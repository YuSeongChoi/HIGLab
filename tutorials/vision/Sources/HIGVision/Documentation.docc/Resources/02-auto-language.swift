import Vision
import UIKit

extension TextRecognizer {
    
    /// 자동 언어 감지 활성화
    func recognizeTextAutoLanguage(
        in image: UIImage
    ) async throws -> [VNRecognizedTextObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        
        // 자동 언어 감지 활성화
        // Vision이 이미지 내 언어를 자동으로 감지
        request.automaticallyDetectsLanguage = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        
        return request.results ?? []
    }
}
