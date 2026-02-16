import CoreData

// ❌ Core Data의 복잡함

// 1. .xcdatamodeld 파일에서 엔티티 정의 (XML 편집기 필요)
// 2. NSManagedObject 서브클래스 생성 (코드젠 설정)
// 3. 문자열 기반 NSFetchRequest

class TaskItem: NSManagedObject {
    @NSManaged var title: String?
    @NSManaged var isCompleted: Bool
    @NSManaged var createdAt: Date?
}

// Fetch Request 생성
func fetchTasks() -> [TaskItem] {
    let request = NSFetchRequest<TaskItem>(entityName: "TaskItem")
    request.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: false))
    request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
    
    // 문자열 기반 → 타입 체크 없음, 오타 시 런타임 크래시
    // "createAt" 오타를 컴파일러가 잡아주지 않음
    
    do {
        return try context.fetch(request)
    } catch {
        print("Fetch failed: \(error)")
        return []
    }
}
