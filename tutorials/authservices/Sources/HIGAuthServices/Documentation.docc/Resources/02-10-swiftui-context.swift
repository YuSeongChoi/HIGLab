import AuthenticationServices
import SwiftUI

// SwiftUI에서는 SignInWithAppleButton을 사용하면
// presentationContextProvider가 자동 처리됩니다.

struct LoginView: View {
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                handleAuthorization(authorization)
            case .failure(let error):
                handleError(error)
            }
        }
        .frame(height: 50)
        .padding()
    }
    
    private func handleAuthorization(_ authorization: ASAuthorization) {
        // 성공 처리
    }
    
    private func handleError(_ error: Error) {
        // 오류 처리
    }
}

// UIKit 연동이 필요한 경우 (예: 커스텀 로직)
class SwiftUIContextProvider: NSObject, 
    ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        // 활성 윈도우 찾기
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}
