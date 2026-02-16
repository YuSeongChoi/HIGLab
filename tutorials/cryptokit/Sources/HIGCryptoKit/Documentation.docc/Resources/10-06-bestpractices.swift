import CryptoKit
import Foundation

// 🔐 보안 모범 사례

// 1. 키는 Keychain에 저장
// - 절대 UserDefaults나 파일에 저장하지 않음
// - Secure Enclave 사용 권장

// 2. 키 교체 (Key Rotation)
// - 정기적으로 키 갱신
// - 의심스러운 활동 시 즉시 교체

// 3. Perfect Forward Secrecy
// - 일회용 키(ephemeral key) 사용
// - 과거 메시지 보호

// 4. 인증 후 암호화 (Encrypt-then-MAC)
// - AES-GCM이 이를 자동으로 처리

// 5. 상수 시간 비교
// - 타이밍 공격 방지
func constantTimeCompare(_ a: Data, _ b: Data) -> Bool {
    guard a.count == b.count else { return false }
    var result: UInt8 = 0
    for (x, y) in zip(a, b) {
        result |= x ^ y
    }
    return result == 0
}

// 6. 메모리에서 민감 데이터 제거
// - Swift는 자동 메모리 관리이므로 주의 필요

print("✅ 보안 모범 사례를 항상 따르세요!")
