import SwiftUI
import ImagePlayground

// ImagePlayground의 핵심 구성요소

// 1. imagePlaygroundSheet - 이미지 생성 UI를 표시하는 view modifier
// 2. ImagePlaygroundConcept - 생성할 이미지의 개념을 정의
// 3. ImagePlaygroundStyle - 이미지 스타일 (animation, illustration, sketch)

struct ContentView: View {
    @State private var showPlayground = false
    
    var body: some View {
        Button("이미지 생성") {
            showPlayground = true
        }
        .imagePlaygroundSheet(
            isPresented: $showPlayground,
            concepts: [.text("행복한 고양이")],  // 개념 제공
            style: .animation                    // 스타일 지정
        ) { url in
            // 생성된 이미지 URL 처리
            print("Generated image at: \(url)")
        }
    }
}
