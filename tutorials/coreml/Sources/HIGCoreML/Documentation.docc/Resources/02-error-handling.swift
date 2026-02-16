import CoreML
import os.log

/// 모델 로딩 에러 처리
///
/// 견고한 앱을 위한 에러 처리 패턴
enum ModelLoadingError: LocalizedError {
    case modelNotFound(String)
    case compilationFailed
    case configurationInvalid
    case insufficientMemory
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .modelNotFound(let name):
            return "모델 '\(name)'을(를) 찾을 수 없습니다."
        case .compilationFailed:
            return "모델 컴파일에 실패했습니다."
        case .configurationInvalid:
            return "모델 설정이 올바르지 않습니다."
        case .insufficientMemory:
            return "메모리가 부족합니다."
        case .unknownError(let error):
            return "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
}

class SafeModelLoader {
    private let logger = Logger(subsystem: "com.app.coreml", category: "ModelLoader")
    
    /// 안전한 모델 로딩
    func loadSafely(modelName: String = "MobileNetV2") -> Result<MLModel, ModelLoadingError> {
        // 1. 모델 URL 확인
        guard let modelURL = Bundle.main.url(
            forResource: modelName,
            withExtension: "mlmodelc"
        ) else {
            logger.error("모델 파일을 찾을 수 없습니다: \(modelName)")
            return .failure(.modelNotFound(modelName))
        }
        
        // 2. Configuration 설정
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all
        
        // 3. 모델 로딩 시도
        do {
            let model = try MLModel(contentsOf: modelURL, configuration: configuration)
            logger.info("모델 로딩 성공: \(modelName)")
            return .success(model)
        } catch let error as NSError {
            logger.error("모델 로딩 실패: \(error.localizedDescription)")
            
            // 에러 타입별 분기
            switch error.code {
            case 1:  // File not found
                return .failure(.modelNotFound(modelName))
            case 2:  // Compilation failed
                return .failure(.compilationFailed)
            default:
                return .failure(.unknownError(error))
            }
        }
    }
    
    /// 폴백 모델 로딩
    func loadWithFallback() -> MLModel? {
        // 주 모델 시도
        if case .success(let model) = loadSafely(modelName: "MobileNetV2") {
            return model
        }
        
        // 폴백: 더 작은 모델 시도
        logger.warning("주 모델 로딩 실패, 폴백 모델 시도")
        if case .success(let model) = loadSafely(modelName: "MobileNetV2_Small") {
            return model
        }
        
        logger.error("모든 모델 로딩 실패")
        return nil
    }
}
