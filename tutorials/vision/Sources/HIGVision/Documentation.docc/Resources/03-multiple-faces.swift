import Vision
import UIKit

extension FaceDetector {
    
    /// 여러 얼굴 감지
    func detectAllFaces(in image: UIImage) async throws -> [DetectedFace] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        let request = VNDetectFaceRectanglesRequest()
        
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: image.cgImageOrientation,
            options: [:]
        )
        
        try handler.perform([request])
        
        let observations = request.results ?? []
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        
        // 모든 얼굴 처리
        return processFaceObservations(observations, imageSize: imageSize)
    }
    
    /// 가장 큰 얼굴만 반환
    func detectLargestFace(in image: UIImage) async throws -> DetectedFace? {
        let faces = try await detectAllFaces(in: image)
        return faces.max { $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height }
    }
}
