#if canImport(ImagePlayground)
import SwiftUI
import ImagePlayground

struct MultipleConceptsView: View {
    @State private var isPresented = false
    
    // 여러 개념을 조합하여 더 풍부한 이미지 생성
    let concepts: [ImagePlaygroundConcept] = [
        .text("우주 비행사"),           // 주요 피사체
        .text("화성 표면"),             // 배경/환경
        .text("영화 같은 조명")          // 분위기/스타일
    ]
    
    var body: some View {
        Button("우주 탐험가 생성") {
            isPresented = true
        }
        .imagePlaygroundSheet(
            isPresented: $isPresented,
            concepts: concepts
        ) { url in
            // 모든 개념이 조합되어 이미지 생성
        }
    }
}
#endif
