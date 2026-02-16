import CoreGraphics

extension CGRect {
    /// Vision 정규화 좌표를 UIKit 좌표로 변환
    func toUIKit(in size: CGSize) -> CGRect {
        let flippedY = 1.0 - origin.y - height
        return CGRect(
            x: origin.x * size.width,
            y: flippedY * size.height,
            width: width * size.width,
            height: height * size.height
        )
    }
    
    /// UIKit 좌표를 Vision 정규화 좌표로 변환
    func toVision(in size: CGSize) -> CGRect {
        let normalizedY = 1.0 - (origin.y / size.height) - (height / size.height)
        return CGRect(
            x: origin.x / size.width,
            y: normalizedY,
            width: width / size.width,
            height: height / size.height
        )
    }
}

extension CGPoint {
    /// Vision 정규화 좌표를 UIKit 좌표로 변환
    func toUIKit(in size: CGSize) -> CGPoint {
        CGPoint(
            x: x * size.width,
            y: (1.0 - y) * size.height
        )
    }
    
    /// UIKit 좌표를 Vision 정규화 좌표로 변환
    func toVision(in size: CGSize) -> CGPoint {
        CGPoint(
            x: x / size.width,
            y: 1.0 - (y / size.height)
        )
    }
}
