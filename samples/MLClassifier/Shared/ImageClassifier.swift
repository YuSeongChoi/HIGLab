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
// Vision + CoreML을 사용한 고급 이미지 분류 수행
// VNCoreMLRequest, VNImageRequestHandler, VNClassificationObservation 활용

@MainActor
final class ImageClassifier: ObservableObject {
    
    // MARK: - Published 프로퍼티
    /// 현재 분류 상태
    @Published private(set) var state: ClassificationState = .idle
    
    /// 최근 분류 결과
    @Published private(set) var topResults: [ClassificationResult] = []
    
    /// 마지막 예측 시간 (ms)
    @Published private(set) var lastPredictionTimeMs: Double = 0
    
    // MARK: - Private 프로퍼티
    /// Vision CoreML 모델
    private var visionModel: VNCoreMLModel?
    
    /// 모델 관리자
    private let modelManager = MLModelManager.shared
    
    /// 현재 로드된 모델 타입
    private(set) var currentModelType: MLModelType?
    
    // MARK: - 설정 프로퍼티
    /// 결과 최대 개수
    var maxResults: Int = 5
    
    /// 최소 신뢰도 임계값
    var minimumConfidence: Float = 0.01
    
    /// 이미지 크롭/스케일 옵션
    var imageCropAndScaleOption: VNImageCropAndScaleOption = .centerCrop
    
    // MARK: - 초기화
    init() {}
    
