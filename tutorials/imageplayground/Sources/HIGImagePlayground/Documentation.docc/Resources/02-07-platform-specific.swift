#if canImport(ImagePlayground)
import SwiftUI
import ImagePlayground

struct PlatformSpecificView: View {
    @State private var isPresented = false
    
    var body: some View {
        VStack {
            // 플랫폼별로 다른 진입점 제공
            #if os(iOS)
            // iPhone/iPad: 툴바 버튼
            NavigationStack {
                ContentArea()
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                isPresented = true
                            } label: {
                                Image(systemName: "wand.and.stars")
                            }
                        }
                    }
            }
            #elseif os(macOS)
            // Mac: 메뉴 바 + 단축키
            ContentArea()
                .keyboardShortcut("g", modifiers: [.command, .shift])
            #endif
        }
        .imagePlaygroundSheet(isPresented: $isPresented) { _ in }
    }
}

struct ContentArea: View {
    var body: some View {
        Text("메인 콘텐츠")
    }
}
#endif
