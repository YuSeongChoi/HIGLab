import Vision
import UIKit

final class FaceDetector {
    
    func detectFaces(in image: UIImage) async throws -> [VNFaceObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        // VNDetectFaceRectanglesRequest 생성
        let request = VNDetectFaceRectanglesRequest()
        
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: image.cgImageOrientation,
            options: [:]
        )
        
        try handler.perform([request])
        
        return request.results ?? []
    }
}
