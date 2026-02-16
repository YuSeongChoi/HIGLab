import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("로그인")
                .font(.largeTitle)
            
            // SwiftUI 전용 Sign in with Apple 버튼
            SignInWithAppleButton(.signIn) { request in
                // 인증 요청 구성
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                // 결과 처리
                switch result {
                case .success(let authorization):
                    handleSuccess(authorization)
                case .failure(let error):
                    handleError(error)
                }
            }
            .frame(height: 50)
            .padding(.horizontal, 40)
        }
    }
    
    private func handleSuccess(_ authorization: ASAuthorization) {
        if let credential = authorization.credential 
            as? ASAuthorizationAppleIDCredential {
            print("User: \(credential.user)")
        }
    }
    
    private func handleError(_ error: Error) {
        print("Error: \(error)")
    }
}
