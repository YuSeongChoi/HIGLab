import SwiftUI
import Observation

/// 패턴 2: body 내에서 @Bindable 사용
/// @Environment로 받은 객체를 바인딩할 때 유용합니다.

@Observable
class AppTheme {
    var primaryColor: Color = .blue
    var fontSize: CGFloat = 16
    var useDarkMode: Bool = false
}

struct ThemeSettingsView: View {
    // @Environment로 받으면 @Bindable을 직접 붙일 수 없음
    @Environment(AppTheme.self) var theme
    
    var body: some View {
        // ✅ body 내에서 @Bindable 지역 변수 생성
        @Bindable var bindableTheme = theme
        
        Form {
            Section("색상") {
                ColorPicker("메인 색상", selection: $bindableTheme.primaryColor)
            }
            
            Section("글꼴") {
                Slider(value: $bindableTheme.fontSize, in: 12...24) {
                    Text("글자 크기: \(Int(bindableTheme.fontSize))pt")
                }
            }
            
            Section("테마") {
                Toggle("다크 모드", isOn: $bindableTheme.useDarkMode)
            }
        }
    }
}

// 앱 설정
struct ThemeApp: View {
    @State private var theme = AppTheme()
    
    var body: some View {
        NavigationStack {
            ThemeSettingsView()
        }
        .environment(theme) // 환경에 주입
    }
}
