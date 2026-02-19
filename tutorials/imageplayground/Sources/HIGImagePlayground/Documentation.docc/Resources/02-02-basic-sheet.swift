#if canImport(ImagePlayground)
import SwiftUI
import ImagePlayground

struct BasicSheetView: View {
    @State private var isShowingPlayground = false
    @State private var generatedImageURL: URL?
    
    var body: some View {
        VStack {
            // 시트를 표시하는 버튼
            Button("이미지 만들기") {
                isShowingPlayground = true
            }
            .buttonStyle(.borderedProminent)
        }
        // imagePlaygroundSheet modifier 연결
        .imagePlaygroundSheet(isPresented: $isShowingPlayground) { url in
            // 사용자가 이미지를 선택하면 호출됨
            generatedImageURL = url
        }
    }
}
#endif
