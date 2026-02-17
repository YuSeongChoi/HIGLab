import SwiftUI
import AppIntents

struct BookDetailView: View {
    let book: BookEntity
    @State private var showSiriTip = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 책 정보
                BookInfoSection(book: book)
                
                // 읽기 버튼
                Button("읽기 시작") {
                    startReading()
                    // 읽기 시작할 때 관련 Siri 팁 표시
                    showSiriTip = true
                }
                .buttonStyle(.borderedProminent)
                
                // 맥락에 맞는 Siri 팁
                if showSiriTip {
                    SiriTipView(intent: MarkAsReadIntent())
                        .siriTipViewStyle(.automatic)
                        .onDisappear {
                            showSiriTip = false
                        }
                }
            }
            .padding()
        }
        .navigationTitle(book.title)
    }
    
    private func startReading() {
        // 읽기 시작 로직
    }
}
