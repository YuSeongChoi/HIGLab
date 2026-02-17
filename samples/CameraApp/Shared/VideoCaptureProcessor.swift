import AVFoundation
import UIKit
import Photos

// MARK: - 비디오 캡처 프로세서
// AVCaptureMovieFileOutput과 AVAssetWriter를 사용한 고급 비디오 녹화를 담당합니다.
// HIG: 녹화 상태를 명확히 표시하고, 저장 공간 부족 등의 문제를 사전에 알립니다.

// MARK: - 비디오 녹화 설정

/// 비디오 녹화 설정
struct VideoRecordingConfiguration {
    /// 해상도
    var resolution: VideoResolution = .hd1080p
    
    /// 프레임 레이트
    var frameRate: VideoFrameRate = .fps30
    
    /// 오디오 녹음 여부
    var isAudioEnabled: Bool = true
    
    /// 손떨림 보정
    var stabilizationMode: AVCaptureVideoStabilizationMode = .auto
    
    /// 비디오 코덱
    var videoCodec: AVVideoCodecType = .hevc
    
    /// 비트레이트 (bps)
    var videoBitRate: Int = 10_000_000  // 10 Mbps
    
    /// 오디오 비트레이트
    var audioBitRate: Int = 128_000  // 128 kbps
    
    /// 최대 녹화 시간 (초, 0 = 무제한)
    var maxDuration: TimeInterval = 0
    
    /// 포토 라이브러리에 저장
    var saveToPhotoLibrary: Bool = true
}

// MARK: - 비디오 녹화 프로세서 (MovieFileOutput 기반)

