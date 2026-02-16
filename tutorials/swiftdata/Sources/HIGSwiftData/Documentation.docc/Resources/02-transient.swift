import SwiftData
import Foundation

@Model
class TaskItem {
    var title: String
    var note: String
    var isCompleted: Bool
    var createdAt: Date
    var priority: Priority
    
    // ═══════════════════════════════════════════
    // @Transient: 저장하지 않는 프로퍼티
    // ═══════════════════════════════════════════
    
    // ⚠️ 반드시 기본값 필요!
    // 앱 재시작 시 기본값으로 초기화됨
    
    // 편집 중 임시 상태
    @Transient
    var isEditing: Bool = false
    
    // UI 표시용 캐시
    @Transient
    var formattedDate: String = ""
    
    // 네트워크 상태 등 런타임 정보
    @Transient
    var isSyncing: Bool = false
    
    // 계산 프로퍼티 캐시
    @Transient
    var cachedPriorityColor: String = ""
    
    init(
        title: String,
        note: String = "",
        isCompleted: Bool = false,
        priority: Priority = .medium,
        createdAt: Date = .now
    ) {
        self.title = title
        self.note = note
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
    }
    
    // 💡 계산 프로퍼티는 자동으로 저장 안 됨
    // @Transient 없어도 됨
    var isOverdue: Bool {
        // dueDate가 있고 미완료인데 오늘 이전이면 기한 초과
        return false // 실제 로직은 dueDate 추가 후 구현
    }
}

// ─────────────────────────────────────────

// @Transient 사용 시 주의사항:
// 1. 기본값 필수 (없으면 컴파일 에러)
// 2. 앱 재시작 → 기본값으로 리셋
// 3. CloudKit 동기화 대상 아님
// 4. lazy 프로퍼티와 조합 불가

// ❌ 잘못된 예시
// @Transient
// var temp: String  // 컴파일 에러! 기본값 없음

// ✅ 올바른 예시
// @Transient
// var temp: String = ""
