import LocalAuthentication

// 생체 인증 타입 확인
let context = LAContext()
var error: NSError?

if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
    switch context.biometryType {
    case .faceID:
        print("Face ID 지원")
        // iPhone X 이후 모델
        // TrueDepth 카메라로 얼굴 인식
        
    case .touchID:
        print("Touch ID 지원")
        // iPhone 5s~8, SE
        // 홈 버튼의 지문 센서
        
    case .opticID:
        print("Optic ID 지원")
        // Apple Vision Pro
        // 홍채 패턴 인식
        
    case .none:
        print("생체 인증 미지원")
        
    @unknown default:
        print("새로운 생체 인증 타입")
    }
}
