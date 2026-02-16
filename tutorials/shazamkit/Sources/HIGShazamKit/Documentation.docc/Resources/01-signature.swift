import ShazamKit
import AVFoundation

// SHSignature - 오디오 핑거프린트
class SignatureExample {
    let generator = SHSignatureGenerator()
    
    // 오디오 버퍼에서 시그니처 생성
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer, at time: AVAudioTime) throws {
        try generator.append(buffer, at: time)
    }
    
    // 최종 시그니처 얻기
    func getSignature() -> SHSignature {
        return generator.signature()
    }
    
    // 시그니처 저장/로드
    func saveAndLoad() throws {
        let signature = generator.signature()
        
        // Data로 저장
        let data = signature.dataRepresentation
        try data.write(to: URL(fileURLWithPath: "/tmp/my.shazamsignature"))
        
        // 파일에서 로드
        let loadedSignature = try SHSignature(dataRepresentation: data)
    }
}
