import SwiftData
import Foundation

// @Model 매크로로 데이터 모델 정의
// class에만 적용 가능! (struct 불가)

@Model
class TaskItem {
    // 기본 프로퍼티들
    var title: String
    var note: String
    var isCompleted: Bool
    var createdAt: Date
    
    // 필수: init 메서드
    init(
        title: String,
        note: String = "",
        isCompleted: Bool = false,
        createdAt: Date = .now
    ) {
        self.title = title
        self.note = note
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

// ⚠️ 컴파일 에러 예시
// @Model
// struct TaskItem { } // ❌ Error: @Model은 class에만 적용 가능

// 💡 왜 class인가?
// - 참조 타입이라 변경 추적이 가능
// - 동일 객체를 여러 곳에서 참조 가능
// - Observable 패턴 구현에 적합
