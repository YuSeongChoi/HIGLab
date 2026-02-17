import Foundation
import Vision
import CoreImage

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Vision 분석기
// 텍스트 인식, 얼굴 감지, 포즈 감지를 통합한 Vision 프레임워크 활용 클래스
// VNRecognizeTextRequest, VNDetectFaceRectanglesRequest, VNDetectHumanBodyPoseRequest 활용

@MainActor
final class VisionAnalyzer: ObservableObject {
    
    // MARK: - Published 프로퍼티
    /// 분석 상태
    @Published private(set) var state: AnalysisState = .idle
    
    /// 인식된 텍스트들
    @Published private(set) var recognizedTexts: [RecognizedText] = []
    
    /// 감지된 얼굴들
    @Published private(set) var detectedFaces: [DetectedFace] = []
    
    /// 감지된 포즈들
    @Published private(set) var detectedPoses: [DetectedPose] = []
    
    /// 마지막 분석 시간 (ms)
    @Published private(set) var lastAnalysisTimeMs: Double = 0
    
    // MARK: - 텍스트 인식 설정
    /// 텍스트 인식 레벨 (빠름 vs 정확함)
    var textRecognitionLevel: VNRequestTextRecognitionLevel = .accurate
    
    /// 인식할 언어들
    var recognitionLanguages: [String] = ["ko-KR", "en-US"]
    
    /// 최소 텍스트 높이 (정규화된 값)
    var minimumTextHeight: Float = 0.01
    
    // MARK: - 얼굴 감지 설정
    /// 얼굴 랜드마크 감지 여부
    var detectFaceLandmarks: Bool = true
    
    // MARK: - 초기화
    init() {}
    
    // MARK: - 텍스트 인식
    /// 이미지에서 텍스트 인식
    /// - Parameter image: 분석할 이미지
    /// - Returns: 인식된 텍스트 배열
    func recognizeText(in image: PlatformImage) async throws -> [RecognizedText] {
        state = .analyzing
        
        guard let cgImage = cgImage(from: image) else {
            state = .failure("이미지 변환 실패")
            throw VisionAnalyzerError.imageConversionFailed
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let texts = try await performTextRecognition(cgImage: cgImage)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastAnalysisTimeMs = (endTime - startTime) * 1000
        
        recognizedTexts = texts
        state = .idle
        
        return texts
    }
    
    /// CIImage에서 텍스트 인식 (실시간용)
    func recognizeText(in ciImage: CIImage) async throws -> [RecognizedText] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let texts = try await performTextRecognition(ciImage: ciImage)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastAnalysisTimeMs = (endTime - startTime) * 1000
        
        recognizedTexts = texts
        
        return texts
    }
    
    /// 텍스트 인식 수행 (CGImage)
    private func performTextRecognition(cgImage: CGImage) async throws -> [RecognizedText] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(
                        throwing: VisionAnalyzerError.recognitionFailed(error.localizedDescription)
                    )
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let texts = observations.compactMap { observation -> RecognizedText? in
                    guard let topCandidate = observation.topCandidates(1).first else {
                        return nil
                    }
                    
                    return RecognizedText(
                        text: topCandidate.string,
                        confidence: topCandidate.confidence,
                        boundingBox: observation.boundingBox
                    )
                }
                
