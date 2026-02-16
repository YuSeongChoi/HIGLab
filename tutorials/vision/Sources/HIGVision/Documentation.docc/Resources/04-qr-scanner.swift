import Vision
import UIKit

final class QRScanner {
    
    func scanQRCodes(in image: UIImage) async throws -> [VNBarcodeObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        let request = VNDetectBarcodesRequest()
        // QR코드만 감지
        request.symbologies = [.qr]
        
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: image.cgImageOrientation,
            options: [:]
        )
        
        try handler.perform([request])
        
        return request.results ?? []
    }
}
