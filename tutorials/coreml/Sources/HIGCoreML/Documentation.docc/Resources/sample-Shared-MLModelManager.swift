import Foundation
import CoreML

// MARK: - ML 모델 관리자
// CoreML 모델의 로딩 및 관리를 담당

/// 사용 가능한 ML 모델 타입
enum MLModelType: String, CaseIterable, Identifiable {
    case mobileNetV2 = "MobileNetV2"
    case resnet50 = "Resnet50"
    case squeezeNet = "SqueezeNet"
    
    var id: String { rawValue }
    
    /// 모델 설명
    var description: String {
        switch self {
        case .mobileNetV2:
            return "빠르고 효율적인 모바일 최적화 모델"
        case .resnet50:
            return "높은 정확도의 딥러닝 모델"
        case .squeezeNet:
            return "경량화된 빠른 추론 모델"
        }
    }
}

// MARK: - 모델 관리자
@MainActor
final class MLModelManager: ObservableObject {
    
    // MARK: - Published 프로퍼티
    @Published private(set) var isLoading = false
    @Published private(set) var loadedModel: MLModel?
    @Published private(set) var currentModelType: MLModelType?
    @Published private(set) var errorMessage: String?
    
    // MARK: - 싱글톤
    static let shared = MLModelManager()
    
    private init() {}
    
    // MARK: - 모델 로딩
    /// 지정된 타입의 ML 모델을 로드
    /// - Parameter type: 로드할 모델 타입
    /// - Returns: 로드된 MLModel (실패 시 nil)
    func loadModel(_ type: MLModelType) async -> MLModel? {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // 모델 설정: CPU + GPU 사용
            let config = MLModelConfiguration()
            config.computeUnits = .all  // CPU, GPU, Neural Engine 모두 활용
            
            let model: MLModel
            
            // 번들에서 모델 로드 시도
            // 실제 앱에서는 .mlmodelc 파일이 번들에 포함되어야 함
            switch type {
            case .mobileNetV2:
                // MobileNetV2 모델 로드
                if let modelURL = Bundle.main.url(forResource: "MobileNetV2", withExtension: "mlmodelc") {
                    model = try MLModel(contentsOf: modelURL, configuration: config)
                } else {
                    throw MLModelError.modelNotFound(type.rawValue)
                }
                
            case .resnet50:
                if let modelURL = Bundle.main.url(forResource: "Resnet50", withExtension: "mlmodelc") {
                    model = try MLModel(contentsOf: modelURL, configuration: config)
                } else {
                    throw MLModelError.modelNotFound(type.rawValue)
                }
                
            case .squeezeNet:
                if let modelURL = Bundle.main.url(forResource: "SqueezeNet", withExtension: "mlmodelc") {
                    model = try MLModel(contentsOf: modelURL, configuration: config)
                } else {
                    throw MLModelError.modelNotFound(type.rawValue)
                }
            }
            
            self.loadedModel = model
            self.currentModelType = type
            
            return model
            
        } catch let error as MLModelError {
            self.errorMessage = error.localizedDescription
            return nil
        } catch {
            self.errorMessage = "모델 로딩 실패: \(error.localizedDescription)"
            return nil
        }
    }
    
    /// 현재 로드된 모델 해제
    func unloadModel() {
        loadedModel = nil
        currentModelType = nil
    }
}

// MARK: - 모델 오류
enum MLModelError: LocalizedError {
    case modelNotFound(String)
    case loadingFailed(String)
    case invalidModel
    
    var errorDescription: String? {
        switch self {
        case .modelNotFound(let name):
            return "모델을 찾을 수 없습니다: \(name)"
        case .loadingFailed(let reason):
            return "모델 로딩 실패: \(reason)"
        case .invalidModel:
            return "유효하지 않은 모델입니다"
        }
    }
}
