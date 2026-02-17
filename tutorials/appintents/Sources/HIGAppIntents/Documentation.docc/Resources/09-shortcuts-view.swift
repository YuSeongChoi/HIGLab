import AppIntents
import SwiftUI

struct SearchBooksIntent: AppIntent {
    static var title: LocalizedStringResource = "책 검색"
    
    @Parameter(title: "검색어")
    var query: String
    
    // 커스텀 SwiftUI 뷰로 결과 표시
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        let results = await BookStore.shared.search(query)
        
        return .result(
            value: results,
            dialog: "\(results.count)권의 책을 찾았습니다."
        ) {
            // 커스텀 결과 뷰
            BookSearchResultView(books: results)
        }
    }
}

// 단축어 결과에 표시될 뷰
struct BookSearchResultView: View {
    let books: [BookEntity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(books.prefix(3), id: \.id) { book in
                HStack {
                    Image(systemName: "book.closed")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading) {
                        Text(book.title)
                            .font(.headline)
                        Text(book.author)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            if books.count > 3 {
                Text("외 \(books.count - 3)권...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
