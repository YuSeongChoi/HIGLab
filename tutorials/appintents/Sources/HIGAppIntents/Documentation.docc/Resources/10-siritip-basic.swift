import SwiftUI
import AppIntents

struct ContentView: View {
    var body: some View {
        NavigationStack {
            BookListView()
                .navigationTitle("내 책장")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("추가", systemImage: "plus") {
                            // 책 추가
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    // Siri 팁 표시
                    SiriTipView(intent: SearchBooksIntent())
                        .padding()
                }
        }
    }
}
