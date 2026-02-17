import Foundation
import CoreML
import Vision
import CoreImage

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

// MARK: - 이미지 분류기
// Vision + CoreML을 사용한 이미지 분류 수행

@MainActor
final class ImageClassifier: ObservableObject {
    
    // MARK: - Published 프로퍼티
    @Published private(set) var state: ClassificationState = .idle
    @Published private(set) var topResults: [ClassificationResult] = []
    
    // MARK: - Private 프로퍼티
    private var visionModel: VNCoreMLModel?
    private let modelManager = MLModelManager.shared
    
    /// 결과 최대 개수
    var maxResults: Int = 5
    
    /// 최소 신뢰도 임계값
    var minimumConfidence: Float = 0.01
    
    // MARK: - 초기화
    init() {}
    
    // MARK: - 모델 준비
    /// Vision 모델 준비
    /// - Parameter modelType: 사용할 ML 모델 타입
    func prepareModel(_ modelType: MLModelType = .mobileNetV2) async throws {
        state = .loading
        
        guard let mlModel = await modelManager.loadModel(modelType) else {
            state = .failure("모델을 로드할 수 없습니다")
            throw ClassifierError.modelLoadFailed
        }
        
        do {
            // CoreML 모델을 Vision 모델로 변환
            visionModel = try VNCoreMLModel(for: mlModel)
            state = .idle
        } catch {
            state = .failure("Vision 모델 생성 실패")
            throw ClassifierError.visionModelCreationFailed
        }
    }
    
    // MARK: - 이미지 분류
    /// 이미지 분류 수행
    /// - Parameter image: 분류할 이미지
    /// - Returns: 분류 결과 배열
    func classify(image: PlatformImage) async throws -> [ClassificationResult] {
        // 모델이 준비되지 않았으면 기본 모델로 준비
        if visionModel == nil {
            try await prepareModel()
        }
        
        guard let visionModel = visionModel else {
            throw ClassifierError.modelNotReady
        }
        
        state = .classifying
        
        // CGImage로 변환
        guard let cgImage = cgImage(from: image) else {
            state = .failure("이미지 변환 실패")
            throw ClassifierError.imageConversionFailed
        }
        
        // Vision 요청 생성 및 실행
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
                guard let self = self else { return }
                
                if let error = error {
                    Task { @MainActor in
                        self.state = .failure(error.localizedDescription)
                    }
                    continuation.resume(throwing: ClassifierError.classificationFailed(error.localizedDescription))
                    return
                }
                
                // 결과 처리
                guard let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(throwing: ClassifierError.noResults)
                    return
                }
                
                // 상위 결과 추출
                let results = observations
                    .prefix(self.maxResults)
                    .filter { $0.confidence >= self.minimumConfidence }
                    .map { observation in
                        ClassificationResult(
                            label: observation.identifier,
                            confidence: observation.confidence
                        )
                    }
                
                Task { @MainActor in
                    self.topResults = results
                    self.state = .success(results)
                }
                
                continuation.resume(returning: results)
            }
            
            // 이미지 크롭/스케일 옵션
            request.imageCropAndScaleOption = .centerCrop
            
            // 요청 실행
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                Task { @MainActor in
                    self.state = .failure(error.localizedDescription)
                }
                continuation.resume(throwing: ClassifierError.classificationFailed(error.localizedDescription))
            }
        }
    }
    
    /// CIImage로 분류 (실시간 카메라용)
    /// - Parameter ciImage: 분류할 CIImage
    /// - Returns: 분류 결과 배열
    func classify(ciImage: CIImage) async throws -> [ClassificationResult] {
        if visionModel == nil {
            try await prepareModel()
        }
        
        guard let visionModel = visionModel else {
            throw ClassifierError.modelNotReady
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
                guard let self = self else { return }
                
                if let error = error {
                    continuation.resume(throwing: ClassifierError.classificationFailed(error.localizedDescription))
                    return
                }
                
                guard let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(throwing: ClassifierError.noResults)
                    return
                }
                
                let results = observations
                    .prefix(self.maxResults)
                    .filter { $0.confidence >= self.minimumConfidence }
                    .map { ClassificationResult(label: $0.identifier, confidence: $0.confidence) }
                
                Task { @MainActor in
                    self.topResults = results
                    self.state = .success(results)
                }
                
                continuation.resume(returning: results)
            }
            
            request.imageCropAndScaleOption = .centerCrop
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: ClassifierError.classificationFailed(error.localizedDescription))
            }
        }
    }
    
    /// 상태 초기화
    func reset() {
        state = .idle
        topResults = []
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

// MARK: - 분류기 오류
enum ClassifierError: LocalizedError {
    case modelLoadFailed
    case visionModelCreationFailed
    case modelNotReady
    case imageConversionFailed
    case classificationFailed(String)
    case noResults
    
    var errorDescription: String? {
        switch self {
        case .modelLoadFailed:
            return "ML 모델을 로드할 수 없습니다"
        case .visionModelCreationFailed:
            return "Vision 모델을 생성할 수 없습니다"
        case .modelNotReady:
            return "모델이 준비되지 않았습니다"
        case .imageConversionFailed:
            return "이미지를 변환할 수 없습니다"
        case .classificationFailed(let reason):
            return "분류 실패: \(reason)"
        case .noResults:
            return "분류 결과가 없습니다"
        }
    }
}
