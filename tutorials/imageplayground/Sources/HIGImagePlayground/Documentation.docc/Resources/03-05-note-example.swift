#if canImport(ImagePlayground)
import SwiftUI
import ImagePlayground

// 노트 앱에서의 활용 예시
struct NoteAppView: View {
    @State private var isPresented = false
    @State private var generatedImageURL: URL?
    
    let note = Note(
        title: "주말 요리 계획",
        content: "토요일에는 이탈리안 파스타를 만들 예정이다. 신선한 토마토와 바질, 모짜렐라 치즈를 사용해서 카프레제 샐러드도 함께 준비하려고 한다."
    )
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(note.title)
                .font(.headline)
            
            Text(note.content)
                .font(.body)
            
            // 생성된 이미지
            if let url = generatedImageURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxHeight: 200)
            }
            
            Button("이 노트로 이미지 만들기") {
                isPresented = true
            }
        }
        .imagePlaygroundSheet(
            isPresented: $isPresented,
            concepts: [.extracted(from: note.content, title: note.title)]
        ) { url in
            generatedImageURL = url
        }
    }
}

struct Note {
    let title: String
    let content: String
}
#endif
