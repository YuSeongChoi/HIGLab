import Foundation
import ShazamKit
import AVFoundation

// MARK: - SignatureManager
/// SHSignature와 SHSignatureGenerator를 사용한 오디오 시그니처 관리자
/// 시그니처 생성, 저장, 불러오기, 비교 기능 제공

@MainActor
@Observable
final class SignatureManager {
    // MARK: - 싱글톤
    static let shared = SignatureManager()
    
    // MARK: - 상태
    enum State: Equatable {
        case idle              // 대기 중
        case generating        // 시그니처 생성 중
        case completed         // 완료
        case error(String)     // 오류
        
        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.generating, .generating), (.completed, .completed):
                return true
            case (.error(let l), .error(let r)):
                return l == r
            default:
                return false
            }
        }
    }
    
    private(set) var state: State = .idle
    
    /// 현재 생성 중인 시그니처의 진행률 (0.0 ~ 1.0)
    private(set) var generationProgress: Double = 0
    
    /// 마지막으로 생성된 시그니처
    private(set) var lastGeneratedSignature: SHSignature?
    
    // MARK: - 저장소 경로
    private var signaturesDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let signaturesPath = documentsPath.appendingPathComponent("Signatures", isDirectory: true)
        
        // 디렉토리 생성
        if !FileManager.default.fileExists(atPath: signaturesPath.path) {
            try? FileManager.default.createDirectory(at: signaturesPath, withIntermediateDirectories: true)
        }
        
        return signaturesPath
    }
    
    // MARK: - 초기화
    private init() {}
    
    // MARK: - 오디오 파일에서 시그니처 생성
    /// 오디오 파일 URL에서 시그니처 생성
    /// - Parameter url: 오디오 파일 URL
    /// - Returns: 생성된 SHSignature
    func generateSignature(from url: URL) async throws -> SHSignature {
        state = .generating
        generationProgress = 0
        
        do {
            // SHSignatureGenerator를 사용하여 파일에서 시그니처 생성
            let generator = SHSignatureGenerator()
            
            // iOS 17+의 async API 사용
            let signature = try await generator.signature(from: url)
            
            state = .completed
            generationProgress = 1.0
            lastGeneratedSignature = signature
            
            return signature
        } catch {
            state = .error("시그니처 생성 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// 오디오 버퍼에서 시그니처 생성 (실시간 오디오용)
    /// - Parameters:
    ///   - buffers: 오디오 버퍼 배열
    ///   - format: 오디오 포맷
    /// - Returns: 생성된 SHSignature
    func generateSignature(
        from buffers: [AVAudioPCMBuffer],
        format: AVAudioFormat
    ) async throws -> SHSignature {
        state = .generating
        generationProgress = 0
        
        let generator = SHSignatureGenerator()
        
        var currentTime = AVAudioTime(sampleTime: 0, atRate: format.sampleRate)
        
        for (index, buffer) in buffers.enumerated() {
            do {
                try generator.append(buffer, at: currentTime)
                
                // 진행률 업데이트
                generationProgress = Double(index + 1) / Double(buffers.count)
                
                // 다음 버퍼의 시작 시간 계산
                let frameCount = AVAudioFramePosition(buffer.frameLength)
                currentTime = AVAudioTime(
                    sampleTime: (currentTime.sampleTime) + frameCount,
                    atRate: format.sampleRate
                )
            } catch {
                state = .error("버퍼 처리 실패: \(error.localizedDescription)")
                throw error
            }
        }
        
        // 최종 시그니처 생성
        let signature = generator.signature()
        
        state = .completed
        generationProgress = 1.0
        lastGeneratedSignature = signature
        
        return signature
    }
    
    // MARK: - 시그니처 저장/로드
    /// 시그니처를 파일로 저장
    /// - Parameters:
    ///   - signature: 저장할 시그니처
    ///   - name: 파일 이름 (확장자 제외)
    /// - Returns: 저장된 파일 URL
    @discardableResult
    func saveSignature(_ signature: SHSignature, name: String) throws -> URL {
        // 시그니처 데이터 직렬화
        let data = signature.dataRepresentation
        
        // 파일 경로 생성
        let fileURL = signaturesDirectory.appendingPathComponent("\(name).shazamsignature")
        
        // 데이터 저장
        try data.write(to: fileURL)
        
        return fileURL
    }
    
    /// 파일에서 시그니처 로드
    /// - Parameter url: 시그니처 파일 URL
    /// - Returns: 로드된 SHSignature
    func loadSignature(from url: URL) throws -> SHSignature {
        let data = try Data(contentsOf: url)
        return try SHSignature(dataRepresentation: data)
    }
    
    /// 이름으로 시그니처 로드
    /// - Parameter name: 시그니처 파일 이름 (확장자 제외)
    /// - Returns: 로드된 SHSignature
    func loadSignature(named name: String) throws -> SHSignature {
        let fileURL = signaturesDirectory.appendingPathComponent("\(name).shazamsignature")
        return try loadSignature(from: fileURL)
    }
    
    /// 저장된 모든 시그니처 파일 목록
    func listSavedSignatures() -> [SignatureFile] {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: signaturesDirectory,
            includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
            options: .skipsHiddenFiles
        ) else {
            return []
        }
        
        return contents
            .filter { $0.pathExtension == "shazamsignature" }
            .compactMap { url -> SignatureFile? in
                let resourceValues = try? url.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
                return SignatureFile(
                    url: url,
                    name: url.deletingPathExtension().lastPathComponent,
                    createdAt: resourceValues?.creationDate ?? Date(),
                    fileSize: resourceValues?.fileSize ?? 0
                )
            }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    /// 시그니처 파일 삭제
    func deleteSignature(named name: String) throws {
        let fileURL = signaturesDirectory.appendingPathComponent("\(name).shazamsignature")
        try FileManager.default.removeItem(at: fileURL)
    }
    
    /// 시그니처 파일 삭제
    func deleteSignature(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
    
    // MARK: - 시그니처 비교
    /// 두 시그니처 비교 (데이터 크기 기준 간단 비교)
    func compareSignatures(_ sig1: SHSignature, _ sig2: SHSignature) -> SignatureComparison {
        let data1 = sig1.dataRepresentation
        let data2 = sig2.dataRepresentation
        
        return SignatureComparison(
            signature1Size: data1.count,
            signature2Size: data2.count,
            duration1: sig1.duration,
            duration2: sig2.duration,
            areSameDuration: abs(sig1.duration - sig2.duration) < 0.1
        )
    }
    
    // MARK: - 유틸리티
    /// 시그니처 정보 추출
    func getSignatureInfo(_ signature: SHSignature) -> SignatureInfo {
        return SignatureInfo(
            duration: signature.duration,
            dataSize: signature.dataRepresentation.count,
            createdAt: Date()
        )
    }
    
    /// 상태 초기화
    func reset() {
        state = .idle
        generationProgress = 0
        lastGeneratedSignature = nil
    }
}

// MARK: - 보조 타입
/// 저장된 시그니처 파일 정보
struct SignatureFile: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let createdAt: Date
    let fileSize: Int
    
    /// 파일 크기 포맷팅
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSize))
    }
}

