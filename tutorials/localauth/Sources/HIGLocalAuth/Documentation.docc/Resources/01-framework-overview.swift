// LocalAuthentication Framework Overview
// iOS 8.0+, macOS 10.10+, watchOS 3.0+, visionOS 1.0+

import LocalAuthentication

/// LocalAuthentication은 사용자 신원을 확인하는 프레임워크입니다.
/// - Face ID (TrueDepth 카메라)
/// - Touch ID (지문 센서)
/// - Optic ID (Apple Vision Pro)
/// - 기기 패스코드 (폴백)
///
/// 핵심 특징:
/// 1. Secure Enclave에서 생체 데이터 처리
/// 2. 앱은 생체 데이터에 직접 접근 불가
/// 3. 인증 결과(성공/실패)만 전달받음