/// MovieFileOutput을 사용한 비디오 녹화
@MainActor
final class VideoRecordingProcessor: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// 녹화 상태
    @Published private(set) var recordingState: RecordingState = .idle
    
    /// 현재 녹화 시간 (초)
    @Published private(set) var recordingDuration: TimeInterval = 0
    
    /// 녹화 파일 크기 (bytes)
    @Published private(set) var recordingFileSize: Int64 = 0
    
    // MARK: - Properties
    
    /// MovieFileOutput
    private let movieFileOutput = AVCaptureMovieFileOutput()
    
    /// 현재 녹화 설정
    private var configuration = VideoRecordingConfiguration()
    
    /// 녹화 시작 시간
    private var recordingStartTime: Date?
    
    /// 녹화 타이머
    private var durationTimer: Timer?
    
    /// 완료 핸들러
    private var completionHandler: ((Result<CapturedMedia, CameraError>) -> Void)?
    
    /// 현재 녹화 파일 URL
    private var currentRecordingURL: URL?
    
    // MARK: - Public Properties
    
    /// AVCaptureMovieFileOutput 반환 (세션에 추가용)
    var output: AVCaptureMovieFileOutput { movieFileOutput }
    
    /// 녹화 중 여부
    var isRecording: Bool { recordingState.isRecording }
    
    // MARK: - Public Methods
    
    /// 세션에 출력 추가
    /// - Parameter session: AVCaptureSession
    func configureOutput(for session: AVCaptureSession) -> Bool {
        guard session.canAddOutput(movieFileOutput) else {
            print("⚠️ MovieFileOutput 추가 불가")
            return false
        }
        
        session.addOutput(movieFileOutput)
        
        // 연결 설정
        if let connection = movieFileOutput.connection(with: .video) {
            // 손떨림 보정
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = configuration.stabilizationMode
            }
            
            // 비디오 방향
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
        }
        
        return true
    }
    
    /// 녹화 시작
    /// - Parameters:
    ///   - configuration: 녹화 설정
    ///   - completion: 완료 핸들러
    func startRecording(
        configuration: VideoRecordingConfiguration = VideoRecordingConfiguration(),
        completion: @escaping (Result<CapturedMedia, CameraError>) -> Void
    ) {
        guard recordingState == .idle else {
            completion(.failure(.recordingError("이미 녹화 중입니다")))
            return
        }
        
        self.configuration = configuration
        self.completionHandler = completion
        
        // 파일 URL 생성
        let outputURL = createOutputURL()
        currentRecordingURL = outputURL
        
        // 최대 녹화 시간 설정
        if configuration.maxDuration > 0 {
            movieFileOutput.maxRecordedDuration = CMTime(
                seconds: configuration.maxDuration,
                preferredTimescale: 600
            )
        } else {
            movieFileOutput.maxRecordedDuration = .invalid
        }
        
        // 녹화 시작
        recordingState = .preparing
        movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)
        
        print("🎬 녹화 준비 중...")
    }
    
    /// 녹화 중지
    func stopRecording() {
        guard movieFileOutput.isRecording else { return }
        
        recordingState = .finishing
        movieFileOutput.stopRecording()
        
        stopDurationTimer()
        print("🎬 녹화 중지 요청")
    }
    
    /// 녹화 일시 정지 (iOS 18+)
    @available(iOS 18.0, *)
    func pauseRecording() {
        guard movieFileOutput.isRecording else { return }
        
        movieFileOutput.pauseRecording()
        recordingState = .paused
        stopDurationTimer()
        
        print("🎬 녹화 일시 정지")
    }
    
    /// 녹화 재개 (iOS 18+)
    @available(iOS 18.0, *)
    func resumeRecording() {
        guard recordingState == .paused else { return }
        
        movieFileOutput.resumeRecording()
        recordingState = .recording
        startDurationTimer()
        
        print("🎬 녹화 재개")
    }
    
    // MARK: - Private Methods
    
    /// 출력 파일 URL 생성
    private func createOutputURL() -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = formatter.string(from: Date())
        
        let fileName = "Video_\(dateString).mov"
        let tempDirectory = FileManager.default.temporaryDirectory
        
        return tempDirectory.appendingPathComponent(fileName)
    }
    
    /// 녹화 시간 타이머 시작
    private func startDurationTimer() {
        recordingStartTime = Date()
        recordingDuration = 0
        
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateDuration()
            }
        }
    }
    
    /// 녹화 시간 업데이트
    private func updateDuration() {
        guard let startTime = recordingStartTime else { return }
        recordingDuration = Date().timeIntervalSince(startTime)
        recordingFileSize = movieFileOutput.recordedFileSize
    }
    
    /// 녹화 시간 타이머 중지
    private func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }
    
    /// 포토 라이브러리에 저장
    private func saveToPhotoLibrary(url: URL, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else {
                print("⚠️ 비디오 저장 권한 없음")
                completion(false)
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { success, error in
                if success {
                    print("✅ 비디오가 라이브러리에 저장됨")
                } else if let error = error {
                    print("⚠️ 비디오 저장 실패: \(error.localizedDescription)")
                }
                completion(success)
            }
        }
    }
    
    /// 비디오에서 썸네일 추출
    private func extractThumbnail(from url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0, preferredTimescale: 600)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("⚠️ 썸네일 추출 실패: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension VideoRecordingProcessor: AVCaptureFileOutputRecordingDelegate {
    
    nonisolated func fileOutput(
        _ output: AVCaptureFileOutput,
        didStartRecordingTo fileURL: URL,
        from connections: [AVCaptureConnection]
    ) {
        Task { @MainActor in
            recordingState = .recording
            startDurationTimer()
            print("🎬 녹화 시작됨: \(fileURL.lastPathComponent)")
        }
    }
    
    nonisolated func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        Task { @MainActor in
            stopDurationTimer()
            recordingState = .finished
            
            // 오류 확인
            if let error = error {
                // 사용자가 중지한 경우가 아닌 실제 오류인지 확인
                let nsError = error as NSError
                if nsError.domain == AVFoundationErrorDomain {
                    let errorCode = AVError.Code(rawValue: nsError.code)
                    if errorCode != .maximumFileSizeReached && errorCode != .maximumDurationReached {
                        completionHandler?(.failure(.recordingError(error.localizedDescription)))
                        recordingState = .idle
                        return
                    }
                }
            }
            
            // 썸네일 추출
            let thumbnail = extractThumbnail(from: outputFileURL) ?? UIImage(systemName: "video.fill")!
            
            // 미디어 생성
            let media = CapturedMedia(
                type: .video,
                image: thumbnail,
                capturedAt: Date(),
                fileURL: outputFileURL,
                duration: recordingDuration
            )
            
            // 포토 라이브러리에 저장
            if configuration.saveToPhotoLibrary {
                saveToPhotoLibrary(url: outputFileURL) { _ in }
            }
            
            completionHandler?(.success(media))
            
            print("🎬 녹화 완료: \(recordingDuration)초, \(recordingFileSize) bytes")
            
            recordingState = .idle
            recordingDuration = 0
            recordingFileSize = 0
        }
    }
}

