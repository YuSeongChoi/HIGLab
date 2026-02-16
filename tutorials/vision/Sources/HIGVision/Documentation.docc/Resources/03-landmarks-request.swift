import Vision
import UIKit

extension FaceDetector {
    
    /// 얼굴 랜드마크 감지
    func detectFaceLandmarks(in image: UIImage) async throws -> [VNFaceObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        // VNDetectFaceLandmarksRequest는 자동으로 얼굴도 감지함
        let request = VNDetectFaceLandmarksRequest()
        
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: image.cgImageOrientation,
            options: [:]
        )
        
        try handler.perform([request])
        
        return request.results ?? []
    }
}
