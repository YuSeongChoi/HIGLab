import LocalAuthentication

let context = LAContext()

// localizedFallbackTitle: "비밀번호 입력" 버튼 텍스트

// 기본값: "비밀번호 입력" (또는 "Enter Password")
context.localizedFallbackTitle = nil

// 커스텀 텍스트 설정
context.localizedFallbackTitle = "PIN 코드 사용"
context.localizedFallbackTitle = "패스코드로 잠금 해제"

// 버튼 숨기기 (빈 문자열)
context.localizedFallbackTitle = ""
// → 생체 인증만 허용하고 싶을 때 사용

// 앱별 권장 설정:
// - 일반 앱: nil (시스템 기본값)
// - 커스텀 PIN 앱: "PIN 입력" 또는 ""
// - 고보안 앱: "" (생체 인증만)
