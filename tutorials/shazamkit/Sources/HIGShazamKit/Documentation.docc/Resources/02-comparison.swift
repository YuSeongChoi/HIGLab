import ShazamKit
import AVFoundation

// SHSession vs SHManagedSession 비교

// ── SHSession (iOS 15+) ──
// 장점: 세밀한 제어 가능
// 단점: 많은 설정 코드 필요
class TraditionalApproach {
    let session = SHSession()
    let audioEngine = AVAudioEngine()
    let signatureGenerator = SHSignatureGenerator()
    
    // 직접 해야 할 것들:
    // 1. AVAudioEngine 설정
    // 2. 마이크 탭 설치
    // 3. 시그니처 생성기에 버퍼 전달
    // 4. 세션에 시그니처 전달
}

// ── SHManagedSession (iOS 17+) ──
// 장점: 한 줄로 음악 인식
// 단점: 커스텀 오디오 소스 지원 안 함
@available(iOS 17.0, *)
class ModernApproach {
    let session = SHManagedSession()
    
    func recognize() async -> SHSession.Result {
        await session.result()  // 이게 전부!
    }
}
