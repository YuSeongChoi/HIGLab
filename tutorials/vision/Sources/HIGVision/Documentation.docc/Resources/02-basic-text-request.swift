import Vision
import UIKit

final class TextRecognizer {
    
    func recognizeText(in image: UIImage) async throws -> [VNRecognizedTextObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        // VNRecognizeTextRequest 생성
        let request = VNRecognizeTextRequest()
        
        // Handler 생성 및 실행
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            options: [:]
        )
        
        try handler.perform([request])
        
        // 결과 반환
        return request.results ?? []
    }
}
