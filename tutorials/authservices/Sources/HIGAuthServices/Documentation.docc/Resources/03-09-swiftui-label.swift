import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    var body: some View {
        VStack(spacing: 20) {
            // .signIn - "Sign in with Apple"
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email]
            } onCompletion: { _ in }
            .frame(height: 50)
            
            // .signUp - "Sign up with Apple"
            SignInWithAppleButton(.signUp) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { _ in }
            .frame(height: 50)
            
            // .continue - "Continue with Apple"
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.email]
            } onCompletion: { _ in }
            .frame(height: 50)
        }
        .padding()
    }
}
