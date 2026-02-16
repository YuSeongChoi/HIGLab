import SwiftUI

struct LandmarkOverlayView: View {
    let face: DetectedFace
    let imageSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                guard let landmarks = face.landmarks else { return }
                
                let scale = CGSize(
                    width: size.width,
                    height: size.height
                )
                
                // 눈 그리기
                drawLandmark(landmarks.leftEye, color: .blue, context: &context, face: face, scale: scale)
                drawLandmark(landmarks.rightEye, color: .blue, context: &context, face: face, scale: scale)
                
                // 눈썹 그리기
                drawLandmark(landmarks.leftEyebrow, color: .brown, context: &context, face: face, scale: scale)
                drawLandmark(landmarks.rightEyebrow, color: .brown, context: &context, face: face, scale: scale)
                
                // 코 그리기
                drawLandmark(landmarks.nose, color: .orange, context: &context, face: face, scale: scale)
                
                // 입 그리기
                drawLandmark(landmarks.outerLips, color: .red, context: &context, face: face, scale: scale)
            }
        }
    }
    
    private func drawLandmark(
        _ points: [CGPoint],
        color: Color,
        context: inout GraphicsContext,
        face: DetectedFace,
        scale: CGSize
    ) {
        for point in points {
            // 랜드마크 포인트 → 화면 좌표 변환
            let x = (face.boundingBox.origin.x + point.x * face.boundingBox.width) * scale.width
            let y = (1 - (face.boundingBox.origin.y + point.y * face.boundingBox.height)) * scale.height
            
            let rect = CGRect(x: x - 2, y: y - 2, width: 4, height: 4)
            context.fill(Path(ellipseIn: rect), with: .color(color))
        }
    }
}
