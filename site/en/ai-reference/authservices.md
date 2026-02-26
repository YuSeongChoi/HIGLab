# Authentication Services AI Reference

> Sign in with Apple 및 패스키 구현 가이드. 이 문서를 읽고 인증 코드를 생성할 수 있습니다.

## 개요

Authentication Services는 Sign in with Apple, 패스키(Passkeys), 
자동 완성 비밀번호를 관리하는 프레임워크입니다.

## 필수 Import

```swift
import AuthenticationServices
```

## 프로젝트 설정

1. **Capabilities**: Sign in with Apple 추가
2. **App ID**: Apple Developer에서 Sign in with Apple 활성화

## 핵심 구성요소

### 1. Sign in with Apple 버튼

```swift
import SwiftUI
import AuthenticationServices

struct SignInView: View {
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            switch result {
            case .success(let auth):
                handleAuthorization(auth)
            case .failure(let error):
                print("로그인 실패: \(error)")
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
    }
    
    func handleAuthorization(_ authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = credential.user
            let email = credential.email
            let fullName = credential.fullName
            let identityToken = credential.identityToken
            
            // 서버로 전송하여 인증
            print("User ID: \(userID)")
        }
    }
}
```

### 2. 버튼 스타일

```swift
// 검은색 배경
SignInWithAppleButton(.signIn) { ... } onCompletion: { ... }
    .signInWithAppleButtonStyle(.black)

// 흰색 배경
.signInWithAppleButtonStyle(.white)

// 테두리만
.signInWithAppleButtonStyle(.whiteOutline)

// 버튼 타입
SignInWithAppleButton(.signIn)    // "Sign in with Apple"
SignInWithAppleButton(.signUp)    // "Sign up with Apple"
SignInWithAppleButton(.continue)  // "Continue with Apple"
```

## 전체 작동 예제

```swift
import SwiftUI
import AuthenticationServices

// MARK: - Auth Manager
@Observable
class AuthManager {
    var isAuthenticated = false
    var userID: String?
    var email: String?
    var fullName: PersonNameComponents?
    var error: Error?
    
    func handleSignIn(_ authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        // 사용자 정보 저장
        userID = credential.user
        email = credential.email  // 첫 로그인 시에만 제공
        fullName = credential.fullName  // 첫 로그인 시에만 제공
        
        // Keychain에 userID 저장
        saveUserID(credential.user)
        
        // 서버 인증용 토큰
        if let tokenData = credential.identityToken,
           let token = String(data: tokenData, encoding: .utf8) {
            // 서버로 토큰 전송하여 검증
            authenticateWithServer(token: token, userID: credential.user)
        }
        
        isAuthenticated = true
    }
    
    func checkExistingCredential() {
        guard let userID = loadUserID() else { return }
        
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userID) { state, error in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    self.userID = userID
                    self.isAuthenticated = true
                case .revoked, .notFound:
                    self.signOut()
                default:
                    break
                }
            }
        }
    }
    
    func signOut() {
        isAuthenticated = false
        userID = nil
        email = nil
        fullName = nil
        deleteUserID()
    }
    
    // MARK: - Keychain
    private func saveUserID(_ userID: String) {
        let data = userID.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "appleUserID",
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func loadUserID() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "appleUserID",
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    private func deleteUserID() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "appleUserID"
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    private func authenticateWithServer(token: String, userID: String) {
        // 서버 API 호출
        // POST /auth/apple { identityToken: token, userID: userID }
    }
}

// MARK: - Views
struct AuthView: View {
    @State private var authManager = AuthManager()
    
    var body: some View {
        NavigationStack {
            if authManager.isAuthenticated {
                ProfileView(authManager: authManager)
            } else {
                LoginView(authManager: authManager)
            }
        }
        .task {
            authManager.checkExistingCredential()
        }
    }
}

struct LoginView: View {
    let authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("환영합니다")
                .font(.largeTitle.bold())
            
            Text("Apple 계정으로 간편하게 로그인하세요")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email, .fullName]
                request.nonce = generateNonce()  // 보안용
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    authManager.handleSignIn(authorization)
                case .failure(let error):
                    authManager.error = error
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    func generateNonce() -> String {
        // 서버와 공유하는 임의 문자열 (CSRF 방지)
        let charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
        return String((0..<32).map { _ in charset.randomElement()! })
    }
}

struct ProfileView: View {
    let authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.blue)
            
            if let name = authManager.fullName {
                Text(PersonNameComponentsFormatter.localizedString(from: name, style: .default))
                    .font(.title2.bold())
            }
            
            if let email = authManager.email {
                Text(email)
                    .foregroundStyle(.secondary)
            }
            
            Text("ID: \(authManager.userID?.prefix(8) ?? "")...")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button("로그아웃", role: .destructive) {
                authManager.signOut()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("프로필")
    }
}
```

## 고급 패턴

### 1. 패스키 (Passkeys)

```swift
class PasskeyManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func signInWithPasskey(challenge: Data) {
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "example.com")
        
        let request = provider.createCredentialAssertionRequest(challenge: challenge)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func registerPasskey(challenge: Data, userID: Data, userName: String) {
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "example.com")
        
        let request = provider.createCredentialRegistrationRequest(
            challenge: challenge,
            name: userName,
            userID: userID
        )
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            // 패스키 로그인 성공
            let signature = credential.signature
            let clientDataJSON = credential.rawClientDataJSON
            // 서버로 전송하여 검증
        }
        
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            // 패스키 등록 성공
            let attestationObject = credential.rawAttestationObject
            // 서버에 저장
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }!
    }
}
```

### 2. 기존 로그인 + Apple 통합

```swift
func performExistingAccountSetup() {
    let appleProvider = ASAuthorizationAppleIDProvider()
    let appleRequest = appleProvider.createRequest()
    appleRequest.requestedScopes = [.email, .fullName]
    
    let passwordProvider = ASAuthorizationPasswordProvider()
    let passwordRequest = passwordProvider.createRequest()
    
    let controller = ASAuthorizationController(authorizationRequests: [appleRequest, passwordRequest])
    controller.delegate = self
    controller.presentationContextProvider = self
    controller.performRequests()
}
```

### 3. 자격 증명 상태 모니터링

```swift
func observeCredentialState() {
    NotificationCenter.default.addObserver(
        forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
        object: nil,
        queue: .main
    ) { _ in
        // 사용자가 Apple ID 설정에서 앱 연결 해제
        // 로그아웃 처리
        self.signOut()
    }
}
```

## 주의사항

1. **이메일/이름은 첫 로그인만**
   - `email`, `fullName`은 최초 로그인 시에만 제공
   - 반드시 서버에 저장해야 함
   - 재로그인 시 `nil`

2. **User ID 관리**
   - `credential.user`는 변하지 않는 고유 ID
   - Keychain에 안전하게 저장
   - 앱 삭제 후 재설치해도 동일

3. **서버 검증 필수**
   - `identityToken`을 서버에서 검증
   - Apple의 공개 키로 JWT 검증
   - `nonce` 일치 확인

4. **Hide My Email**
   - 사용자가 이메일 숨김 선택 가능
   - `xxx@privaterelay.appleid.com` 형태
   - 릴레이로 실제 이메일로 전달됨
