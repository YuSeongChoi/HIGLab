import SwiftUI
import ImagePlayground

struct BasicFlowView: View {
    @State private var showImagePlayground = false
    @State private var generatedImageURL: URL?
    
    var body: some View {
        VStack(spacing: 20) {
            // 생성된 이미지 표시
            if let url = generatedImageURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300)
                } placeholder: {
                    ProgressView()
                }
            }
            
            // Image Playground 실행 버튼
            Button {
                showImagePlayground = true
            } label: {
                Label("이미지 생성하기", systemImage: "wand.and.stars")
            }
            .buttonStyle(.borderedProminent)
        }
        .imagePlaygroundSheet(isPresented: $showImagePlayground) { url in
            // 사용자가 이미지를 선택하면 호출됨
            generatedImageURL = url
        }
    }
}
