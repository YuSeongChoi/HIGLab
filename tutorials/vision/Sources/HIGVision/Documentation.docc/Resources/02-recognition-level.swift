import Vision
import UIKit

final class TextRecognizer {
    
    func recognizeText(
        in image: UIImage,
        level: VNRequestTextRecognitionLevel = .accurate
    ) async throws -> [VNRecognizedTextObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        let request = VNRecognizeTextRequest()
        
        // 인식 레벨 설정
        // - .fast: 빠르지만 정확도 낮음 (실시간 프리뷰용)
        // - .accurate: 느리지만 정확함 (최종 스캔용)
        request.recognitionLevel = level
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        
        return request.results ?? []
    }
}
