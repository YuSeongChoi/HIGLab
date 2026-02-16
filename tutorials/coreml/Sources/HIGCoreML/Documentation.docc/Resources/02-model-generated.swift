import CoreML

/// Xcode가 자동 생성한 MobileNetV2 클래스 (예시)
///
/// .mlmodel 파일을 프로젝트에 추가하면
/// Xcode가 이런 형태의 클래스를 자동 생성합니다.
///
/// 실제 생성된 코드는 Derived Data에서 확인할 수 있습니다.
class MobileNetV2 {
    
    /// 모델 인스턴스
    let model: MLModel
    
    /// 기본 Configuration으로 초기화
    init() throws {
        let configuration = MLModelConfiguration()
        self.model = try MLModel(contentsOf: MobileNetV2.urlOfModelInThisBundle)
    }
    
    /// 커스텀 Configuration으로 초기화
    init(configuration: MLModelConfiguration) throws {
        self.model = try MLModel(
            contentsOf: MobileNetV2.urlOfModelInThisBundle,
            configuration: configuration
        )
    }
    
    /// 번들 내 모델 URL
    static var urlOfModelInThisBundle: URL {
        Bundle.main.url(forResource: "MobileNetV2", withExtension: "mlmodelc")!
    }
    
    /// 예측 수행
    func prediction(image: CVPixelBuffer) throws -> MobileNetV2Output {
        let input = MobileNetV2Input(image: image)
        return try prediction(input: input)
    }
    
    func prediction(input: MobileNetV2Input) throws -> MobileNetV2Output {
        let output = try model.prediction(from: input)
        return MobileNetV2Output(features: output)
    }
}

/// 입력 타입
class MobileNetV2Input: MLFeatureProvider {
    var image: CVPixelBuffer
    
    var featureNames: Set<String> { ["image"] }
    
    init(image: CVPixelBuffer) {
        self.image = image
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "image" {
            return MLFeatureValue(pixelBuffer: image)
        }
        return nil
    }
}

/// 출력 타입
class MobileNetV2Output: MLFeatureProvider {
    let classLabel: String
    let classLabelProbs: [String: Double]
    
    var featureNames: Set<String> { ["classLabel", "classLabelProbs"] }
    
    init(features: MLFeatureProvider) {
        self.classLabel = features.featureValue(for: "classLabel")!.stringValue
        self.classLabelProbs = features.featureValue(for: "classLabelProbs")!
            .dictionaryValue as! [String: Double]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        nil // 단순화
    }
}
