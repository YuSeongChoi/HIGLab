import SwiftUI

struct BarcodeOverlayView: View {
    let barcodes: [ScannedBarcode]
    let imageSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(barcodes) { barcode in
                let rect = convertRect(barcode.boundingBox, in: geometry.size)
                
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.yellow, lineWidth: 2)
                    .background(Color.yellow.opacity(0.1))
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                
                Text(barcode.symbologyName)
                    .font(.caption2)
                    .padding(2)
                    .background(Color.yellow)
                    .position(x: rect.midX, y: rect.minY - 10)
            }
        }
    }
    
    private func convertRect(_ normalizedRect: CGRect, in size: CGSize) -> CGRect {
        CGRect(
            x: normalizedRect.minX * size.width,
            y: (1 - normalizedRect.maxY) * size.height,
            width: normalizedRect.width * size.width,
            height: normalizedRect.height * size.height
        )
    }
}
