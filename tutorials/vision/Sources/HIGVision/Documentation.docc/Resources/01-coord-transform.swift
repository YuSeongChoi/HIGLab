import Vision
import CoreGraphics

struct CoordinateTransformer {
    let imageSize: CGSize
    
    // Vision 정규화 좌표 → UIKit 좌표
    func convertToUIKit(_ normalizedRect: CGRect) -> CGRect {
        // Y축 반전
        let flippedY = 1.0 - normalizedRect.origin.y - normalizedRect.height
        
        return CGRect(
            x: normalizedRect.origin.x * imageSize.width,
            y: flippedY * imageSize.height,
            width: normalizedRect.width * imageSize.width,
            height: normalizedRect.height * imageSize.height
        )
    }
    
    // Vision 정규화 포인트 → UIKit 좌표
    func convertToUIKit(_ normalizedPoint: CGPoint) -> CGPoint {
        return CGPoint(
            x: normalizedPoint.x * imageSize.width,
            y: (1.0 - normalizedPoint.y) * imageSize.height
        )
    }
    
    // UIKit 좌표 → Vision 정규화 좌표
    func convertToVision(_ rect: CGRect) -> CGRect {
        let normalizedY = 1.0 - (rect.origin.y / imageSize.height) - (rect.height / imageSize.height)
        
        return CGRect(
            x: rect.origin.x / imageSize.width,
            y: normalizedY,
            width: rect.width / imageSize.width,
            height: rect.height / imageSize.height
        )
    }
}
