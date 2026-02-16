import Vision
import UIKit

final class BarcodeScanner {
    
    func detectBarcodes(in image: UIImage) async throws -> [VNBarcodeObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        let request = VNDetectBarcodesRequest()
        
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: image.cgImageOrientation,
            options: [:]
        )
        
        try handler.perform([request])
        
        return request.results ?? []
    }
}
