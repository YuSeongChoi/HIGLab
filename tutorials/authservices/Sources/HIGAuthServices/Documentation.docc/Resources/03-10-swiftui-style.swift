import SwiftUI
import AuthenticationServices

struct StyledLoginView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 30) {
            // .black 스타일 (밝은 배경용)
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email]
            } onCompletion: { _ in }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            
            // .white 스타일 (어두운 배경용)
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email]
            } onCompletion: { _ in }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 50)
            
            // .whiteOutline 스타일
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email]
            } onCompletion: { _ in }
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(height: 50)
            
            // 시스템 테마에 따라 자동 선택
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email]
            } onCompletion: { _ in }
            .signInWithAppleButtonStyle(
                colorScheme == .dark ? .white : .black
            )
            .frame(height: 50)
        }
        .padding()
    }
}
