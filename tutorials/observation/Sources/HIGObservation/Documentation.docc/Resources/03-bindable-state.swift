import SwiftUI
import Observation

/// 패턴 3: @State와 함께 사용
/// @State로 @Observable 객체를 소유하면 자동으로 Bindable처럼 동작!

@Observable
class LoginForm {
    var email: String = ""
    var password: String = ""
    var rememberMe: Bool = false
    
    var isValid: Bool {
        email.contains("@") && password.count >= 8
    }
}

struct LoginView: View {
    // ✅ @State로 소유하면 $ 문법이 바로 동작!
    @State private var form = LoginForm()
    
    var body: some View {
        Form {
            Section("로그인") {
                // @Bindable 없이도 $ 사용 가능
                TextField("이메일", text: $form.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                
                SecureField("비밀번호", text: $form.password)
                    .textContentType(.password)
            }
            
            Section {
                Toggle("로그인 유지", isOn: $form.rememberMe)
            }
            
            Section {
                Button("로그인") {
                    login()
                }
                .disabled(!form.isValid) // 계산 프로퍼티도 자동 추적
            }
        }
    }
    
    private func login() {
        print("로그인: \(form.email)")
    }
}

// 💡 요약:
// - @State로 @Observable 소유 → @Bindable 불필요
// - 외부에서 받거나 @Environment → @Bindable 필요
