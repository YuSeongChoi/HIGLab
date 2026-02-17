import Foundation
import CoreML
import Vision
import CoreImage

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 객체 탐지기
// Vision + CoreML을 사용한 실시간 객체 탐지
// VNRecognizedObjectObservation, VNDetectRectanglesRequest 활용

@MainActor
final class ObjectDetector: ObservableObject {
    
    // MARK: - Published 프로퍼티
    /// 탐지 상태
    @Published private(set) var state: DetectionState = .idle
    
    /// 탐지된 객체들
    @Published private(set) var detectedObjects: [DetectedObject] = []
    
    /// 마지막 추론 시간 (ms)
    @Published private(set) var lastInferenceTimeMs: Double = 0
    
    // MARK: - Private 프로퍼티
    /// Vision CoreML 모델
    private var visionModel: VNCoreMLModel?
    
    /// 모델 관리자
    private let modelManager = MLModelManager.shared
    
    // MARK: - 설정
    /// 최소 신뢰도 임계값
    var minimumConfidence: Float = 0.5
    
    /// 최대 객체 수
    var maxDetections: Int = 20
    
    /// NMS(Non-Maximum Suppression) IOU 임계값
    var nmsThreshold: Float = 0.5
    
    // MARK: - 초기화
    init() {}
    
    // MARK: - 모델 준비
    /// 객체 탐지 모델 준비
    /// - Parameters:
    ///   - modelType: 사용할 모델 타입 (YOLO 계열)
    ///   - computeUnits: 연산 장치
    func prepareModel(
        _ modelType: MLModelType = .yoloV3Tiny,
        computeUnits: ComputeUnitOption = .all
    ) async throws {
        state = .loading
        
        guard let mlModel = await modelManager.loadModel(
            modelType,
            computeUnits: computeUnits
        ) else {
            state = .failure("객체 탐지 모델을 로드할 수 없습니다")
            throw DetectorError.modelLoadFailed
        }
        
        do {
            visionModel = try VNCoreMLModel(for: mlModel)
            state = .idle
        } catch {
            state = .failure("Vision 모델 생성 실패")
            throw DetectorError.visionModelCreationFailed
        }
    }
    
    // MARK: - 객체 탐지
    /// 이미지에서 객체 탐지 수행
    /// - Parameter image: 분석할 이미지
    /// - Returns: 탐지된 객체 배열
    func detect(in image: PlatformImage) async throws -> [DetectedObject] {
        if visionModel == nil {
            try await prepareModel()
        }
        
        guard let visionModel = visionModel else {
            throw DetectorError.modelNotReady
        }
        
        state = .detecting
        
        guard let cgImage = cgImage(from: image) else {
            state = .failure("이미지 변환 실패")
            throw DetectorError.imageConversionFailed
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let objects = try await performDetection(
            model: visionModel,
            cgImage: cgImage
        )
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastInferenceTimeMs = (endTime - startTime) * 1000
        
        return objects
    }
    
    /// CIImage에서 객체 탐지 (실시간 카메라용)
    /// - Parameter ciImage: 분석할 CIImage
    /// - Returns: 탐지된 객체 배열
    func detect(in ciImage: CIImage) async throws -> [DetectedObject] {
        if visionModel == nil {
            try await prepareModel()
        }
        
        guard let visionModel = visionModel else {
            throw DetectorError.modelNotReady
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let objects = try await performDetection(
            model: visionModel,
            ciImage: ciImage
        )
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastInferenceTimeMs = (endTime - startTime) * 1000
        
        return objects
    }
    
    /// 상태 초기화
    func reset() {
        state = .idle
        detectedObjects = []
        lastInferenceTimeMs = 0
    }
    
    // MARK: - Private 헬퍼
    /// Vision 요청 수행 (CGImage)
    private func performDetection(
        model: VNCoreMLModel,
        cgImage: CGImage
    ) async throws -> [DetectedObject] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = createDetectionRequest(
                model: model,
                continuation: continuation
            )
            
            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                orientation: .up,
                options: [:]
            )
            
            executeRequest(request, with: handler, continuation: continuation)
        }
    }
    
    /// Vision 요청 수행 (CIImage)
    private func performDetection(
        model: VNCoreMLModel,
        ciImage: CIImage
    ) async throws -> [DetectedObject] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = createDetectionRequest(
                model: model,
                continuation: continuation
            )
            
            let handler = VNImageRequestHandler(
                ciImage: ciImage,
                orientation: .up,
                options: [:]
            )
            
            executeRequest(request, with: handler, continuation: continuation)
        }
    }
    
    /// 탐지 요청 생성
    private func createDetectionRequest(
        model: VNCoreMLModel,
        continuation: CheckedContinuation<[DetectedObject], Error>
    ) -> VNCoreMLRequest {
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                Task { @MainActor in
                    self.state = .failure(error.localizedDescription)
                }
                continuation.resume(
                    throwing: DetectorError.detectionFailed(error.localizedDescription)
                )
                return
            }
            
            // 결과 처리
            guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                Task { @MainActor in
                    self.detectedObjects = []
                    self.state = .success([])
                }
                continuation.resume(returning: [])
                return
            }
            
            // 객체 변환 및 필터링
            var objects = observations
                .compactMap { DetectedObject(from: $0, minimumConfidence: self.minimumConfidence) }
            
            // NMS 적용
            objects = self.applyNMS(objects)
            
            // 최대 개수 제한
            objects = Array(objects.prefix(self.maxDetections))
            
            Task { @MainActor in
                self.detectedObjects = objects
                self.state = .success(objects)
            }
            
            continuation.resume(returning: objects)
        }
        
        request.imageCropAndScaleOption = .scaleFill
        
        return request
    }
    
    /// 요청 실행
    private func executeRequest(
        _ request: VNCoreMLRequest,
        with handler: VNImageRequestHandler,
        continuation: CheckedContinuation<[DetectedObject], Error>
    ) {
        do {
            try handler.perform([request])
        } catch {
            Task { @MainActor in
                self.state = .failure(error.localizedDescription)
            }
            continuation.resume(
                throwing: DetectorError.detectionFailed(error.localizedDescription)
            )
        }
    }
    
    /// Non-Maximum Suppression 적용
    /// 겹치는 바운딩 박스 중 신뢰도가 가장 높은 것만 유지
    private func applyNMS(_ objects: [DetectedObject]) -> [DetectedObject] {
        guard !objects.isEmpty else { return [] }
        
        // 신뢰도 순으로 정렬
        var sorted = objects.sorted { $0.confidence > $1.confidence }
        var result: [DetectedObject] = []
        
        while !sorted.isEmpty {
            let best = sorted.removeFirst()
            result.append(best)
            
            // 겹치는 박스 제거
            sorted = sorted.filter { candidate in
                let iou = calculateIOU(best.boundingBox, candidate.boundingBox)
                return iou < nmsThreshold || best.label != candidate.label
            }
        }
        
        return result
    }
    
    /// IOU (Intersection over Union) 계산
    private func calculateIOU(_ box1: CGRect, _ box2: CGRect) -> Float {
        let intersection = box1.intersection(box2)
        
        guard !intersection.isNull else { return 0 }
        
        let intersectionArea = intersection.width * intersection.height
        let unionArea = box1.width * box1.height +
                        box2.width * box2.height -
                        intersectionArea
        
        guard unionArea > 0 else { return 0 }
        
        return Float(intersectionArea / unionArea)
    }
    
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

