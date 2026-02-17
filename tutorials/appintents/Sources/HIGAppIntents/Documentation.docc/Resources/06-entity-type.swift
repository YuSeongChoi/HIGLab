import AppIntents

struct BookEntity: AppEntity {
    var id: String
    var title: String
    var author: String
    var pageCount: Int
    var coverImageURL: URL?
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(author) · \(pageCount)쪽",
            image: coverImageURL.map { .init(url: $0) }
        )
    }
    
    // 단수/복수 형태 지정
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("책"),
            numericFormat: LocalizedStringResource("\(placeholder: .int)권의 책")
        )
    }
    
    static var defaultQuery = BookQuery()
}
