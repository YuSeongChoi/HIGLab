import AuthenticationServices
import Combine

class ModernAppleAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupCredentialRevokedPublisher()
    }
    
    private func setupCredentialRevokedPublisher() {
        // Combine을 사용한 알림 관찰
        NotificationCenter.default.publisher(
            for: ASAuthorizationAppleIDProvider.credentialRevokedNotification
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.handleCredentialRevoked()
        }
        .store(in: &cancellables)
    }
    
    private func handleCredentialRevoked() {
        // 비동기 상태 확인
        Task {
            await verifyAndHandleRevocation()
        }
    }
    
    private func verifyAndHandleRevocation() async {
        guard let userID = getSavedUserID() else { return }
        
        let provider = ASAuthorizationAppleIDProvider()
        
        do {
            let state = try await provider.credentialState(forUserID: userID)
            
            await MainActor.run {
                if state == .revoked {
                    self.isAuthenticated = false
                    self.performLogout()
                }
            }
        } catch {
            // 오류 처리
        }
    }
    
    private func getSavedUserID() -> String? { nil }
    private func performLogout() { }
}
