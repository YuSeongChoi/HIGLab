import AuthenticationServices

// 요청 가능한 Scopes

let request = ASAuthorizationAppleIDProvider().createRequest()

// 이름과 이메일 모두 요청
request.requestedScopes = [.fullName, .email]

// 이메일만 요청
// request.requestedScopes = [.email]

// 이름만 요청
// request.requestedScopes = [.fullName]

// scope 없음 - User Identifier만 받음
// request.requestedScopes = []

// 주의: email과 fullName은 첫 인증 시에만 제공됩니다!
// 이후 재인증에서는 nil이 반환됩니다.
