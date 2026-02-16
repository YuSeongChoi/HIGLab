import SwiftUI
import SwiftData

// 일괄 삭제 구현

struct BatchDeleteView: View {
    @Environment(\.modelContext) private var context
    @Query private var tasks: [TaskItem]
    
    @State private var showingDeleteAlert = false
    
    var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var body: some View {
        VStack {
            // 통계 표시
            HStack {
                Label("\(tasks.count) 전체", systemImage: "list.bullet")
                Spacer()
                Label("\(completedCount) 완료", systemImage: "checkmark.circle")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding()
            
            // 일괄 삭제 버튼
            if completedCount > 0 {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("완료된 항목 모두 삭제", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .alert("완료된 항목 삭제", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제 (\(completedCount)개)", role: .destructive) {
                deleteAllCompleted()
            }
        } message: {
            Text("완료된 \(completedCount)개의 할 일을 모두 삭제하시겠습니까?")
        }
    }
    
    private func deleteAllCompleted() {
        withAnimation {
            for task in tasks where task.isCompleted {
                context.delete(task)
            }
        }
    }
}

// ─────────────────────────────────────────

// 백그라운드에서 대량 삭제

@MainActor
class BatchDeleteService {
    let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    /// 완료된 모든 항목 삭제 (백그라운드)
    func deleteAllCompleted() async throws {
        let bgContext = ModelContext(container)
        
        try await Task.detached {
            let predicate = #Predicate<TaskItem> { $0.isCompleted }
            let descriptor = FetchDescriptor(predicate: predicate)
            let completedTasks = try bgContext.fetch(descriptor)
            
            for task in completedTasks {
                bgContext.delete(task)
            }
            
            try bgContext.save()
        }.value
    }
    
    /// 오래된 완료 항목 삭제 (30일 이전)
    func deleteOldCompleted(daysOld: Int = 30) async throws {
        let bgContext = ModelContext(container)
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -daysOld, to: .now)!
        
        try await Task.detached {
            let predicate = #Predicate<TaskItem> { task in
                task.isCompleted && (task.completedAt ?? Date.distantFuture) < cutoffDate
            }
            
            let descriptor = FetchDescriptor(predicate: predicate)
            let oldTasks = try bgContext.fetch(descriptor)
            
            for task in oldTasks {
                bgContext.delete(task)
            }
            
            try bgContext.save()
        }.value
    }
    
    /// 모든 데이터 삭제 (초기화)
    func deleteAllData() async throws {
        let bgContext = ModelContext(container)
        
        try await Task.detached {
            try bgContext.delete(model: TaskItem.self)
            try bgContext.save()
        }.value
    }
}

// ─────────────────────────────────────────

// 💡 대량 삭제 팁:
// 1. 백그라운드 컨텍스트로 메인 스레드 블로킹 방지
// 2. 삭제 전 확인 대화상자 필수
// 3. 진행 상태 표시 (ProgressView)
// 4. 에러 처리 및 사용자 피드백
