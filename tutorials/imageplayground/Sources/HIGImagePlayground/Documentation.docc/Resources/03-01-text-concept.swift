import SwiftUI
import ImagePlayground

struct TextConceptView: View {
    @State private var isPresented = false
    
    // 텍스트 개념 생성 - 가장 기본적인 방식
    let concept = ImagePlaygroundConcept.text("해변에서 석양을 바라보는 강아지")
    
    var body: some View {
        Button("이미지 생성") {
            isPresented = true
        }
        .imagePlaygroundSheet(
            isPresented: $isPresented,
            concepts: [concept]  // 개념을 배열로 전달
        ) { url in
            print("생성된 이미지: \(url)")
        }
    }
}
