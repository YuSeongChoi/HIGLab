import SwiftUI
import Observation

@Observable
class AppSettings {
    var isDarkMode: Bool = false
    var fontSize: CGFloat = 14
}

/// ✅ @Observable 객체는 일반 클래스처럼 다루면 됩니다!
/// @StateObject/@ObservedObject 고민 끝!

struct MainView: View {
    // 방법 1: @State로 소유 (SwiftUI가 수명 관리)
    @State private var settings = AppSettings()
    
    var body: some View {
        SettingsView(settings: settings)
    }
}

struct SettingsView: View {
    // 방법 2: 그냥 프로퍼티로 참조
    var settings: AppSettings
    
    var body: some View {
        Toggle("다크 모드", isOn: $settings.isDarkMode)
        // 💡 $settings.isDarkMode는 @Bindable 덕분에 동작
        // (다음 챕터에서 자세히!)
    }
}

// 방법 3: @Environment로 주입
struct AppWithEnvironment: View {
    @State private var settings = AppSettings()
    
    var body: some View {
        ContentView()
            .environment(settings)
    }
}

struct ContentView: View {
    @Environment(AppSettings.self) var settings
    
    var body: some View {
        Text(settings.isDarkMode ? "🌙" : "☀️")
    }
}

// 💡 더 이상 "이 상황에서 @StateObject? @ObservedObject?" 고민 없음!
