import CoreML

/// Xcode Model Inspector 정보
///
/// .mlmodel 파일을 선택하면 Xcode에서 확인할 수 있는 정보:
///
/// ## General
/// - Name: MobileNetV2
/// - Type: Neural Network Classifier
/// - Size: 14.0 MB
/// - Author: Apple
///
/// ## Inputs
/// - Name: image
/// - Type: Image (Color 224 × 224)
///
/// ## Outputs
/// - Name: classLabelProbs
/// - Type: Dictionary (String → Double)
///
/// - Name: classLabel
/// - Type: String

struct ModelInspector {
    
    /// 모델 메타데이터 확인
    static func inspectModel() throws {
        let model = try MobileNetV2()
        let description = model.model.modelDescription
        
        // 입력 설명
        print("📥 Inputs:")
        for (name, desc) in description.inputDescriptionsByName {
            print("  - \(name): \(desc.type)")
        }
        
        // 출력 설명
        print("📤 Outputs:")
        for (name, desc) in description.outputDescriptionsByName {
            print("  - \(name): \(desc.type)")
        }
        
        // 메타데이터
        if let metadata = description.metadata[.author] {
            print("👤 Author: \(metadata)")
        }
        
        if let metadata = description.metadata[.description] {
            print("📝 Description: \(metadata)")
        }
    }
}
