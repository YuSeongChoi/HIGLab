// Info.plist 설정 (XML 형식)
/*
<key>NSFaceIDUsageDescription</key>
<string>SecureVault의 보안 콘텐츠에 접근하려면 Face ID 인증이 필요합니다.</string>
*/

// 또는 Xcode에서:
// Target → Info → Custom iOS Target Properties
// + NSFaceIDUsageDescription
// Value: "SecureVault의 보안 콘텐츠에 접근하려면 Face ID 인증이 필요합니다."

// ⚠️ 중요: 이 키가 없으면 Face ID 사용 시 앱이 크래시됩니다!
// Touch ID는 별도 키가 필요 없습니다.

// 좋은 설명 예시:
// ✅ "개인 메모와 파일을 안전하게 보호하기 위해 Face ID를 사용합니다."
// ✅ "본인 확인을 통해 민감한 정보를 보호합니다."

// 나쁜 설명 예시:
// ❌ "Face ID 사용" (너무 모호함)
// ❌ "인증 필요" (목적 불명확)
