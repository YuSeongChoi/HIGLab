import CoreML

/// 동기 모델 로딩
///
/// 간단하지만 UI 스레드를 블로킹할 수 있습니다.
/// 작은 모델이나 앱 시작 시 사용합니다.
struct SyncModelLoading {
    
    /// 방법 1: 자동 생성 클래스 사용 (권장)
    func loadWithGeneratedClass() throws -> MobileNetV2 {
        // Xcode가 생성한 클래스를 직접 사용
        let model = try MobileNetV2()
        return model
    }
    
    /// 방법 2: MLModel 직접 로딩
    func loadWithMLModel() throws -> MLModel {
        guard let modelURL = Bundle.main.url(
            forResource: "MobileNetV2",
            withExtension: "mlmodelc"
        ) else {
            throw ModelError.modelNotFound
        }
        
        let model = try MLModel(contentsOf: modelURL)
        return model
    }
    
    /// 방법 3: Configuration과 함께 로딩
    func loadWithConfiguration() throws -> MLModel {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all  // Neural Engine, GPU, CPU 모두 사용
        
        guard let modelURL = Bundle.main.url(
            forResource: "MobileNetV2",
            withExtension: "mlmodelc"
        ) else {
            throw ModelError.modelNotFound
        }
        
        let model = try MLModel(
            contentsOf: modelURL,
            configuration: configuration
        )
        return model
    }
}

enum ModelError: Error {
    case modelNotFound
    case loadingFailed
}
