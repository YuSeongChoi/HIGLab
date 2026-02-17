import SwiftUI

/// 메인 탭 뷰
/// 각 탭에서 다양한 TipKit 사용 사례를 보여줍니다.
struct ContentView: View {
    var body: some View {
        TabView {
            // MARK: - 인라인 팁 탭
            InlineTipView()
                .tabItem {
                    Label("인라인", systemImage: "text.bubble")
                }
            
            // MARK: - 팝오버 팁 탭
            PopoverTipView()
                .tabItem {
                    Label("팝오버", systemImage: "bubble.left.and.bubble.right")
                }
            
            // MARK: - 이벤트 기반 팁 탭
            EventTipView()
                .tabItem {
                    Label("이벤트", systemImage: "bell.badge")
                }
            
            // MARK: - 설정 탭
            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
