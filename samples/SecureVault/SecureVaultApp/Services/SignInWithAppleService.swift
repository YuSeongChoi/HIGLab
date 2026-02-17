import Foundation
import AuthenticationServices
import Combine

// MARK: - Apple 로그인 서비스
/// Authentication Services 프레임워크를 사용한 Sign in with Apple 구현
///
/// ## 주요 기능:
/// - ASAuthorizationController를 통한 Apple ID 인증
/// - ASAuthorizationAppleIDCredential 처리
/// - ASAuthorizationPasswordProvider를 통한 Keychain 자격 증명
/// - 자격 증명 상태 확인 및 모니터링
///
/// ## HIG 권장사항:
/// - 'Sign in with Apple' 버튼은 Apple 가이드라인 준수
/// - 최초 로그인 시에만 이메일/이름 제공됨 (저장 필요)
/// - 앱 실행 시 자격 증명 상태 확인

@MainActor
final class SignInWithAppleService: NSObject, ObservableObject {
    
    // MARK: - 발행 속성
    
    /// 현재 로그인 상태
    @Published private(set) var signInState: SignInState = .unknown
    
    /// 로그인 진행 중 여부
    @Published private(set) var isSigningIn = false
    
    /// 마지막 에러
    @Published private(set) var lastError: SecurityError?
    
    /// 현재 사용자 정보
    @Published private(set) var currentUser: AppleUser?
    
    // MARK: - 상태 열거형
    
    /// 로그인 상태
    enum SignInState: Equatable {
        /// 상태 확인 전
        case unknown
        /// 로그인됨
        case signedIn
        /// 로그아웃됨
        case signedOut
        /// 자격 증명 취소됨 (사용자가 설정에서 연결 해제)
        case revoked
        /// 사용자를 찾을 수 없음
        case notFound
        /// 에러 발생
        case error(SecurityError)
        
        var isAuthenticated: Bool {
            self == .signedIn
        }
    }
    
    // MARK: - 사용자 정보
    
    /// Apple 로그인 사용자 정보
    struct AppleUser: Codable, Equatable, Sendable {
        /// Apple에서 제공하는 고유 사용자 식별자
        let userIdentifier: String
        
        /// 이메일 (최초 로그인 시에만 제공)
        let email: String?
        
        /// 이름 (최초 로그인 시에만 제공)
        let fullName: PersonNameComponents?
        
        /// 인증 코드
        let authorizationCode: Data?
        
        /// ID 토큰
        let identityToken: Data?
        
        /// 계정 상태
        let realUserStatus: RealUserStatus
        
        /// 최초 가입 시점
        let signUpDate: Date
        
        /// 마지막 로그인 시점
        var lastSignInDate: Date
        
        /// 실사용자 상태
        enum RealUserStatus: Int, Codable, Sendable {
            case unsupported = 0
            case unknown = 1
            case likelyReal = 2
        }
        
        init(from credential: ASAuthorizationAppleIDCredential) {
            self.userIdentifier = credential.user
            self.email = credential.email
            self.fullName = credential.fullName
            self.authorizationCode = credential.authorizationCode
            self.identityToken = credential.identityToken
            self.realUserStatus = RealUserStatus(rawValue: credential.realUserStatus.rawValue) ?? .unknown
            self.signUpDate = Date()
            self.lastSignInDate = Date()
        }
        
        /// 표시용 이름
        var displayName: String {
            if let fullName = fullName {
                let formatter = PersonNameComponentsFormatter()
                formatter.style = .default
                let formatted = formatter.string(from: fullName)
                if !formatted.isEmpty {
                    return formatted
                }
            }
            return email ?? "Apple 사용자"
        }
        
        /// ID 토큰 문자열
        var identityTokenString: String? {
            guard let token = identityToken else { return nil }
            return String(data: token, encoding: .utf8)
        }
    }
    
    // MARK: - 내부 속성
    
    /// 현재 인증 요청의 continuation
    private var authContinuation: CheckedContinuation<AppleUser, Error>?
    
