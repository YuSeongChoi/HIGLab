import SwiftUI
import SwiftData

struct ContentView: View {
    // ModelContext 주입
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 헤더
                headerView
                
                // 빈 상태 (아직 @Query 없음)
                emptyStateView
                
                Spacer()
                
                // 테스트용 버튼
                testButtons
            }
            .padding()
            .navigationTitle("TaskMaster")
        }
    }
    
    // MARK: - 서브뷰들
    
    private var headerView: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundStyle(.green.gradient)
            
            Text("할 일 관리")
                .font(.title2.bold())
            
            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundStyle(.gray.opacity(0.5))
            
            Text("아직 할 일이 없습니다")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("+ 버튼을 눌러 추가하세요")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var testButtons: some View {
        VStack(spacing: 12) {
            Button {
                addSampleTask()
            } label: {
                Label("샘플 할 일 추가", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Text("SwiftData가 연결되었습니다! ✅")
                .font(.caption)
                .foregroundStyle(.green)
        }
    }
    
    // MARK: - Actions
    
    private func addSampleTask() {
        let task = TaskItem(
            title: "SwiftData 학습하기",
            note: "Chapter 3 완료!",
            priority: .high
        )
        context.insert(task)
        print("✅ Task 추가됨: \(task.title)")
    }
}
