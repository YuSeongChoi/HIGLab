import AppIntents

struct BookEntity: AppEntity {
    var id: String
    
    // @Property로 단축어에서 접근 가능하게 노출
    @Property(title: "제목")
    var title: String
    
    @Property(title: "작가")
    var author: String
    
    @Property(title: "페이지 수")
    var pageCount: Int
    
    @Property(title: "출간일")
    var publishDate: Date?
    
    @Property(title: "읽음")
    var isRead: Bool
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(author)"
        )
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "책"
    static var defaultQuery = BookQuery()
}