    /// Keychain 서비스
    private let keychainService = KeychainService.shared
    
    /// Crypto 서비스
    private let cryptoService = CryptoService.shared
    
    /// 상태 변경 감지용
    private var credentialStateObserver: NSObjectProtocol?
    
    // MARK: - 초기화
    
    override init() {
        super.init()
        
        // 앱 시작 시 자격 증명 상태 확인
        Task {
            await checkCredentialState()
        }
        
        // 자격 증명 취소 알림 구독
        registerForCredentialRevokeNotification()
    }
    
    deinit {
        if let observer = credentialStateObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - 로그인
    
    /// Sign in with Apple 요청
    /// - Returns: 로그인된 사용자 정보
    func signIn() async throws -> AppleUser {
        guard !isSigningIn else {
            throw SecurityError.authorizationSessionFailed
        }
        
        isSigningIn = true
        lastError = nil
        
        defer {
            isSigningIn = false
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.authContinuation = continuation
            performSignInRequest()
        }
    }
    
    /// 인증 요청 수행
    private func performSignInRequest() {
        // Apple ID 인증 요청 생성
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        
        // 요청할 정보 범위 (이메일, 이름)
        request.requestedScopes = [.fullName, .email]
        
        // nonce 생성 (보안 강화용)
        let nonce = cryptoService.generateSalt(length: 32)
        let nonceString = nonce.base64EncodedString()
        request.nonce = cryptoService.sha256Hex(nonce)
        
        // Keychain 비밀번호 자동완성도 요청 (선택적)
        let passwordRequest = ASAuthorizationPasswordProvider().createRequest()
        
        // 인증 컨트롤러 생성
        let controller = ASAuthorizationController(authorizationRequests: [request, passwordRequest])
        controller.delegate = self
        controller.presentationContextProvider = self
        
        // 요청 수행
        controller.performRequests()
    }
    
    /// Keychain 자격 증명으로 빠른 로그인
    /// - Note: 이미 저장된 비밀번호가 있을 경우 사용
    func signInWithExistingCredentials() async throws -> AppleUser {
        isSigningIn = true
        lastError = nil
        
        defer {
            isSigningIn = false
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.authContinuation = continuation
            performExistingCredentialsRequest()
        }
    }
    
    /// 기존 자격 증명 요청
    private func performExistingCredentialsRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let passwordProvider = ASAuthorizationPasswordProvider()
        
        let requests: [ASAuthorizationRequest] = [
            appleIDProvider.createRequest(),
            passwordProvider.createRequest()
        ]
        
        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = self
        controller.presentationContextProvider = self
        
        // 기존 자격 증명으로 빠른 로그인 시도
        controller.performRequests(options: .preferImmediatelyAvailableCredentials)
    }
    
    // MARK: - 로그아웃
    
    /// 로그아웃 (로컬 상태만 변경)
    /// - Note: Apple ID 연결 해제는 설정 앱에서만 가능
    func signOut() {
        currentUser = nil
        signInState = .signedOut
        
        // Keychain에서 사용자 정보 삭제
        try? keychainService.deleteAppleUserId()
        try? deleteStoredUser()
    }
    
    // MARK: - 자격 증명 상태 확인
    
    /// Apple ID 자격 증명 상태 확인
    /// - Note: 앱 실행 시 또는 foreground 복귀 시 호출 권장
    func checkCredentialState() async {
        guard let userIdentifier = try? keychainService.loadAppleUserId() else {
            signInState = .signedOut
            return
        }
        
        do {
            let state = try await getCredentialState(for: userIdentifier)
            handleCredentialState(state, userIdentifier: userIdentifier)
        } catch {
            signInState = .error(SecurityError.appleSignInFailed(underlying: error))
        }
    }
    
