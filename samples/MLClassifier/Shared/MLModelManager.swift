import Foundation
import CoreML

// MARK: - ML 모델 관리자
// CoreML 모델의 로딩, 설정, 관리를 담당하는 통합 관리자
// MLModel, MLModelConfiguration, MLComputeUnits, MLModelDescription 활용

/// 사용 가능한 ML 모델 타입
enum MLModelType: String, CaseIterable, Identifiable, Codable {
    case mobileNetV2 = "MobileNetV2"
    case resnet50 = "Resnet50"
    case squeezeNet = "SqueezeNet"
    case yoloV3 = "YOLOv3"
    case yoloV3Tiny = "YOLOv3Tiny"
    
    var id: String { rawValue }
    
    /// 모델 설명
    var description: String {
        switch self {
        case .mobileNetV2:
            return "빠르고 효율적인 모바일 최적화 모델 (이미지 분류)"
        case .resnet50:
            return "높은 정확도의 딥러닝 모델 (이미지 분류)"
        case .squeezeNet:
            return "경량화된 빠른 추론 모델 (이미지 분류)"
        case .yoloV3:
            return "실시간 객체 탐지 모델 (고정확도)"
        case .yoloV3Tiny:
            return "경량 객체 탐지 모델 (고속)"
        }
    }
    
    /// 모델 카테고리
    var category: ModelCategory {
        switch self {
        case .mobileNetV2, .resnet50, .squeezeNet:
            return .imageClassification
        case .yoloV3, .yoloV3Tiny:
            return .objectDetection
        }
    }
    
    /// 예상 입력 크기
    var expectedInputSize: CGSize {
        switch self {
        case .mobileNetV2:
            return CGSize(width: 224, height: 224)
        case .resnet50:
            return CGSize(width: 224, height: 224)
        case .squeezeNet:
            return CGSize(width: 227, height: 227)
        case .yoloV3:
            return CGSize(width: 416, height: 416)
        case .yoloV3Tiny:
            return CGSize(width: 416, height: 416)
        }
    }
}

/// 모델 카테고리
enum ModelCategory: String, CaseIterable {
    case imageClassification = "이미지 분류"
    case objectDetection = "객체 탐지"
}

/// 연산 장치 설정
enum ComputeUnitOption: String, CaseIterable, Identifiable {
    case all = "전체 (Neural Engine + GPU + CPU)"
    case cpuAndGPU = "CPU + GPU"
    case cpuAndNeuralEngine = "CPU + Neural Engine"
    case cpuOnly = "CPU만"
    
    var id: String { rawValue }
    
    /// MLComputeUnits 변환
    var mlComputeUnits: MLComputeUnits {
        switch self {
        case .all:
            return .all
        case .cpuAndGPU:
            return .cpuAndGPU
        case .cpuAndNeuralEngine:
            return .cpuAndNeuralEngine
        case .cpuOnly:
            return .cpuOnly
        }
    }
    
    /// 설명
    var description: String {
        switch self {
        case .all:
            return "최고 성능: Neural Engine, GPU, CPU를 모두 활용"
        case .cpuAndGPU:
            return "GPU 가속: Neural Engine 제외"
        case .cpuAndNeuralEngine:
            return "전력 효율: GPU 제외"
        case .cpuOnly:
            return "호환성 최대: CPU만 사용"
        }
    }
}

// MARK: - 모델 메타데이터
/// 로드된 모델의 상세 정보
struct ModelMetadata: Identifiable {
    let id = UUID()
    let modelType: MLModelType
    let description: MLModelDescription
    let loadedAt: Date
    let computeUnits: ComputeUnitOption
    
    /// 입력 피처 이름 목록
    var inputFeatureNames: [String] {
        description.inputDescriptionsByName.keys.sorted()
    }
    
    /// 출력 피처 이름 목록
    var outputFeatureNames: [String] {
        description.outputDescriptionsByName.keys.sorted()
    }
    
    /// 예측 피처 이름 (분류 모델용)
    var predictedFeatureName: String? {
        description.predictedFeatureName
    }
    
    /// 확률 출력 피처 이름 (분류 모델용)
    var predictedProbabilitiesName: String? {
        description.predictedProbabilitiesName
    }
    
    /// 모델 작성자
    var author: String? {
        description.metadata[MLModelMetadataKey.author] as? String
    }
    
    /// 모델 라이선스
    var license: String? {
        description.metadata[MLModelMetadataKey.license] as? String
    }
    
    /// 모델 버전
    var versionString: String? {
        description.metadata[MLModelMetadataKey.versionString] as? String
    }
    
    /// 전체 설명
    var fullDescription: String? {
        description.metadata[MLModelMetadataKey.description] as? String
    }
}

// MARK: - 모델 관리자
@MainActor
final class MLModelManager: ObservableObject {
    
    // MARK: - Published 프로퍼티
    /// 로딩 상태
    @Published private(set) var isLoading = false
    
    /// 현재 로드된 모델
    @Published private(set) var loadedModel: MLModel?
    
    /// 현재 모델 타입
    @Published private(set) var currentModelType: MLModelType?
    
    /// 현재 연산 장치 설정
    @Published private(set) var currentComputeUnits: ComputeUnitOption = .all
    
    /// 모델 메타데이터
    @Published private(set) var modelMetadata: ModelMetadata?
    
    /// 오류 메시지
    @Published private(set) var errorMessage: String?
    
    /// 캐시된 모델들
    @Published private(set) var cachedModels: [MLModelType: MLModel] = [:]
    
    // MARK: - 싱글톤
    static let shared = MLModelManager()
    
    private init() {}
    
