import SwiftUI
import ImagePlayground

struct ConceptsParameterView: View {
    @State private var isPresented = false
    @State private var userInput = "마법사"
    
    // 사용자 입력을 개념으로 변환
    var concepts: [ImagePlaygroundConcept] {
        [.text(userInput)]
    }
    
    var body: some View {
        VStack {
            TextField("원하는 이미지 설명", text: $userInput)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("이미지 생성") {
                isPresented = true
            }
            .disabled(userInput.isEmpty)
        }
        .imagePlaygroundSheet(
            isPresented: $isPresented,
            concepts: concepts  // 동적으로 생성된 개념 전달
        ) { url in
            // 사용자의 설명을 기반으로 이미지 생성됨
        }
    }
}