// MARK: - 고급 비디오 녹화 프로세서 (AVAssetWriter 기반)

/// AVAssetWriter를 사용한 고급 비디오 녹화
/// 프레임 단위 제어, 실시간 필터 적용 등이 필요할 때 사용
@MainActor
final class AdvancedVideoRecordingProcessor: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 녹화 상태
    @Published private(set) var recordingState: RecordingState = .idle
    
    /// 현재 녹화 시간
    @Published private(set) var recordingDuration: TimeInterval = 0
    
    // MARK: - Properties
    
    /// Asset Writer
    private var assetWriter: AVAssetWriter?
    
    /// 비디오 입력
    private var videoInput: AVAssetWriterInput?
    
    /// 오디오 입력
    private var audioInput: AVAssetWriterInput?
    
    /// 픽셀 버퍼 어댑터
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    /// 녹화 설정
    private var configuration = VideoRecordingConfiguration()
    
    /// 현재 출력 URL
    private var outputURL: URL?
    
    /// 시작 타임스탬프
    private var startTimestamp: CMTime?
    
    /// 마지막 비디오 타임스탬프
    private var lastVideoTimestamp: CMTime?
    
    /// 마지막 오디오 타임스탬프
    private var lastAudioTimestamp: CMTime?
    
    /// 녹화 큐
    private let recordingQueue = DispatchQueue(label: "com.cameraapp.recording", qos: .userInitiated)
    
    // MARK: - Public Methods
    
    /// 녹화 준비
    /// - Parameter configuration: 녹화 설정
    func prepareRecording(with configuration: VideoRecordingConfiguration) throws {
        self.configuration = configuration
        
        // 출력 URL 생성
        let url = createOutputURL()
        self.outputURL = url
        
        // 기존 파일 삭제
        try? FileManager.default.removeItem(at: url)
        
        // Asset Writer 생성
        let writer = try AVAssetWriter(outputURL: url, fileType: .mov)
        
        // 비디오 설정
        let videoSettings = createVideoSettings()
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput.expectsMediaDataInRealTime = true
        videoInput.transform = CGAffineTransform(rotationAngle: .pi / 2)  // 세로 모드
        
        // 픽셀 버퍼 어댑터 (필터 적용 시 필요)
        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: videoWidth,
            kCVPixelBufferHeightKey as String: videoHeight
        ]
        
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoInput,
            sourcePixelBufferAttributes: sourcePixelBufferAttributes
        )
        
        // 오디오 설정
        var audioInput: AVAssetWriterInput?
        if configuration.isAudioEnabled {
            let audioSettings = createAudioSettings()
            audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            audioInput?.expectsMediaDataInRealTime = true
        }
        
        // Writer에 입력 추가
        if writer.canAdd(videoInput) {
            writer.add(videoInput)
        }
        
        if let audioInput = audioInput, writer.canAdd(audioInput) {
            writer.add(audioInput)
        }
        
        self.assetWriter = writer
        self.videoInput = videoInput
        self.audioInput = audioInput
        self.pixelBufferAdaptor = adaptor
        
        print("🎬 AVAssetWriter 준비 완료")
    }
    
    /// 녹화 시작
    func startRecording() {
        guard let writer = assetWriter else { return }
        
        recordingState = .recording
        writer.startWriting()
        
        print("🎬 AVAssetWriter 녹화 시작")
    }
    
    /// 비디오 프레임 추가
    /// - Parameters:
    ///   - sampleBuffer: 비디오 샘플 버퍼
    func appendVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard recordingState == .recording,
              let videoInput = videoInput,
              videoInput.isReadyForMoreMediaData else { return }
        
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        // 시작 타임스탬프 설정
        if startTimestamp == nil {
            startTimestamp = timestamp
            assetWriter?.startSession(atSourceTime: timestamp)
        }
        
        recordingQueue.async { [weak self] in
            if videoInput.isReadyForMoreMediaData {
                videoInput.append(sampleBuffer)
                self?.lastVideoTimestamp = timestamp
            }
        }
        
        // 녹화 시간 업데이트
        if let start = startTimestamp {
            let duration = CMTimeSubtract(timestamp, start)
            Task { @MainActor in
                self.recordingDuration = CMTimeGetSeconds(duration)
            }
        }
    }
    
    /// 오디오 샘플 추가
    /// - Parameter sampleBuffer: 오디오 샘플 버퍼
    func appendAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard recordingState == .recording,
              let audioInput = audioInput,
              audioInput.isReadyForMoreMediaData,
              startTimestamp != nil else { return }
        
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        recordingQueue.async {
            if audioInput.isReadyForMoreMediaData {
                audioInput.append(sampleBuffer)
            }
        }
        
        lastAudioTimestamp = timestamp
    }
    
    /// 녹화 종료
    /// - Parameter completion: 완료 핸들러
    func stopRecording(completion: @escaping (Result<URL, CameraError>) -> Void) {
        guard let writer = assetWriter else {
            completion(.failure(.recordingError("Writer가 없습니다")))
            return
        }
        
        recordingState = .finishing
        
        videoInput?.markAsFinished()
        audioInput?.markAsFinished()
        
        writer.finishWriting { [weak self] in
            Task { @MainActor in
                guard let self = self else { return }
                
                if writer.status == .completed, let url = self.outputURL {
                    self.recordingState = .finished
                    print("🎬 AVAssetWriter 녹화 완료")
                    completion(.success(url))
                } else if let error = writer.error {
                    self.recordingState = .idle
                    completion(.failure(.recordingError(error.localizedDescription)))
                } else {
                    self.recordingState = .idle
                    completion(.failure(.recordingError("알 수 없는 오류")))
                }
                
                self.cleanup()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func createOutputURL() -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = formatter.string(from: Date())
        
        let fileName = "Video_\(dateString).mov"
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }
    
    private var videoWidth: Int {
        switch configuration.resolution {
        case .hd720p: 1280
        case .hd1080p: 1920
        case .uhd4k: 3840
        }
    }
    
    private var videoHeight: Int {
        switch configuration.resolution {
        case .hd720p: 720
        case .hd1080p: 1080
        case .uhd4k: 2160
        }
    }
    
    private func createVideoSettings() -> [String: Any] {
        return [
            AVVideoCodecKey: configuration.videoCodec,
            AVVideoWidthKey: videoWidth,
            AVVideoHeightKey: videoHeight,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: configuration.videoBitRate,
                AVVideoExpectedSourceFrameRateKey: configuration.frameRate.rawValue,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]
    }
    
    private func createAudioSettings() -> [String: Any] {
        return [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: configuration.audioBitRate
        ]
    }
    
    private func cleanup() {
        assetWriter = nil
        videoInput = nil
        audioInput = nil
        pixelBufferAdaptor = nil
        startTimestamp = nil
        lastVideoTimestamp = nil
        lastAudioTimestamp = nil
        recordingState = .idle
        recordingDuration = 0
    }
}

// MARK: - 녹화 시간 포맷터

extension VideoRecordingProcessor {
    /// 녹화 시간을 표시용 문자열로 변환
    var formattedDuration: String {
        formatDuration(recordingDuration)
    }
}

extension AdvancedVideoRecordingProcessor {
    /// 녹화 시간을 표시용 문자열로 변환
    var formattedDuration: String {
        formatDuration(recordingDuration)
    }
}

/// 시간 포맷 헬퍼
private func formatDuration(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    let seconds = Int(duration) % 60
    
    if hours > 0 {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    } else {
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
