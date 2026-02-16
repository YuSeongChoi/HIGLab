// LocalAuthentication 프레임워크 임포트

import LocalAuthentication
import SwiftUI

// 별도의 라이브러리 설치나 Package 추가가 필요 없습니다.
// iOS SDK에 기본 포함되어 있습니다.

// 사용할 파일 상단에 import만 추가하면 됩니다.

struct AuthenticationManager {
    private let context = LAContext()
    
    func authenticate() async throws -> Bool {
        // LAContext 메서드 사용 가능
        try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "보안 콘텐츠에 접근"
        )
    }
}
