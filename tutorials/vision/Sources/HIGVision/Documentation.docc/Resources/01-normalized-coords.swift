import Vision
import CoreGraphics

// Vision 정규화 좌표계
// - 범위: 0.0 ~ 1.0
// - 원점: 좌하단 (Lower-Left)
// - UIKit 원점: 좌상단 (Upper-Left)

/*
 Vision 좌표계:
 
 (0,1) -------- (1,1)
   |              |
   |              |
   |              |
 (0,0) -------- (1,0)
 
 UIKit 좌표계:
 
 (0,0) -------- (W,0)
   |              |
   |              |
   |              |
 (0,H) -------- (W,H)
 */

// Vision 좌표 → UIKit 좌표 변환
func convertToUIKit(
    visionRect: CGRect,
    imageSize: CGSize
) -> CGRect {
    // Y축 뒤집기 필요
    let y = 1.0 - visionRect.origin.y - visionRect.height
    
    return CGRect(
        x: visionRect.origin.x * imageSize.width,
        y: y * imageSize.height,
        width: visionRect.width * imageSize.width,
        height: visionRect.height * imageSize.height
    )
}