// MARK: - 탐지 상태
enum DetectionState: Equatable {
    case idle
    case loading
    case detecting
    case success([DetectedObject])
    case failure(String)
    
    var description: String {
        switch self {
        case .idle:
            return "준비됨"
        case .loading:
            return "모델 로딩 중..."
        case .detecting:
            return "탐지 중..."
        case .success(let objects):
            return "\(objects.count)개 객체 탐지됨"
        case .failure(let message):
            return "오류: \(message)"
        }
    }
    
    static func == (lhs: DetectionState, rhs: DetectionState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.detecting, .detecting):
            return true
        case (.success(let l), .success(let r)):
            return l == r
        case (.failure(let l), .failure(let r)):
            return l == r
        default:
            return false
        }
    }
}

// MARK: - 탐지기 오류
enum DetectorError: LocalizedError {
    case modelLoadFailed
    case visionModelCreationFailed
    case modelNotReady
    case imageConversionFailed
    case detectionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .modelLoadFailed:
            return "객체 탐지 모델을 로드할 수 없습니다"
        case .visionModelCreationFailed:
            return "Vision 모델을 생성할 수 없습니다"
        case .modelNotReady:
            return "모델이 준비되지 않았습니다"
        case .imageConversionFailed:
            return "이미지를 변환할 수 없습니다"
        case .detectionFailed(let reason):
            return "객체 탐지 실패: \(reason)"
        }
    }
}

// MARK: - 사각형 탐지 (문서 스캔용)
extension ObjectDetector {
    
    /// 이미지에서 사각형 영역 탐지
    /// - Parameter image: 분석할 이미지
    /// - Returns: 탐지된 사각형 영역들
    func detectRectangles(in image: PlatformImage) async throws -> [CGRect] {
        guard let cgImage = cgImage(from: image) else {
            throw DetectorError.imageConversionFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectRectanglesRequest { request, error in
                if let error = error {
                    continuation.resume(
                        throwing: DetectorError.detectionFailed(error.localizedDescription)
                    )
                    return
                }
                
                guard let observations = request.results as? [VNRectangleObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let rects = observations.map { $0.boundingBox }
                continuation.resume(returning: rects)
            }
            
            // 사각형 탐지 설정
            request.minimumAspectRatio = 0.3
            request.maximumAspectRatio = 3.0
            request.minimumSize = 0.1
            request.minimumConfidence = 0.5
            request.maximumObservations = 10
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(
                    throwing: DetectorError.detectionFailed(error.localizedDescription)
                )
            }
        }
    }
}
