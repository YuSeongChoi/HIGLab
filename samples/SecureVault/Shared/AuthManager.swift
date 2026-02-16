import Foundation
import LocalAuthentication

// MARK: - 인증 관리자
/// LocalAuthentication 프레임워크를 래핑하여 Face ID/Touch ID 인증을 처리
/// HIG 권장: 생체 인증 실패 시 대체 인증 방법(암호)을 제공해야 함

@MainActor
final class AuthManager: ObservableObject {
    
    // MARK: - 발행 속성
    
    /// 현재 인증 상태
    @Published private(set) var isAuthenticated = false
    
    /// 인증 중 여부
    @Published private(set) var isAuthenticating = false
    
    /// 마지막 에러 메시지
    @Published var errorMessage: String?
    
    // MARK: - 인증 컨텍스트
    
    /// LAContext 인스턴스 (매 인증마다 새로 생성 권장)
    private var context: LAContext {
        let ctx = LAContext()
        // 생체 인증 실패 시 시스템 암호 입력 허용
        ctx.localizedFallbackTitle = "암호 입력"
        // 취소 버튼 텍스트
        ctx.localizedCancelTitle = "취소"
        return ctx
    }
    
    // MARK: - 생체 인증 가용성
    
    /// 생체 인증 사용 가능 여부
    var isBiometricAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// 디바이스 인증(생체 + 암호) 사용 가능 여부
    var isDeviceAuthAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }
    
    /// 현재 사용 가능한 생체 인증 유형
    var biometryType: LABiometryType {
        let ctx = context
        _ = ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return ctx.biometryType
    }
    
    /// 생체 인증 유형 표시 문자열
    var biometryTypeString: String {
        switch biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "생체 인증 없음"
        @unknown default:
            return "알 수 없음"
        }
    }
    
    /// 생체 인증 아이콘 이름
    var biometryIconName: String {
        switch biometryType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        case .none:
            return "lock.fill"
        @unknown default:
            return "lock.fill"
        }
    }
    
    // MARK: - 인증 메서드
    
    /// 생체 인증 수행
    /// - Parameter reason: 인증 요청 사유 (시스템 다이얼로그에 표시)
    /// - Returns: 인증 성공 여부
    @discardableResult
    func authenticate(reason: String = "보안 금고에 접근하려면 인증이 필요합니다") async -> Bool {
        // 이미 인증된 상태면 true 반환
        guard !isAuthenticated else { return true }
        
        // 인증 진행 중 상태로 변경
        isAuthenticating = true
        errorMessage = nil
        
        defer {
            isAuthenticating = false
        }
        
        // 새 컨텍스트 생성 (매 인증마다 새로 생성해야 함)
        let ctx = context
        
        // 인증 정책 결정: 생체 인증 우선, 불가 시 디바이스 인증
        let policy: LAPolicy = isBiometricAvailable
            ? .deviceOwnerAuthenticationWithBiometrics
            : .deviceOwnerAuthentication
        
        do {
            // 인증 시도
            let success = try await ctx.evaluatePolicy(policy, localizedReason: reason)
            isAuthenticated = success
            return success
        } catch let error as LAError {
            // LAError 유형별 처리
            handleAuthError(error)
            return false
        } catch {
            // 기타 에러
            errorMessage = "알 수 없는 오류가 발생했습니다: \(error.localizedDescription)"
            return false
        }
    }
    
    /// 암호만으로 인증 (생체 인증 실패 시 대안)
    /// - Returns: 인증 성공 여부
    @discardableResult
    func authenticateWithPasscode(reason: String = "암호를 입력하세요") async -> Bool {
        isAuthenticating = true
        errorMessage = nil
        
        defer {
            isAuthenticating = false
        }
        
        let ctx = context
        // 생체 인증 비활성화, 암호만 허용
        ctx.localizedFallbackTitle = ""
        
        do {
            let success = try await ctx.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
            isAuthenticated = success
            return success
        } catch let error as LAError {
            handleAuthError(error)
            return false
        } catch {
            errorMessage = "알 수 없는 오류가 발생했습니다"
            return false
        }
    }
    
    /// 잠금 (인증 해제)
    func lock() {
        isAuthenticated = false
        errorMessage = nil
    }
    
    // MARK: - 에러 처리
    
    /// LAError 유형별 에러 메시지 처리
    private func handleAuthError(_ error: LAError) {
        switch error.code {
        case .authenticationFailed:
            errorMessage = "인증에 실패했습니다. 다시 시도해주세요."
            
        case .userCancel:
            errorMessage = "인증이 취소되었습니다."
            
        case .userFallback:
            // 사용자가 '암호 입력' 선택 시
            // 별도 처리 없이 시스템이 암호 입력 화면 표시
            errorMessage = nil
            
        case .biometryNotAvailable:
            errorMessage = "생체 인증을 사용할 수 없습니다."
            
        case .biometryNotEnrolled:
            errorMessage = "생체 인증이 등록되어 있지 않습니다. 설정에서 \(biometryTypeString)을(를) 등록해주세요."
            
        case .biometryLockout:
            errorMessage = "너무 많은 시도로 생체 인증이 잠겼습니다. 암호를 입력해주세요."
            
        case .passcodeNotSet:
            errorMessage = "기기에 암호가 설정되어 있지 않습니다. 설정 > Face ID 및 암호에서 설정해주세요."
            
        case .systemCancel:
            // 시스템에 의한 취소 (예: 다른 앱으로 전환)
            errorMessage = nil
            
        case .appCancel:
            errorMessage = nil
            
        case .invalidContext:
            errorMessage = "인증 컨텍스트가 유효하지 않습니다. 앱을 다시 시작해주세요."
            
        case .notInteractive:
            errorMessage = "현재 상태에서 인증을 수행할 수 없습니다."
            
        @unknown default:
            errorMessage = "알 수 없는 인증 오류가 발생했습니다."
        }
    }
}

// MARK: - 미리보기용 Mock
#if DEBUG
extension AuthManager {
    /// 미리보기용 인증된 상태의 AuthManager
    static var authenticatedPreview: AuthManager {
        let manager = AuthManager()
        manager.isAuthenticated = true
        return manager
    }
    
    /// 미리보기용 잠긴 상태의 AuthManager
    static var lockedPreview: AuthManager {
        AuthManager()
    }
}
#endif
