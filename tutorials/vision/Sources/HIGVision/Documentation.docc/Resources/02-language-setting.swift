import Vision
import UIKit

final class TextRecognizer {
    
    func recognizeText(
        in image: UIImage,
        languages: [String] = ["ko-KR", "en-US"]
    ) async throws -> [VNRecognizedTextObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        
        // 인식할 언어 설정 (BCP 47 언어 코드)
        // - "ko-KR": 한국어
        // - "en-US": 영어
        // - "ja-JP": 일본어
        // - "zh-Hans": 중국어 간체
        request.recognitionLanguages = languages
        
        // 지원 언어 확인
        let supportedLanguages = try request.supportedRecognitionLanguages()
        print("지원 언어: \(supportedLanguages)")
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        
        return request.results ?? []
    }
}
