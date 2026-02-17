import Foundation
import LocalAuthentication
import Combine

// MARK: - 생체 인증 서비스
/// LocalAuthentication 프레임워크를 사용한 생체 인증 관리
/// Face ID, Touch ID, Optic ID 지원 및 암호 폴백 처리
///
/// ## 주요 기능:
/// - LAContext 생명주기 관리
/// - 생체 인증 가용성 확인
/// - 인증 정책 선택 (생체만 / 생체+암호)
/// - 재사용 시간 설정 (touchIDAuthenticationAllowableReuseDuration)
/// - 인증 실패 시 폴백 처리
///
/// ## HIG 권장사항:
/// - 생체 인증 실패 시 반드시 대체 인증 방법 제공
/// - 인증 요청 사유를 명확하게 표시
/// - 사용자가 인증 방식을 선택할 수 있도록 제공

@MainActor
final class BiometricService: ObservableObject {
    
    // MARK: - 발행 속성
    
    /// 현재 인증 상태
    @Published private(set) var isAuthenticated = false
    
    /// 인증 진행 중 여부
    @Published private(set) var isAuthenticating = false
    
    /// 마지막 인증 시간
    @Published private(set) var lastAuthenticationDate: Date?
    
    /// 마지막 에러
    @Published private(set) var lastError: SecurityError?
    
    /// 현재 생체 인증 상태
    @Published private(set) var biometricStatus: BiometricStatus
    
    /// 연속 실패 횟수
    @Published private(set) var consecutiveFailures: Int = 0
    
    // MARK: - 설정
    
    /// 인증 재사용 시간 (초)
    /// - Note: 이 시간 내에 재인증 요청 시 즉시 성공 처리
    var authenticationReuseDuration: TimeInterval = 60
    
    /// 최대 연속 실패 허용 횟수
    var maxConsecutiveFailures: Int = 5
    
    /// 폴백 버튼 제목 (nil이면 시스템 기본값)
    var fallbackButtonTitle: String? = "암호 입력"
    
    /// 취소 버튼 제목
    var cancelButtonTitle: String = "취소"
    
    // MARK: - 내부 상태
    
    /// 현재 활성 LAContext
    private var currentContext: LAContext?
    
    /// 컨텍스트 무효화 여부
    private var isContextInvalidated = false
    
    /// 키체인 서비스 참조
    private let keychainService = KeychainService.shared
    
    // MARK: - 초기화
    
    init() {
        // 초기 상태 확인
        self.biometricStatus = BiometricStatus.current
        
        // 저장된 마지막 인증 시간 로드
        self.lastAuthenticationDate = keychainService.lastUnlockDate
    }
    
    // MARK: - 상태 확인
    
    /// 현재 기기의 생체 인증 유형
    var biometryType: BiometryType {
        BiometryType.current
    }
    
    /// 생체 인증 사용 가능 여부
    var isBiometricAvailable: Bool {
        if case .available = biometricStatus {
            return true
        }
        return false
    }
    
    /// 기기 인증 (생체 또는 암호) 사용 가능 여부
    var isDeviceAuthAvailable: Bool {
        var error: NSError?
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }
    
    /// 상태 새로고침
    func refreshStatus() {
        biometricStatus = BiometricStatus.current
    }
    
    // MARK: - LAContext 관리
    
    /// 새 LAContext 생성
    /// - Note: 각 인증 시도마다 새 컨텍스트를 생성하는 것이 권장됨
    private func createContext(
        reason: String,
        allowFallback: Bool = true,
        reuseDuration: TimeInterval? = nil
    ) -> LAContext {
        let context = LAContext()
        
        // 인증 요청 사유
        context.localizedReason = reason
        
        // 폴백 버튼 설정
        if allowFallback {
            context.localizedFallbackTitle = fallbackButtonTitle
        } else {
            context.localizedFallbackTitle = "" // 빈 문자열로 설정하면 폴백 버튼 숨김
        }
        
        // 취소 버튼 설정
        context.localizedCancelTitle = cancelButtonTitle
        
        // 재사용 시간 설정 (Touch ID/Face ID 인증 결과 캐싱)
        // 이 시간 동안은 재인증 없이 통과
        context.touchIDAuthenticationAllowableReuseDuration = reuseDuration ?? authenticationReuseDuration
        
        // 현재 컨텍스트 저장
        currentContext = context
        isContextInvalidated = false
        
        return context
    }
    
    /// 현재 컨텍스트 무효화
    /// - Note: 앱이 백그라운드로 전환되거나 보안 이벤트 발생 시 호출
    func invalidateContext() {
        currentContext?.invalidate()
        currentContext = nil
        isContextInvalidated = true
        isAuthenticated = false
    }
    
    // MARK: - 인증 메서드
    