    /// Apple ID Provider에서 자격 증명 상태 조회
    private func getCredentialState(for userIdentifier: String) async throws -> ASAuthorizationAppleIDProvider.CredentialState {
        try await withCheckedThrowingContinuation { continuation in
            let provider = ASAuthorizationAppleIDProvider()
            provider.getCredentialState(forUserID: userIdentifier) { state, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: state)
                }
            }
        }
    }
    
    /// 자격 증명 상태 처리
    private func handleCredentialState(
        _ state: ASAuthorizationAppleIDProvider.CredentialState,
        userIdentifier: String
    ) {
        switch state {
        case .authorized:
            // 유효한 자격 증명
            signInState = .signedIn
            loadStoredUser()
            
        case .revoked:
            // 사용자가 설정에서 연결 해제함
            signInState = .revoked
            currentUser = nil
            signOut() // 로컬 데이터 정리
            
        case .notFound:
            // 사용자를 찾을 수 없음
            signInState = .notFound
            currentUser = nil
            
        case .transferred:
            // 앱 전송됨 (다른 개발자 계정으로)
            signInState = .signedOut
            
        @unknown default:
            signInState = .unknown
        }
    }
    
    /// 자격 증명 취소 알림 등록
    private func registerForCredentialRevokeNotification() {
        credentialStateObserver = NotificationCenter.default.addObserver(
            forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.signInState = .revoked
                self?.currentUser = nil
                self?.signOut()
            }
        }
    }
    
    // MARK: - 사용자 정보 저장/로드
    
    /// 사용자 정보 저장
    private func saveUser(_ user: AppleUser) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        
        // 암호화하여 저장
        let encrypted = try cryptoService.encryptAESGCMCombined(
            data,
            using: try cryptoService.loadOrCreateKey(identifier: "appleuser")
        )
        
        try keychainService.saveData(encrypted, for: "apple.user.data")
        try keychainService.saveAppleUserId(user.userIdentifier)
    }
    
    /// 저장된 사용자 정보 로드
    private func loadStoredUser() {
        do {
            guard let encryptedData = try keychainService.loadData(for: "apple.user.data"),
                  let key = try cryptoService.loadKeyFromKeychain(identifier: "appleuser") else {
                return
            }
            
            let decrypted = try cryptoService.decryptAESGCMCombined(encryptedData, using: key)
            let decoder = JSONDecoder()
            currentUser = try decoder.decode(AppleUser.self, from: decrypted)
        } catch {
            // 로드 실패 시 무시 (재로그인 필요)
            currentUser = nil
        }
    }
    
    /// 저장된 사용자 정보 삭제
    private func deleteStoredUser() throws {
        try keychainService.deleteData(for: "apple.user.data")
    }
    
    /// 사용자 정보 업데이트 (마지막 로그인 시간 등)
    private func updateUserSignInDate() {
        guard var user = currentUser else { return }
        user.lastSignInDate = Date()
        currentUser = user
        try? saveUser(user)
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension SignInWithAppleService: ASAuthorizationControllerDelegate {
    
    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        Task { @MainActor in
            handleAuthorization(authorization)
        }
    }
    
    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Task { @MainActor in
            handleAuthorizationError(error)
        }
    }
    
    /// 인증 성공 처리
    private func handleAuthorization(_ authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            handleAppleIDCredential(appleIDCredential)
            
        case let passwordCredential as ASPasswordCredential:
            handlePasswordCredential(passwordCredential)
            
        default:
            let error = SecurityError.invalidAppleIDResponse
            lastError = error
            authContinuation?.resume(throwing: error)
            authContinuation = nil
        }
    }
    
    /// Apple ID 자격 증명 처리
    private func handleAppleIDCredential(_ credential: ASAuthorizationAppleIDCredential) {
        var user = AppleUser(from: credential)
        
        // 기존 사용자 정보가 있으면 이름/이메일 유지
        if let existingUser = currentUser, user.userIdentifier == existingUser.userIdentifier {
            if user.email == nil {
                // 이메일은 최초 로그인 시에만 제공됨
            }
            if user.fullName == nil || user.fullName?.givenName == nil {
                // 이름도 마찬가지
            }
            user.lastSignInDate = Date()
        }
        
        // 저장
        do {
            try saveUser(user)
            currentUser = user
            signInState = .signedIn
            authContinuation?.resume(returning: user)
        } catch {
            let secError = SecurityError.keychainSaveFailed(status: -1)
            lastError = secError
            authContinuation?.resume(throwing: secError)
        }
        
        authContinuation = nil
    }
    
    /// 비밀번호 자격 증명 처리
    private func handlePasswordCredential(_ credential: ASPasswordCredential) {
        // Keychain에 저장된 비밀번호로 로그인
        // 이 경우는 Apple ID가 아닌 일반 계정
        // 앱의 필요에 따라 처리
        
        let error = SecurityError.appleIDCredentialNotFound
        lastError = error
        authContinuation?.resume(throwing: error)
        authContinuation = nil
    }
    
    /// 인증 에러 처리
    private func handleAuthorizationError(_ error: Error) {
        let securityError: SecurityError
        
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                securityError = .appleSignInCancelled
                signInState = .signedOut
                
            case .failed:
                securityError = .appleSignInFailed(underlying: error)
                
            case .invalidResponse:
                securityError = .invalidAppleIDResponse
                
            case .notHandled:
                securityError = .authorizationSessionFailed
                
            case .unknown:
                securityError = .unknown(underlying: error)
                
            case .notInteractive:
                securityError = .authorizationSessionFailed
                
            @unknown default:
                securityError = .unknown(underlying: error)
            }
        } else {
            securityError = .appleSignInFailed(underlying: error)
        }
        
        lastError = securityError
        signInState = .error(securityError)
        
        authContinuation?.resume(throwing: securityError)
        authContinuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension SignInWithAppleService: ASAuthorizationControllerPresentationContextProviding {
    
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 현재 활성 윈도우 반환
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

// MARK: - Combine 지원
extension SignInWithAppleService {
    /// 로그인 상태 Publisher
    var signInStatePublisher: AnyPublisher<SignInState, Never> {
        $signInState.eraseToAnyPublisher()
    }
    
    /// 현재 사용자 Publisher
    var currentUserPublisher: AnyPublisher<AppleUser?, Never> {
        $currentUser.eraseToAnyPublisher()
    }
}

// MARK: - 미리보기 지원
#if DEBUG
extension SignInWithAppleService {
    /// 로그인된 상태의 서비스
    static var signedInPreview: SignInWithAppleService {
        let service = SignInWithAppleService()
        service.signInState = .signedIn
        service.currentUser = AppleUser(
            userIdentifier: "preview.user.123",
            email: "preview@example.com",
            fullName: {
                var name = PersonNameComponents()
                name.givenName = "홍"
                name.familyName = "길동"
                return name
            }(),
            authorizationCode: nil,
            identityToken: nil,
            realUserStatus: .likelyReal,
            signUpDate: Date().addingTimeInterval(-86400 * 30),
            lastSignInDate: Date()
        )
        return service
    }
    
    /// 로그아웃된 상태의 서비스
    static var signedOutPreview: SignInWithAppleService {
        let service = SignInWithAppleService()
        service.signInState = .signedOut
        return service
    }
}

// PersonNameComponents Codable 확장
extension PersonNameComponents: @retroactive Codable {
    enum CodingKeys: String, CodingKey {
        case givenName, familyName, middleName, namePrefix, nameSuffix, nickname
    }
    
    public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        givenName = try container.decodeIfPresent(String.self, forKey: .givenName)
        familyName = try container.decodeIfPresent(String.self, forKey: .familyName)
        middleName = try container.decodeIfPresent(String.self, forKey: .middleName)
        namePrefix = try container.decodeIfPresent(String.self, forKey: .namePrefix)
        nameSuffix = try container.decodeIfPresent(String.self, forKey: .nameSuffix)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(givenName, forKey: .givenName)
        try container.encodeIfPresent(familyName, forKey: .familyName)
        try container.encodeIfPresent(middleName, forKey: .middleName)
        try container.encodeIfPresent(namePrefix, forKey: .namePrefix)
        try container.encodeIfPresent(nameSuffix, forKey: .nameSuffix)
        try container.encodeIfPresent(nickname, forKey: .nickname)
    }
}
#endif
