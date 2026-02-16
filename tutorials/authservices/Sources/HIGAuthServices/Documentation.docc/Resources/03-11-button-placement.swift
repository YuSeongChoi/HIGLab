import SwiftUI
import AuthenticationServices

struct LoginOptionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("로그인")
                .font(.title)
                .padding(.bottom, 20)
            
            // Sign in with Apple을 맨 위에 배치
            // HIG: 다른 로그인 버튼과 동일하거나 더 눈에 띄게
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { _ in }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            
            // 다른 소셜 로그인 버튼들 (같은 크기)
            Button(action: {}) {
                HStack {
                    Image(systemName: "g.circle.fill")
                    Text("Google로 로그인")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .buttonStyle(.bordered)
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "f.circle.fill")
                    Text("Facebook으로 로그인")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 40)
    }
}
