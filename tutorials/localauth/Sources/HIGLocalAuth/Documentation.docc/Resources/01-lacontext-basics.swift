import LocalAuthentication

// LAContext: 모든 인증 작업의 중심
let context = LAContext()

// 주요 속성들
context.localizedFallbackTitle = "패스코드 사용"
context.localizedCancelTitle = "나중에"

// 주요 메서드들
// - canEvaluatePolicy(_:error:) : 인증 가용성 확인 (동기)
// - evaluatePolicy(_:localizedReason:) : 실제 인증 요청 (비동기)

// 인증 가용성 확인
var error: NSError?
if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
    print("생체 인증 사용 가능")
} else {
    print("생체 인증 불가: \(error?.localizedDescription ?? "알 수 없음")")
}