                continuation.resume(returning: texts)
            }
            
            // 텍스트 인식 설정
            request.recognitionLevel = textRecognitionLevel
            request.recognitionLanguages = recognitionLanguages
            request.usesLanguageCorrection = true
            request.minimumTextHeight = minimumTextHeight
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(
                    throwing: VisionAnalyzerError.recognitionFailed(error.localizedDescription)
                )
            }
        }
    }
    
    /// 텍스트 인식 수행 (CIImage)
    private func performTextRecognition(ciImage: CIImage) async throws -> [RecognizedText] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(
                        throwing: VisionAnalyzerError.recognitionFailed(error.localizedDescription)
                    )
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let texts = observations.compactMap { observation -> RecognizedText? in
                    guard let topCandidate = observation.topCandidates(1).first else {
                        return nil
                    }
                    
                    return RecognizedText(
                        text: topCandidate.string,
                        confidence: topCandidate.confidence,
                        boundingBox: observation.boundingBox
                    )
                }
                
                continuation.resume(returning: texts)
            }
            
            request.recognitionLevel = textRecognitionLevel
            request.recognitionLanguages = recognitionLanguages
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(
                    throwing: VisionAnalyzerError.recognitionFailed(error.localizedDescription)
                )
            }
        }
    }
    
    // MARK: - 얼굴 감지
    /// 이미지에서 얼굴 감지
    /// - Parameter image: 분석할 이미지
    /// - Returns: 감지된 얼굴 배열
    func detectFaces(in image: PlatformImage) async throws -> [DetectedFace] {
        state = .analyzing
        
        guard let cgImage = cgImage(from: image) else {
            state = .failure("이미지 변환 실패")
            throw VisionAnalyzerError.imageConversionFailed
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let faces = try await performFaceDetection(cgImage: cgImage)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastAnalysisTimeMs = (endTime - startTime) * 1000
        
        detectedFaces = faces
        state = .idle
        
        return faces
    }
    
    /// CIImage에서 얼굴 감지 (실시간용)
    func detectFaces(in ciImage: CIImage) async throws -> [DetectedFace] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let faces = try await performFaceDetection(ciImage: ciImage)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastAnalysisTimeMs = (endTime - startTime) * 1000
        
        detectedFaces = faces
        
        return faces
    }
    
    /// 얼굴 감지 수행 (CGImage)
    private func performFaceDetection(cgImage: CGImage) async throws -> [DetectedFace] {
        return try await withCheckedThrowingContinuation { continuation in
            // 랜드마크 포함 감지 또는 기본 감지
            let request: VNImageBasedRequest
            
            if detectFaceLandmarks {
                request = VNDetectFaceLandmarksRequest { request, error in
                    self.handleFaceDetectionResult(request: request, error: error, continuation: continuation)
                }
            } else {
                request = VNDetectFaceRectanglesRequest { request, error in
                    self.handleFaceDetectionResult(request: request, error: error, continuation: continuation)
                }
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(
                    throwing: VisionAnalyzerError.detectionFailed(error.localizedDescription)
                )
            }
        }
    }
    
    /// 얼굴 감지 수행 (CIImage)
    private func performFaceDetection(ciImage: CIImage) async throws -> [DetectedFace] {
        return try await withCheckedThrowingContinuation { continuation in
            let request: VNImageBasedRequest
            
            if detectFaceLandmarks {
                request = VNDetectFaceLandmarksRequest { request, error in
                    self.handleFaceDetectionResult(request: request, error: error, continuation: continuation)
                }
            } else {
                request = VNDetectFaceRectanglesRequest { request, error in
                    self.handleFaceDetectionResult(request: request, error: error, continuation: continuation)
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(
                    throwing: VisionAnalyzerError.detectionFailed(error.localizedDescription)
                )
            }
        }
    }
    
    /// 얼굴 감지 결과 처리
    private func handleFaceDetectionResult(
        request: VNRequest,
        error: Error?,
        continuation: CheckedContinuation<[DetectedFace], Error>
    ) {
        if let error = error {
            continuation.resume(
                throwing: VisionAnalyzerError.detectionFailed(error.localizedDescription)
            )
            return
        }
        
        guard let observations = request.results as? [VNFaceObservation] else {
            continuation.resume(returning: [])
            return
        }
        
        let faces = observations.map { DetectedFace(from: $0) }
        continuation.resume(returning: faces)
    }
    
    // MARK: - 포즈 감지
    /// 이미지에서 인체 포즈 감지
    /// - Parameter image: 분석할 이미지
    /// - Returns: 감지된 포즈 배열
    func detectPoses(in image: PlatformImage) async throws -> [DetectedPose] {
        state = .analyzing
        
        guard let cgImage = cgImage(from: image) else {
            state = .failure("이미지 변환 실패")
            throw VisionAnalyzerError.imageConversionFailed
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let poses = try await performPoseDetection(cgImage: cgImage)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastAnalysisTimeMs = (endTime - startTime) * 1000
        
        detectedPoses = poses
        state = .idle
        
        return poses
    }
    
    /// CIImage에서 포즈 감지 (실시간용)
    func detectPoses(in ciImage: CIImage) async throws -> [DetectedPose] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let poses = try await performPoseDetection(ciImage: ciImage)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastAnalysisTimeMs = (endTime - startTime) * 1000
        
        detectedPoses = poses
        
        return poses
    }
    
    /// 포즈 감지 수행 (CGImage)
    private func performPoseDetection(cgImage: CGImage) async throws -> [DetectedPose] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanBodyPoseRequest { request, error in
                if let error = error {
                    continuation.resume(
                        throwing: VisionAnalyzerError.detectionFailed(error.localizedDescription)
                    )
                    return
                }
                
                guard let observations = request.results as? [VNHumanBodyPoseObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let poses = observations.compactMap { DetectedPose(from: $0) }
                continuation.resume(returning: poses)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(
                    throwing: VisionAnalyzerError.detectionFailed(error.localizedDescription)
                )
            }
        }
    }
    
    /// 포즈 감지 수행 (CIImage)
    private func performPoseDetection(ciImage: CIImage) async throws -> [DetectedPose] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanBodyPoseRequest { request, error in
                if let error = error {
                    continuation.resume(
                        throwing: VisionAnalyzerError.detectionFailed(error.localizedDescription)
                    )
                    return
                }
                
                guard let observations = request.results as? [VNHumanBodyPoseObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let poses = observations.compactMap { DetectedPose(from: $0) }
                continuation.resume(returning: poses)
            }
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(
                    throwing: VisionAnalyzerError.detectionFailed(error.localizedDescription)
                )
            }
        }
    }
    
    // MARK: - 통합 분석
    /// 모든 분석 동시 수행 (텍스트 + 얼굴 + 포즈)
    /// - Parameter image: 분석할 이미지
    /// - Returns: 통합 분석 결과
    func analyzeAll(in image: PlatformImage) async throws -> AnalysisResult {
        state = .analyzing
        
        guard let cgImage = cgImage(from: image) else {
            state = .failure("이미지 변환 실패")
            throw VisionAnalyzerError.imageConversionFailed
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 병렬로 모든 분석 수행
        async let textsTask = performTextRecognition(cgImage: cgImage)
        async let facesTask = performFaceDetection(cgImage: cgImage)
        async let posesTask = performPoseDetection(cgImage: cgImage)
        
        let texts = try await textsTask
        let faces = try await facesTask
        let poses = try await posesTask
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastAnalysisTimeMs = (endTime - startTime) * 1000
        
        recognizedTexts = texts
        detectedFaces = faces
        detectedPoses = poses
        
        state = .idle
        
        return AnalysisResult(
            texts: texts,
            faces: faces,
            poses: poses,
            analysisTimeMs: lastAnalysisTimeMs
        )
    }
    
    /// 상태 초기화
    func reset() {
        state = .idle
        recognizedTexts = []
        detectedFaces = []
        detectedPoses = []
        lastAnalysisTimeMs = 0
    }
    
    // MARK: - Private 헬퍼
    /// 플랫폼 이미지를 CGImage로 변환
    private func cgImage(from image: PlatformImage) -> CGImage? {
        #if canImport(UIKit)
        return image.cgImage
        #elseif canImport(AppKit)
        var rect = NSRect(origin: .zero, size: image.size)
        return image.cgImage(forProposedRect: &rect, context: nil, hints: nil)
        #endif
    }
}

