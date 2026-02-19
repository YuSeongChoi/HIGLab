#if canImport(ImagePlayground)
import SwiftUI
import ImagePlayground

struct ExtractedConceptView: View {
    @State private var isPresented = false
    
    // 긴 텍스트에서 개념 추출
    let noteContent = """
    오늘 제주도 여행을 다녀왔다. 
    한라산 정상에서 본 일출은 정말 아름다웠다.
    구름 위로 솟아오르는 태양의 빛이 
    온 세상을 황금빛으로 물들였다.
    """
    
    // extracted 개념: AI가 텍스트에서 핵심 이미지 개념을 추출
    var concept: ImagePlaygroundConcept {
        .extracted(from: noteContent, title: "제주도 여행 일기")
    }
    
    var body: some View {
        Button("일기 내용으로 이미지 생성") {
            isPresented = true
        }
        .imagePlaygroundSheet(
            isPresented: $isPresented,
            concepts: [concept]
        ) { url in
            // 일기 내용을 바탕으로 이미지 생성
        }
    }
}
#endif
