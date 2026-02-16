import Vision
import UIKit
import Observation

@Observable
final class VisionManager {
    var isProcessing = false
    var errorMessage: String?
    var textResults: [RecognizedText] = []
    
    // 이미지 분석 기본 메서드
    func analyze(image: UIImage, requests: [VNRequest]) async throws {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: image.cgImageOrientation,
            options: [:]
        )
        
        try handler.perform(requests)
    }
}

// UIImage orientation을 CGImagePropertyOrientation으로 변환
extension UIImage {
    var cgImageOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
