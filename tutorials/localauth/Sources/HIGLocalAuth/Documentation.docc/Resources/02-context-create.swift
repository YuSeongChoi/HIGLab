import LocalAuthentication

// LAContext 인스턴스 생성
// 권장: 매 인증마다 새 인스턴스 생성

func authenticate() async throws -> Bool {
    // 새 인스턴스 생성 (이전 인증 상태 초기화)
    let context = LAContext()
    
    // 인증 수행
    return try await context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: "보안 콘텐츠에 접근"
    )
}

// ⚠️ 재사용 시 주의점:
// - 이전 인증 결과가 캐시될 수 있음
// - touchIDAuthenticationAllowableReuseDuration 영향받음
// - 보안상 새 인스턴스 생성 권장
