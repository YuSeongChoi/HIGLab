import SwiftUI
import Observation

/// @Observable에서의 양방향 바인딩
@Observable
class UserSettings {
    var username: String = ""
    var isDarkMode: Bool = false
}

struct SettingsView: View {
    // ✅ @Bindable을 붙여야 $ 문법 사용 가능!
    @Bindable var settings: UserSettings
    
    var body: some View {
        Form {
            // @Bindable 덕분에 $ 접두사로 Binding 생성
            TextField("사용자 이름", text: $settings.username)
            
            Toggle("다크 모드", isOn: $settings.isDarkMode)
        }
    }
}

// ❌ @Bindable 없이는 컴파일 에러!
struct BrokenSettingsView: View {
    var settings: UserSettings // @Bindable 없음
    
    var body: some View {
        Form {
            // 💥 에러: Cannot find '$settings' in scope
            // TextField("사용자 이름", text: $settings.username)
            
            // 읽기는 가능
            Text(settings.username)
        }
    }
}
