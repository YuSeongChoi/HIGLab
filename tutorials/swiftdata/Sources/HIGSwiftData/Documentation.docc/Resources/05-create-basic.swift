import SwiftUI
import SwiftData

// Create: 데이터 생성

struct CreateExampleView: View {
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack(spacing: 20) {
            Button("빠른 할 일 추가") {
                quickAdd()
            }
            
            Button("상세 할 일 추가") {
                detailedAdd()
            }
        }
    }
    
    // 기본 생성
    func quickAdd() {
        let task = TaskItem(title: "새로운 할 일")
        context.insert(task)
        // 끝! autosave가 자동 저장
    }
    
    // 상세 정보와 함께 생성
    func detailedAdd() {
        let task = TaskItem(
            title: "프로젝트 마감",
            note: "최종 리뷰 및 제출",
            priority: .urgent,
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: .now)
        )
        context.insert(task)
    }
}

// ─────────────────────────────────────────

// 생성 패턴 정리

extension ModelContext {
    /// 새 할 일 추가 헬퍼
    func addTask(
        title: String,
        note: String = "",
        priority: Priority = .medium,
        dueDate: Date? = nil
    ) -> TaskItem {
        let task = TaskItem(
            title: title,
            note: note,
            priority: priority,
            dueDate: dueDate
        )
        insert(task)
        return task
    }
}

// 사용 예시
func usageExample(context: ModelContext) {
    // 헬퍼 사용
    let task = context.addTask(
        title: "회의 준비",
        priority: .high
    )
    print("생성됨: \(task.title)")
}

// ─────────────────────────────────────────

// 💡 생성 팁:
// 1. insert() 후 별도 save() 불필요 (autosave)
// 2. @Attribute(.unique) 필드 중복 시 → 기존 항목 업데이트
// 3. 관계 객체는 삽입 순서 중요 (부모 먼저)
// 4. 대량 삽입 시 백그라운드 컨텍스트 사용
