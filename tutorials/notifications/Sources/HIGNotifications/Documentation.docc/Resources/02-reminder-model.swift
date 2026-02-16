import Foundation

struct Reminder: Identifiable, Codable {
    let id: UUID
    var title: String
    var note: String
    var dueDate: Date
    var isCompleted: Bool
    var category: Category
    var priority: Priority
    
    // 알림 ID - 나중에 알림을 취소할 때 사용
    var notificationID: String {
        "reminder-\(id.uuidString)"
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        note: String = "",
        dueDate: Date,
        isCompleted: Bool = false,
        category: Category = .personal,
        priority: Priority = .medium
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.category = category
        self.priority = priority
    }
    
    enum Category: String, Codable, CaseIterable {
        case work = "업무"
        case personal = "개인"
        case health = "건강"
        case shopping = "쇼핑"
    }
    
    enum Priority: Int, Codable, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
    }
}