    /// 기본 생체 인증 수행
    /// - Parameters:
    ///   - reason: 인증 요청 사유 (시스템 다이얼로그에 표시)
    ///   - policy: 인증 정책 (기본값: 생체 또는 암호)
    /// - Returns: 인증 결과
    func authenticate(
        reason: String = "보안 금고에 접근하려면 인증이 필요합니다",
        policy: AuthenticationPolicy = .biometricsOrPasscode
    ) async -> AuthenticationResult {
        // 이미 인증된 상태이고 재사용 시간 내라면 즉시 성공
        if isAuthenticated, let lastAuth = lastAuthenticationDate {
            let elapsed = Date().timeIntervalSince(lastAuth)
            if elapsed < authenticationReuseDuration {
                return .success
            }
        }
        
        // 인증 진행 중이면 대기
        guard !isAuthenticating else {
            return .failed(SecurityError.systemCancelled)
        }
        
        isAuthenticating = true
        lastError = nil
        
        defer {
            isAuthenticating = false
        }
        
        // 새 컨텍스트 생성
        let context = createContext(
            reason: reason,
            allowFallback: policy != .biometricsOnly
        )
        
        // 정책 선택
        let laPolicy = policy.laPolicy
        
        // 정책 사용 가능 여부 확인
        var policyError: NSError?
        guard context.canEvaluatePolicy(laPolicy, error: &policyError) else {
            let error = mapLAError(policyError)
            lastError = error
            return .failed(error)
        }
        
        do {
            // 인증 시도
            let success = try await context.evaluatePolicy(laPolicy, localizedReason: reason)
            
            if success {
                handleAuthenticationSuccess()
                return .success
            } else {
                handleAuthenticationFailure()
                return .failed(SecurityError.biometricAuthenticationFailed)
            }
        } catch let error as LAError {
            return handleLAError(error)
        } catch {
            let securityError = SecurityError.unknown(underlying: error)
            lastError = securityError
            return .failed(securityError)
        }
    }
    
    /// 생체 인증만 수행 (암호 폴백 없음)
    /// - Parameter reason: 인증 요청 사유
    /// - Returns: 인증 결과
    func authenticateWithBiometricsOnly(
        reason: String = "생체 인증이 필요합니다"
    ) async -> AuthenticationResult {
        return await authenticate(reason: reason, policy: .biometricsOnly)
    }
    
