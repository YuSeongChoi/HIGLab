import SwiftUI

struct FaceOverlayView: View {
    let faces: [DetectedFace]
    let imageSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(faces) { face in
                let rect = convertRect(face.boundingBox, in: geometry.size)
                
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.green, lineWidth: 3)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
    }
    
    private func convertRect(_ normalizedRect: CGRect, in size: CGSize) -> CGRect {
        // Vision 좌표 (좌하단 원점) → SwiftUI 좌표 (좌상단 원점)
        let x = normalizedRect.minX * size.width
        let y = (1 - normalizedRect.maxY) * size.height
        let width = normalizedRect.width * size.width
        let height = normalizedRect.height * size.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
