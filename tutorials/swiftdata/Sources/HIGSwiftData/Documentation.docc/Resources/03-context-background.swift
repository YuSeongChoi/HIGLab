import SwiftData
import Foundation

// MainActor Context vs Background Context

@MainActor
class TaskViewModel {
    let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    // 메인 컨텍스트 사용 (UI 업데이트용)
    var mainContext: ModelContext {
        container.mainContext
    }
    
    // ─────────────────────────────────────────
    // 백그라운드 작업용 새 컨텍스트
    // ─────────────────────────────────────────
    
    func importLargeData() async throws {
        // 백그라운드 컨텍스트 생성
        let bgContext = ModelContext(container)
        
        // 백그라운드에서 대량 작업
        try await Task.detached {
            // 1000개 항목 삽입
            for i in 0..<1000 {
                let task = TaskItem(title: "Task \(i)")
                bgContext.insert(task)
                
                // 100개마다 중간 저장 (메모리 관리)
                if i % 100 == 0 {
                    try bgContext.save()
                }
            }
            
            // 최종 저장
            try bgContext.save()
        }.value
        
        // UI 갱신은 mainContext가 자동 처리
    }
    
    // ─────────────────────────────────────────
    // Batch 삭제
    // ─────────────────────────────────────────
    
    func deleteAllCompleted() async throws {
        let bgContext = ModelContext(container)
        
        try await Task.detached {
            // 완료된 항목 조회
            let predicate = #Predicate<TaskItem> { $0.isCompleted }
            let descriptor = FetchDescriptor(predicate: predicate)
            let completedTasks = try bgContext.fetch(descriptor)
            
            // 일괄 삭제
            for task in completedTasks {
                bgContext.delete(task)
            }
            
            try bgContext.save()
        }.value
    }
}

// ─────────────────────────────────────────

// 💡 언제 백그라운드 컨텍스트를 사용하나?
// - 대량 데이터 가져오기 (1000개+)
// - 일괄 삭제/수정
// - 네트워크 응답 파싱 후 저장
// - 앱 시작 시 시드 데이터 삽입

// ⚠️ 주의사항
// - 다른 컨텍스트의 객체를 직접 전달하지 않기
// - ID로 다시 조회하거나 @Query로 자동 갱신