    // MARK: - 모델 준비
    /// Vision 모델 준비
    /// - Parameters:
    ///   - modelType: 사용할 ML 모델 타입
    ///   - computeUnits: 연산 장치 설정
    func prepareModel(
        _ modelType: MLModelType = .mobileNetV2,
        computeUnits: ComputeUnitOption = .all
    ) async throws {
        state = .loading
        
        guard let mlModel = await modelManager.loadModel(
            modelType,
            computeUnits: computeUnits
        ) else {
            state = .failure("모델을 로드할 수 없습니다")
            throw ClassifierError.modelLoadFailed
        }
        
        do {
            // CoreML 모델을 Vision 모델로 변환
            visionModel = try VNCoreMLModel(for: mlModel)
            currentModelType = modelType
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
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Vision 요청 생성 및 실행
        let results = try await performVisionRequest(
            model: visionModel,
            cgImage: cgImage
        )
        
        // 예측 시간 계산
        let endTime = CFAbsoluteTimeGetCurrent()
        lastPredictionTimeMs = (endTime - startTime) * 1000
        
        return results
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
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let results = try await performVisionRequest(
            model: visionModel,
            ciImage: ciImage
        )
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastPredictionTimeMs = (endTime - startTime) * 1000
        
        return results
    }
    
    /// CGImage로 분류
    /// - Parameter cgImage: 분류할 CGImage
    /// - Returns: 분류 결과 배열
    func classify(cgImage: CGImage) async throws -> [ClassificationResult] {
        if visionModel == nil {
            try await prepareModel()
        }
        
        guard let visionModel = visionModel else {
            throw ClassifierError.modelNotReady
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let results = try await performVisionRequest(
            model: visionModel,
            cgImage: cgImage
        )
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastPredictionTimeMs = (endTime - startTime) * 1000
        
        return results
    }
    
    /// Data로 분류
    /// - Parameter data: 이미지 데이터
    /// - Returns: 분류 결과 배열
    func classify(data: Data) async throws -> [ClassificationResult] {
        #if canImport(UIKit)
        guard let image = UIImage(data: data) else {
            throw ClassifierError.imageConversionFailed
        }
        return try await classify(image: image)
        #elseif canImport(AppKit)
        guard let image = NSImage(data: data) else {
            throw ClassifierError.imageConversionFailed
        }
        return try await classify(image: image)
        #endif
    }
    
    /// URL로 분류
    /// - Parameter url: 이미지 URL (로컬 또는 원격)
    /// - Returns: 분류 결과 배열
    func classify(url: URL) async throws -> [ClassificationResult] {
        if url.isFileURL {
            let data = try Data(contentsOf: url)
            return try await classify(data: data)
        } else {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try await classify(data: data)
        }
    }
    
    // MARK: - 직접 CoreML 예측 (Vision 없이)
    /// MLFeatureProvider를 사용한 직접 예측
    /// - Parameters:
    ///   - featureProvider: 입력 피처 제공자
    ///   - options: 예측 옵션
    /// - Returns: 출력 피처 제공자
    func predict(
        with featureProvider: MLFeatureProvider,
        options: MLPredictionOptions? = nil
    ) async throws -> MLFeatureProvider {
        guard let model = modelManager.loadedModel else {
            throw ClassifierError.modelNotReady
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let output: MLFeatureProvider
        if let options = options {
            output = try model.prediction(from: featureProvider, options: options)
        } else {
            output = try model.prediction(from: featureProvider)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastPredictionTimeMs = (endTime - startTime) * 1000
        
        return output
    }
    
    /// 상태 초기화
    func reset() {
        state = .idle
        topResults = []
        lastPredictionTimeMs = 0
    }
    
    // MARK: - Private 헬퍼
    /// Vision 요청 수행 (CGImage)
    private func performVisionRequest(
        model: VNCoreMLModel,
        cgImage: CGImage
    ) async throws -> [ClassificationResult] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = createVisionRequest(
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
    private func performVisionRequest(
        model: VNCoreMLModel,
        ciImage: CIImage
    ) async throws -> [ClassificationResult] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = createVisionRequest(
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
    
    /// Vision 요청 생성
    private func createVisionRequest(
        model: VNCoreMLModel,
        continuation: CheckedContinuation<[ClassificationResult], Error>
    ) -> VNCoreMLRequest {
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                Task { @MainActor in
                    self.state = .failure(error.localizedDescription)
                }
                continuation.resume(
                    throwing: ClassifierError.classificationFailed(error.localizedDescription)
                )
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
                        confidence: observation.confidence,
                        requestRevision: request.revision
                    )
                }
            
            Task { @MainActor in
                self.topResults = results
                self.state = .success(results)
            }
            
            continuation.resume(returning: results)
        }
        
        // 이미지 크롭/스케일 옵션
        request.imageCropAndScaleOption = imageCropAndScaleOption
        
        return request
    }
    
    /// 요청 실행
    private func executeRequest(
        _ request: VNCoreMLRequest,
        with handler: VNImageRequestHandler,
        continuation: CheckedContinuation<[ClassificationResult], Error>
    ) {
        do {
            try handler.perform([request])
        } catch {
            Task { @MainActor in
                self.state = .failure(error.localizedDescription)
            }
            continuation.resume(
                throwing: ClassifierError.classificationFailed(error.localizedDescription)
            )
        }
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

// MARK: - 분류기 오류
enum ClassifierError: LocalizedError {
    case modelLoadFailed
    case visionModelCreationFailed
    case modelNotReady
    case imageConversionFailed
    case classificationFailed(String)
    case noResults
    case invalidInput(String)
    
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
        case .invalidInput(let reason):
            return "잘못된 입력: \(reason)"
        }
    }
}

// MARK: - 이미지 분류 확장 기능
extension ImageClassifier {
    
    /// 여러 이미지 동시 분류
    /// - Parameter images: 분류할 이미지 배열
    /// - Returns: 각 이미지별 분류 결과
    func classifyMultiple(_ images: [PlatformImage]) async throws -> [[ClassificationResult]] {
        var allResults: [[ClassificationResult]] = []
        
        for image in images {
            let results = try await classify(image: image)
            allResults.append(results)
        }
        
        return allResults
    }
    
    /// 이미지가 특정 클래스에 속하는지 확인
    /// - Parameters:
    ///   - image: 확인할 이미지
    ///   - className: 확인할 클래스 이름
    ///   - threshold: 신뢰도 임계값
    /// - Returns: 해당 클래스 포함 여부
    func imageContains(
        image: PlatformImage,
        className: String,
        threshold: Float = 0.5
    ) async throws -> Bool {
        let results = try await classify(image: image)
        
        return results.contains {
            $0.label.lowercased().contains(className.lowercased()) &&
            $0.confidence >= threshold
        }
    }
    
    /// 가장 신뢰도 높은 결과 반환
    /// - Parameter image: 분류할 이미지
    /// - Returns: 최상위 분류 결과
    func topClassification(for image: PlatformImage) async throws -> ClassificationResult? {
        let results = try await classify(image: image)
        return results.first
    }
}