/// 시그니처 정보
struct SignatureInfo: Hashable {
    let duration: TimeInterval    // 시그니처 지속 시간
    let dataSize: Int             // 데이터 크기 (바이트)
    let createdAt: Date           // 생성 시간
    
    /// 지속 시간 포맷팅
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// 데이터 크기 포맷팅
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(dataSize))
    }
}

/// 시그니처 비교 결과
struct SignatureComparison {
    let signature1Size: Int
    let signature2Size: Int
    let duration1: TimeInterval
    let duration2: TimeInterval
    let areSameDuration: Bool
}

// MARK: - SHSignature 확장
extension SHSignature {
    /// 시그니처 지속 시간 (읽기 전용, 내부 계산)
    /// 참고: SHSignature의 실제 duration은 내부적으로 계산됨
    var duration: TimeInterval {
        // dataRepresentation 크기를 기반으로 대략적인 지속 시간 추정
        // 실제로는 ShazamKit 내부에서 관리됨
        let bytesPerSecond = 8000.0 // 대략적인 값
        return Double(dataRepresentation.count) / bytesPerSecond
    }
}

// MARK: - 레코딩 헬퍼
extension SignatureManager {
    /// 녹음된 오디오에서 시그니처 생성을 위한 헬퍼
    /// 사용자가 녹음한 오디오를 시그니처로 변환
    func createSignatureFromRecording(
        audioURL: URL,
        title: String,
        artist: String,
        additionalMetadata: [SHMediaItemProperty: Any] = [:]
    ) async throws -> (signature: SHSignature, mediaItem: SHMediaItem) {
        // 시그니처 생성
        let signature = try await generateSignature(from: audioURL)
        
        // 메타데이터 설정
        var properties: [SHMediaItemProperty: Any] = [
            .title: title,
            .artist: artist
        ]
        
        // 추가 메타데이터 병합
        for (key, value) in additionalMetadata {
            properties[key] = value
        }
        
        // SHMediaItem 생성
        let mediaItem = SHMediaItem(properties: properties)
        
        return (signature, mediaItem)
    }
}
