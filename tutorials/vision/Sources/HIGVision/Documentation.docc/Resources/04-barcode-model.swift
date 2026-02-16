import Foundation
import Vision
import CoreGraphics

struct ScannedBarcode: Identifiable {
    let id = UUID()
    let value: String
    let symbology: VNBarcodeSymbology
    let boundingBox: CGRect
    let confidence: VNConfidence
    
    var symbologyName: String {
        switch symbology {
        case .qr: return "QR코드"
        case .ean13: return "EAN-13"
        case .ean8: return "EAN-8"
        case .code128: return "Code 128"
        case .code39: return "Code 39"
        case .pdf417: return "PDF417"
        case .upce: return "UPC-E"
        case .aztec: return "Aztec"
        case .dataMatrix: return "Data Matrix"
        default: return "기타"
        }
    }
}