    /// 암호로만 인증 (생체 인증 건너뜀)
    /// - Parameter reason: 인증 요청 사유
    /// - Returns: 인증 결과
    func authenticateWithPasscode(
        reason: String = "암호를 입력하세요"
    ) async -> AuthenticationResult {
        guard !isAuthenticating else {
            return .failed(SecurityError.systemCancelled)
        }
        
        isAuthenticating = true
        lastError = nil
        
        defer {
            isAuthenticating = false
        }
        
        // 폴백 버튼 숨기고 암호만 허용
        let context = createContext(reason: reason, allowFallback: false)
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            let securityError = mapLAError(error)
            lastError = securityError
            return .failed(securityError)
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
            
            if success {
                handleAuthenticationSuccess()
                return .success
            } else {
                handleAuthenticationFailure()
                return .failed(SecurityError.biometricAuthenticationFailed)
            }
        } catch let laError as LAError {
            return handleLAError(laError)
        } catch {
            let securityError = SecurityError.unknown(underlying: error)
            lastError = securityError
            return .failed(securityError)
        }
    }
    
    /// 생체 인증 시도 후 실패 시 암호로 폴백
    /// - Parameter reason: 인증 요청 사유
    /// - Returns: 인증 결과
    func authenticateWithFallback(
        reason: String = "보안 금고에 접근하려면 인증이 필요합니다"
    ) async -> AuthenticationResult {
        // 먼저 생체 인증 시도
        let biometricResult = await authenticateWithBiometricsOnly(reason: reason)
        
        switch biometricResult {
        case .success:
            return .success
            
        case .fallbackRequested, .lockedOut:
            // 생체 인증 실패 → 암호로 폴백
            return await authenticateWithPasscode(reason: "암호를 입력하세요")
            
        case .cancelled:
            return .cancelled
            
        case .failed(let error):
            // 특정 에러는 암호로 폴백 가능
            switch error {
            case .biometricLockout, .biometricAuthenticationFailed:
                return await authenticateWithPasscode(reason: "암호를 입력하세요")
            default:
                return .failed(error)
            }
        }
    }
    
    // MARK: - 인증 상태 관리
    
    /// 인증 성공 처리
    private func handleAuthenticationSuccess() {
        isAuthenticated = true
        lastAuthenticationDate = Date()
        consecutiveFailures = 0
        
        // 키체인에 마지막 인증 시간 저장
        keychainService.lastUnlockDate = lastAuthenticationDate
    }
    
    /// 인증 실패 처리
    private func handleAuthenticationFailure() {
        consecutiveFailures += 1
        
        // 최대 실패 횟수 초과 시 잠금
        if consecutiveFailures >= maxConsecutiveFailures {
            lastError = SecurityError.biometricLockout
        }
    }
    
    /// LAError를 AuthenticationResult로 변환
    private func handleLAError(_ error: LAError) -> AuthenticationResult {
        let securityError: SecurityError
        let result: AuthenticationResult
        
        switch error.code {
        case .authenticationFailed:
            handleAuthenticationFailure()
            securityError = .biometricAuthenticationFailed
            result = .failed(securityError)
            
        case .userCancel:
            securityError = .biometricUserCancelled
            result = .cancelled
            
        case .userFallback:
            securityError = .userFallback
            result = .fallbackRequested
            
        case .systemCancel:
            securityError = .systemCancelled
            result = .cancelled
            
        case .passcodeNotSet:
            securityError = .passcodeNotSet
            result = .failed(securityError)
            
        case .biometryNotAvailable:
            securityError = .biometricNotAvailable
            result = .failed(securityError)
            
        case .biometryNotEnrolled:
            securityError = .biometricNotEnrolled
            result = .failed(securityError)
            
        case .biometryLockout:
            securityError = .biometricLockout
            result = .lockedOut
            
        case .appCancel:
            securityError = .systemCancelled
            result = .cancelled
            
        case .invalidContext:
            invalidateContext()
            securityError = .authContextInvalidated
            result = .failed(securityError)
            
        case .notInteractive:
            securityError = .systemCancelled
            result = .failed(securityError)
            
        @unknown default:
            securityError = .unknown(underlying: error)
            result = .failed(securityError)
        }
        
        lastError = securityError
        return result
    }
    
    /// NSError를 SecurityError로 변환
    private func mapLAError(_ error: NSError?) -> SecurityError {
        guard let error = error else {
            return .biometricNotAvailable
        }
        
        guard let laError = LAError.Code(rawValue: error.code) else {
            return .unknown(underlying: error)
        }
        
        switch laError {
        case .biometryNotAvailable:
            return .biometricNotAvailable
        case .biometryNotEnrolled:
            return .biometricNotEnrolled
        case .biometryLockout:
            return .biometricLockout
        case .passcodeNotSet:
            return .passcodeNotSet
        default:
            return .unknown(underlying: error)
        }
    }
    
    // MARK: - 잠금/해제
    
    /// 앱 잠금 (인증 상태 해제)
    func lock() {
        invalidateContext()
        isAuthenticated = false
        lastAuthenticationDate = nil
    }
    
    /// 인증 없이 잠금 해제 (테스트/디버그용)
    #if DEBUG
    func unlockForTesting() {
        isAuthenticated = true
        lastAuthenticationDate = Date()
    }
    #endif
    
    // MARK: - 설정 앱 열기
    
    /// 생체 인증 설정 화면 열기
    /// - Note: iOS 16+에서는 직접 Face ID/Touch ID 설정으로 이동 가능
    func openSystemSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(settingsURL)
    }
    
    // MARK: - 키체인 연동 인증
    
    /// 키체인 항목 접근을 위한 인증
    /// - Parameters:
    ///   - key: 접근할 키체인 키
    ///   - reason: 인증 요청 사유
    /// - Returns: 키체인 데이터 (인증 성공 시)
    func authenticateAndLoadFromKeychain(
        key: String,
        reason: String = "보안 데이터에 접근하려면 인증이 필요합니다"
    ) async throws -> Data {
        let result = await authenticate(reason: reason)
        
        guard result.isSuccess else {
            switch result {
            case .failed(let error):
                throw error
            case .cancelled:
                throw SecurityError.biometricUserCancelled
            case .lockedOut:
                throw SecurityError.biometricLockout
            case .fallbackRequested:
                // 암호로 다시 시도
                let fallbackResult = await authenticateWithPasscode()
                guard fallbackResult.isSuccess else {
                    throw SecurityError.biometricAuthenticationFailed
                }
            case .success:
                break // 성공인 경우는 이미 guard에서 처리됨
            }
        }
        
        // 키체인에서 데이터 로드
        return try await keychainService.loadWithBiometricProtection(for: key, authenticationPrompt: reason)
    }
}

// MARK: - 인증 이벤트 델리게이트
protocol BiometricServiceDelegate: AnyObject {
    /// 인증 성공
    func biometricServiceDidAuthenticate(_ service: BiometricService)
    
    /// 인증 실패
    func biometricService(_ service: BiometricService, didFailWithError error: SecurityError)
    
    /// 잠금됨
    func biometricServiceDidLock(_ service: BiometricService)
}

// MARK: - Combine 지원
extension BiometricService {
    /// 인증 상태 변화 Publisher
    var authenticationStatePublisher: AnyPublisher<Bool, Never> {
        $isAuthenticated.eraseToAnyPublisher()
    }
    
    /// 에러 Publisher
    var errorPublisher: AnyPublisher<SecurityError?, Never> {
        $lastError.eraseToAnyPublisher()
    }
}

// MARK: - 미리보기 지원
#if DEBUG
extension BiometricService {
    /// 인증된 상태의 서비스
    static var authenticatedPreview: BiometricService {
        let service = BiometricService()
        service.isAuthenticated = true
        service.lastAuthenticationDate = Date()
        return service
    }
    
    /// 잠긴 상태의 서비스
    static var lockedPreview: BiometricService {
        BiometricService()
    }
    
    /// 에러 상태의 서비스
    static var errorPreview: BiometricService {
        let service = BiometricService()
        service.lastError = .biometricLockout
        service.consecutiveFailures = 5
        return service
    }
}
#endif
