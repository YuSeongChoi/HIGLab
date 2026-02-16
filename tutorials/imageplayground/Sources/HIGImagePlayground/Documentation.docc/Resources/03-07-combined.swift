import SwiftUI
import ImagePlayground

struct CombinedConceptsView: View {
    @State private var isPresented = false
    
    // 텍스트 개념과 함께 사람 이미지 사용
    // 사용자가 시트에서 피플 선택 가능
    let textConcepts: [ImagePlaygroundConcept] = [
        .text("우주 비행사 복장"),
        .text("달 표면에서"),
        .text("지구를 배경으로")
    ]
    
    var body: some View {
        VStack {
            Text("나를 우주 비행사로!")
                .font(.title)
            
            Text("피플 앨범에서 자신을 선택하면\n우주 비행사가 된 모습을 볼 수 있어요")
                .multilineTextAlignment(.center)
                .font(.caption)
            
            Button {
                isPresented = true
            } label: {
                Label("시작하기", systemImage: "person.crop.circle.badge.plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .imagePlaygroundSheet(
            isPresented: $isPresented,
            concepts: textConcepts,
            style: .animation
        ) { url in
            // 선택한 사람 + 우주 비행사 컨셉이 결합된 이미지
        }
    }
}
