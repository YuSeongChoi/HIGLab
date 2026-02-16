import LocalAuthentication
import SwiftUI

@Observable
final class AuthenticationManager {
    // 인증 상태
    var isAuthenticated = false
    var isAuthenticating = false
    var errorMessage: String?
    
    // 생체 인증 타입
    var biometryType: LABiometryType = .none
    
    init() {
        updateBiometryType()
    }
    
    // 생체 인증 타입 확인
    func updateBiometryType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometryType = context.biometryType
        } else {
            biometryType = .none
        }
    }
    
    // 인증 요청
    func authenticate() async -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = "패스코드 사용"
        
        isAuthenticating = true
        errorMessage = nil
        
        defer { isAuthenticating = false }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "SecureVault에 접근하려면 인증하세요"
            )
            isAuthenticated = success
            return success
        } catch let error as LAError {
            errorMessage = errorMessage(for: error)
            isAuthenticated = false
            return false
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
            return false
        }
    }
    
    // 잠금
    func lock() {
        isAuthenticated = false
    }
    
    private func errorMessage(for error: LAError) -> String {
        switch error.code {
        case .userCancel:
            return "인증이 취소되었습니다"
        case .biometryLockout:
            return "생체 인증이 잠겼습니다. 패스코드를 사용하세요"
        case .biometryNotEnrolled:
            return "생체 인증이 설정되지 않았습니다"
        default:
            return "인증에 실패했습니다"
        }
    }
}
