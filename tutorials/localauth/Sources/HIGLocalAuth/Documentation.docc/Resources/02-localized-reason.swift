import LocalAuthentication

let context = LAContext()

// localizedReason: 인증 다이얼로그에 표시되는 메시지
// - 명확하고 구체적으로 작성
// - 사용자가 왜 인증이 필요한지 이해할 수 있어야 함

// ✅ 좋은 예시:
let goodReasons = [
    "SecureVault의 보안 콘텐츠에 접근합니다",
    "비밀 메모를 보려면 인증이 필요합니다",
    "이 항목을 삭제하려면 본인 확인이 필요합니다"
]

// ❌ 나쁜 예시:
let badReasons = [
    "인증",         // 너무 모호함
    "계속하려면",    // 목적 불명확
    ""              // 빈 문자열 금지
]

// 사용 예:
Task {
    do {
        try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "SecureVault의 보안 콘텐츠에 접근합니다"
        )
    } catch {
        print("인증 실패: \(error)")
    }
}
