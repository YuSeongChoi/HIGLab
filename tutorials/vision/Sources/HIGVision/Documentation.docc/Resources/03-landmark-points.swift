import Vision
import CoreGraphics

extension FaceDetector {
    
    /// 랜드마크 포인트를 이미지 좌표로 변환
    func convertLandmarkPoints(
        _ normalizedPoints: [CGPoint],
        in boundingBox: CGRect,
        imageSize: CGSize
    ) -> [CGPoint] {
        return normalizedPoints.map { point in
            // 랜드마크 포인트는 얼굴 바운딩 박스 내 정규화 좌표
            // 1. 바운딩 박스 내 좌표 계산
            let x = boundingBox.origin.x + point.x * boundingBox.width
            let y = boundingBox.origin.y + point.y * boundingBox.height
            
            // 2. 이미지 좌표로 변환 (Y축 반전)
            return CGPoint(
                x: x * imageSize.width,
                y: (1 - y) * imageSize.height
            )
        }
    }
    
    /// 특정 랜드마크 영역의 중심점 계산
    func centerOfLandmark(_ points: [CGPoint]) -> CGPoint? {
        guard !points.isEmpty else { return nil }
        
        let sumX = points.reduce(0) { $0 + $1.x }
        let sumY = points.reduce(0) { $0 + $1.y }
        
        return CGPoint(
            x: sumX / CGFloat(points.count),
            y: sumY / CGFloat(points.count)
        )
    }
}
