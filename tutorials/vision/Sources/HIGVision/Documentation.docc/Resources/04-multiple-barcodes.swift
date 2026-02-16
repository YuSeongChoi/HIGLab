import Vision
import UIKit

extension BarcodeScanner {
    
    /// 모든 바코드 감지 (형식 제한 없음)
    func detectAllBarcodes(in image: UIImage) async throws -> [ScannedBarcode] {
        let observations = try await detectBarcodes(in: image)
        return processObservations(observations)
    }
    
    /// 바코드 개수 확인
    func countBarcodes(in image: UIImage) async throws -> Int {
        let observations = try await detectBarcodes(in: image)
        return observations.count
    }
}
