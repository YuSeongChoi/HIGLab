import CoreML
import Vision
import UIKit

/// 이미지 분류 서비스
///
/// 모델 로딩과 분류 로직을 캡슐화합니다.
@MainActor
class ImageClassifierService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isModelReady = false
    @Published var isClassifying = false
    @Published var lastResult: ClassificationResult?
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var model: VNCoreMLModel?
    
    // MARK: - Initialization
    init() {
        Task {
            await loadModel()
        }
    }
    
    // MARK: - Model Loading
    private func loadModel() async {
        do {
            let configuration = MLModelConfiguration()
            configuration.computeUnits = .all
            
            let coreMLModel = try MobileNetV2(configuration: configuration)
            self.model = try VNCoreMLModel(for: coreMLModel.model)
            self.isModelReady = true
        } catch {
            self.errorMessage = "모델 로딩 실패: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Classification
    func classify(image: UIImage) async {
        guard let model = model else {
            errorMessage = "모델이 준비되지 않았습니다"
            return
        }
        
        guard let cgImage = image.cgImage else {
            errorMessage = "이미지 변환 실패"
            return
        }
        
        isClassifying = true
        defer { isClassifying = false }
        
        // VNCoreMLRequest 생성
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .centerCrop
        
        // 이미지 핸들러로 요청 실행
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            // 결과 파싱
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                errorMessage = "분류 결과가 없습니다"
                return
            }
            
            self.lastResult = ClassificationResult(
                label: topResult.identifier,
                confidence: topResult.confidence,
                topResults: Array(results.prefix(5))
            )
        } catch {
            errorMessage = "분류 실패: \(error.localizedDescription)"
        }
    }
}

// MARK: - Result Model
struct ClassificationResult {
    let label: String
    let confidence: Float
    let topResults: [VNClassificationObservation]
    
    var confidencePercentage: String {
        String(format: "%.1f%%", confidence * 100)
    }
}
