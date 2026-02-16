import SwiftUI
import ImagePlayground

// 동일한 코드가 iPhone, iPad, Mac에서 모두 작동
struct CrossPlatformView: View {
    @State private var isPresented = false
    @State private var imageURL: URL?
    
    var body: some View {
        VStack {
            #if os(iOS)
            Text("iOS에서 실행 중")
            #elseif os(macOS)
            Text("macOS에서 실행 중")
            #endif
            
            Button("이미지 생성") {
                isPresented = true
            }
            .imagePlaygroundSheet(isPresented: $isPresented) { url in
                imageURL = url
            }
        }
    }
}
