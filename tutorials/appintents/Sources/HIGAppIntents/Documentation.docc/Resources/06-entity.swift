import AppIntents

// 기본 AppEntity 구현
struct BookEntity: AppEntity {
    // 고유 식별자
    var id: String
    
    // 기본 속성
    var title: String
    var author: String
    var pageCount: Int
    
    // 필수: Entity 표시 방법
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
    
    // 필수: 타입 이름
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "책"
    
    // 필수: 기본 쿼리
    static var defaultQuery = BookQuery()
}
