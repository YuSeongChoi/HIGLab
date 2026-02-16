import Vision
import UIKit

extension FaceDetector {
    
    /// 얼굴 캡처 품질 평가
    func detectFaceQuality(in image: UIImage) async throws -> [(face: DetectedFace, quality: Float)] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        // 얼굴 캡처 품질 Request
        let request = VNDetectFaceCaptureQualityRequest()
        
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: image.cgImageOrientation,
            options: [:]
        )
        
        try handler.perform([request])
        
        let observations = request.results ?? []
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        
        return observations.compactMap { observation in
            guard let quality = observation.faceCaptureQuality else {
                return nil
            }
            
            let face = DetectedFace(
                boundingBox: observation.boundingBox,
                frame: observation.boundingBox.toUIKit(in: imageSize),
                roll: observation.roll?.doubleValue ?? 0,
                yaw: observation.yaw?.doubleValue ?? 0,
                confidence: Double(observation.confidence)
            )
            
            return (face, quality)
        }
    }
}
