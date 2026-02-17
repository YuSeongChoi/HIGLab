import SwiftUI
import AppIntents

// 종합: Siri 기능 발견성 높이기

// 1. 온보딩에서 소개
struct OnboardingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("Siri로 제어하세요")
                .font(.title)
            
            Text("\"책 검색해줘\", \"독서 목록 보여줘\" 같은 음성 명령을 사용할 수 있습니다.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            // 주요 기능 팁 표시
            VStack(spacing: 12) {
                SiriTipView(intent: SearchBooksIntent())
                SiriTipView(intent: ShowReadingListIntent())
            }
            .padding()
        }
        .padding()
    }
}

// 2. 적절한 시점에 팁 표시
struct BookListView: View {
    @State private var books: [BookEntity] = []
    @State private var hasShownSearchTip = false
    
    var body: some View {
        List(books, id: \.id) { book in
            BookRow(book: book)
        }
        .searchable(text: .constant(""))
        .onAppear {
            // 검색을 여러 번 사용한 후 Siri 팁 표시
            if UserDefaults.standard.integer(forKey: "searchCount") > 3 && !hasShownSearchTip {
                // SiriTipView를 sheet나 overlay로 표시
            }
        }
    }
}

// 3. 설정 화면에 Siri 섹션
struct SiriSettingsSection: View {
    var body: some View {
        Section("Siri & 단축어") {
            // 단축어 앱 열기
            ShortcutsLink()
            
            // 음성 명령 예시
            NavigationLink("사용 가능한 음성 명령") {
                VoiceCommandsListView()
            }
        }
    }
}

struct VoiceCommandsListView: View {
    var body: some View {
        List {
            Section("검색") {
                SiriTipView(intent: SearchBooksIntent())
            }
            
            Section("목록") {
                SiriTipView(intent: ShowReadingListIntent())
            }
            
            Section("추가") {
                SiriTipView(intent: AddBookIntent())
            }
        }
        .navigationTitle("음성 명령")
    }
}
