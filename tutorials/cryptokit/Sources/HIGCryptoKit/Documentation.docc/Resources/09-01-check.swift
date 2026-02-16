import CryptoKit
import Foundation

// Secure Enclave 사용 가능 여부 확인
let isAvailable = SecureEnclave.isAvailable

if isAvailable {
    print("Secure Enclave 사용 가능!")
} else {
    print("Secure Enclave 미지원 (시뮬레이터 또는 구형 기기)")
}

// Secure Enclave 지원 기기:
// - iPhone 5s 이상 (A7 칩+)
// - iPad Air 이상
// - Mac with T1/T2/Apple Silicon
