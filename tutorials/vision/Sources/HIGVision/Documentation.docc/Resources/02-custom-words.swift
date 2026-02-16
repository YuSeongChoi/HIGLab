import Vision
import UIKit

extension TextRecognizer {
    
    /// 커스텀 단어로 인식 정확도 향상
    func recognizeTextWithCustomWords(
        in image: UIImage,
        customWords: [String]
    ) async throws -> [VNRecognizedTextObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ko-KR", "en-US"]
        
        // 커스텀 단어 설정
        // 자주 사용되는 전문 용어, 브랜드명, 약어 등을 추가
        // 예: ["SKU", "ISBN", "QR코드", "바코드"]
        request.customWords = customWords
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        
        return request.results ?? []
    }
}

// 사용 예시
let customWords = [
    "문서스캐너", "OCR", "텍스트인식",
    "AI", "Vision", "CoreML"
]
