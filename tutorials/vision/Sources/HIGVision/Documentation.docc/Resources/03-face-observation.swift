import Vision
import CoreGraphics

extension FaceDetector {
    
    func processFaceObservations(
        _ observations: [VNFaceObservation],
        imageSize: CGSize
    ) -> [DetectedFace] {
        return observations.map { observation in
            // 바운딩 박스 (정규화 좌표)
            let boundingBox = observation.boundingBox
            
            // UIKit 좌표로 변환
            let frame = boundingBox.toUIKit(in: imageSize)
            
            // 회전 각도 (있는 경우)
            let roll = observation.roll?.doubleValue ?? 0
            let yaw = observation.yaw?.doubleValue ?? 0
            
            return DetectedFace(
                boundingBox: boundingBox,
                frame: frame,
                roll: roll,
                yaw: yaw,
                confidence: Double(observation.confidence)
            )
        }
    }
}
