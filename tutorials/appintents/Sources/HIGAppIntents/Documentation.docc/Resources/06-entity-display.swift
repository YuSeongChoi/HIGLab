import AppIntents

struct BookEntity: AppEntity {
    var id: String
    var title: String
    var author: String
    var pageCount: Int
    var coverImageURL: URL?
    
    // 풍부한 표시 정보 제공
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(author) · \(pageCount)쪽",
            image: coverImageURL.map { .init(url: $0) }
        )
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "책"
    static var defaultQuery = BookQuery()
}
