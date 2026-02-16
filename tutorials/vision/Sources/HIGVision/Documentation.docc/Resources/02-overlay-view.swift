import SwiftUI

struct ImageWithOverlay: View {
    let image: UIImage
    let boundingBoxes: [CGRect]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 원본 이미지
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                
                // 바운딩 박스 오버레이
                ForEach(Array(boundingBoxes.enumerated()), id: \.offset) { _, box in
                    Rectangle()
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(
                            width: box.width * geometry.size.width,
                            height: box.height * geometry.size.height
                        )
                        .position(
                            x: box.midX * geometry.size.width,
                            y: (1 - box.midY) * geometry.size.height
                        )
                }
            }
        }
    }
}

struct BoundingBoxOverlay: View {
    let boxes: [CGRect]
    let imageSize: CGSize
    
    var body: some View {
        Canvas { context, size in
            let scaleX = size.width / imageSize.width
            let scaleY = size.height / imageSize.height
            
            for box in boxes {
                // Vision 좌표 → SwiftUI 좌표
                let rect = CGRect(
                    x: box.minX * size.width,
                    y: (1 - box.maxY) * size.height,
                    width: box.width * size.width,
                    height: box.height * size.height
                )
                
                let path = Path(roundedRect: rect, cornerRadius: 4)
                context.stroke(path, with: .color(.blue), lineWidth: 2)
            }
        }
    }
}
