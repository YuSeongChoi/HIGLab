import AuthenticationServices

// Sign in with Apple 핵심 컴포넌트

// 1. Apple ID 인증 제공자
let appleIDProvider = ASAuthorizationAppleIDProvider()

// 2. 인증 요청 생성
let request = appleIDProvider.createRequest()
request.requestedScopes = [.fullName, .email]

// 3. 인증 컨트롤러로 흐름 관리
let authorizationController = ASAuthorizationController(
    authorizationRequests: [request]
)

// 4. 결과는 ASAuthorizationAppleIDCredential로 전달됨
