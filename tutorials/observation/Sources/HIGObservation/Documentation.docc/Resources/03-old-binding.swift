import SwiftUI
import Combine

/// ObservableObject에서의 양방향 바인딩
class OldUserSettings: ObservableObject {
    @Published var username: String = ""
    @Published var isDarkMode: Bool = false
}

struct OldSettingsView: View {
    @ObservedObject var settings: OldUserSettings
    
    var body: some View {
        Form {
            // ✅ @Published의 projectedValue가 Binding 제공
            TextField("사용자 이름", text: $settings.username)
            
            Toggle("다크 모드", isOn: $settings.isDarkMode)
        }
    }
}

// 💡 @Published는 내부적으로 Publisher이면서 Binding도 제공합니다.
// projected value ($)가 Binding<Value>를 반환합니다.
