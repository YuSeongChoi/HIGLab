import Vision
import CoreGraphics

extension QRScanner {
    
    /// QR코드의 4개 코너 포인트 추출
    func extractCorners(from observation: VNBarcodeObservation) -> [CGPoint] {
        return [
            observation.topLeft,
            observation.topRight,
            observation.bottomRight,
            observation.bottomLeft
        ]
    }
    
    /// 코너 포인트를 이미지 좌표로 변환
    func convertCorners(
        _ corners: [CGPoint],
        to imageSize: CGSize
    ) -> [CGPoint] {
        return corners.map { point in
            CGPoint(
                x: point.x * imageSize.width,
                y: (1 - point.y) * imageSize.height
            )
        }
    }
}