// MARK: - 분석 상태
enum AnalysisState: Equatable {
    case idle
    case analyzing
    case failure(String)
    
    var description: String {
        switch self {
        case .idle:
            return "준비됨"
        case .analyzing:
            return "분석 중..."
        case .failure(let message):
            return "오류: \(message)"
        }
    }
}

// MARK: - 통합 분석 결과
struct AnalysisResult {
    let texts: [RecognizedText]
    let faces: [DetectedFace]
    let poses: [DetectedPose]
    let analysisTimeMs: Double
    
    /// 텍스트 전체 연결
    var fullText: String {
        texts.map { $0.text }.joined(separator: "\n")
    }
    
    /// 요약
    var summary: String {
        """
        텍스트: \(texts.count)개 영역
        얼굴: \(faces.count)명
        포즈: \(poses.count)명
        분석 시간: \(String(format: "%.1f", analysisTimeMs))ms
        """
    }
}

// MARK: - Vision 분석기 오류
enum VisionAnalyzerError: LocalizedError {
    case imageConversionFailed
    case recognitionFailed(String)
    case detectionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "이미지를 변환할 수 없습니다"
        case .recognitionFailed(let reason):
            return "인식 실패: \(reason)"
        case .detectionFailed(let reason):
            return "감지 실패: \(reason)"
        }
    }
}