    // MARK: - 모델 설정 생성
    /// MLModelConfiguration 생성
    /// - Parameter computeUnits: 사용할 연산 장치
    /// - Returns: 구성된 MLModelConfiguration
    func createConfiguration(computeUnits: ComputeUnitOption = .all) -> MLModelConfiguration {
        let config = MLModelConfiguration()
        config.computeUnits = computeUnits.mlComputeUnits
        
        // 모델 파라미터 설정 (iOS 16+)
        if #available(iOS 16.0, macOS 13.0, *) {
            // 파라미터가 필요한 모델용 (선택적)
            config.parameters = nil
        }
        
        return config
    }
    
    // MARK: - 모델 로딩
    /// 지정된 타입의 ML 모델을 로드
    /// - Parameters:
    ///   - type: 로드할 모델 타입
    ///   - computeUnits: 연산 장치 설정
    ///   - useCache: 캐시 사용 여부
    /// - Returns: 로드된 MLModel (실패 시 nil)
    func loadModel(
        _ type: MLModelType,
        computeUnits: ComputeUnitOption = .all,
        useCache: Bool = true
    ) async -> MLModel? {
        // 캐시 확인
        if useCache, let cached = cachedModels[type] {
            self.loadedModel = cached
            self.currentModelType = type
            self.currentComputeUnits = computeUnits
            return cached
        }
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // 모델 설정 생성
            let config = createConfiguration(computeUnits: computeUnits)
            
            // 번들에서 모델 URL 가져오기
            guard let modelURL = Bundle.main.url(
                forResource: type.rawValue,
                withExtension: "mlmodelc"
            ) else {
                throw MLModelError.modelNotFound(type.rawValue)
            }
            
            // 모델 로드
            let model = try MLModel(contentsOf: modelURL, configuration: config)
            
            // 메타데이터 생성
            let metadata = ModelMetadata(
                modelType: type,
                description: model.modelDescription,
                loadedAt: Date(),
                computeUnits: computeUnits
            )
            
            // 상태 업데이트
            self.loadedModel = model
            self.currentModelType = type
            self.currentComputeUnits = computeUnits
            self.modelMetadata = metadata
            
            // 캐시에 저장
            if useCache {
                cachedModels[type] = model
            }
            
            return model
            
        } catch let error as MLModelError {
            self.errorMessage = error.localizedDescription
            return nil
        } catch {
            self.errorMessage = "모델 로딩 실패: \(error.localizedDescription)"
            return nil
        }
    }
    
    /// 비동기 모델 로드 (MLModelAsset 사용)
    /// - Parameters:
    ///   - url: 모델 URL
    ///   - computeUnits: 연산 장치 설정
    /// - Returns: 로드된 MLModel
    @available(iOS 16.0, macOS 13.0, *)
    func loadModelAsync(
        from url: URL,
        computeUnits: ComputeUnitOption = .all
    ) async throws -> MLModel {
        isLoading = true
        defer { isLoading = false }
        
        let config = createConfiguration(computeUnits: computeUnits)
        
        // MLModelAsset을 사용한 비동기 로딩
        let asset = try MLModelAsset(url: url)
        let model = try await MLModel.load(asset: asset, configuration: config)
        
        return model
    }
    
    /// 모델 정보 조회 (로딩 없이)
    /// - Parameter type: 모델 타입
    /// - Returns: 모델 설명 (로드 불가 시 nil)
    func getModelDescription(_ type: MLModelType) -> MLModelDescription? {
        guard let modelURL = Bundle.main.url(
            forResource: type.rawValue,
            withExtension: "mlmodelc"
        ) else {
            return nil
        }
        
        do {
            // 임시 모델 로드로 설명 가져오기
            let config = createConfiguration(computeUnits: .cpuOnly)
            let model = try MLModel(contentsOf: modelURL, configuration: config)
            return model.modelDescription
        } catch {
            return nil
        }
    }
    
    /// 현재 로드된 모델 해제
    func unloadModel() {
        loadedModel = nil
        currentModelType = nil
        modelMetadata = nil
    }
    
    /// 모든 캐시된 모델 해제
    func clearCache() {
        cachedModels.removeAll()
    }
    
    // MARK: - 모델 검증
    /// 모델 입력 검증
    /// - Parameters:
    ///   - featureProvider: 입력 피처 제공자
    ///   - model: 대상 모델
    /// - Returns: 검증 결과
    func validateInput(
        _ featureProvider: MLFeatureProvider,
        for model: MLModel
    ) -> Bool {
        let inputNames = model.modelDescription.inputDescriptionsByName
        
        for (name, description) in inputNames {
            guard featureProvider.featureValue(for: name) != nil else {
                errorMessage = "필수 입력 누락: \(name)"
                return false
            }
            
            // 타입 검증
            let inputValue = featureProvider.featureValue(for: name)!
            if inputValue.type != description.type {
                errorMessage = "입력 타입 불일치: \(name)"
                return false
            }
        }
        
        return true
    }
}

// MARK: - 모델 오류
enum MLModelError: LocalizedError {
    case modelNotFound(String)
    case loadingFailed(String)
    case invalidModel
    case configurationFailed
    case predictionFailed(String)
    case featureProviderError(String)
    
    var errorDescription: String? {
        switch self {
        case .modelNotFound(let name):
            return "모델을 찾을 수 없습니다: \(name)"
        case .loadingFailed(let reason):
            return "모델 로딩 실패: \(reason)"
        case .invalidModel:
            return "유효하지 않은 모델입니다"
        case .configurationFailed:
            return "모델 설정 실패"
        case .predictionFailed(let reason):
            return "예측 실패: \(reason)"
        case .featureProviderError(let reason):
            return "피처 제공 오류: \(reason)"
        }
    }
}
