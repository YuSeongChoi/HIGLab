import Vision

extension BarcodeScanner {
    
    /// 위치에 따라 바코드 정렬 (위→아래, 왼쪽→오른쪽)
    func sortByPosition(_ barcodes: [ScannedBarcode]) -> [ScannedBarcode] {
        return barcodes.sorted { a, b in
            // Y 좌표로 먼저 정렬
            if abs(a.boundingBox.midY - b.boundingBox.midY) > 0.05 {
                return a.boundingBox.midY > b.boundingBox.midY
            }
            // 같은 줄이면 X 좌표로 정렬
            return a.boundingBox.minX < b.boundingBox.minX
        }
    }
    
    /// 형식별로 그룹화
    func groupBySymbology(_ barcodes: [ScannedBarcode]) -> [VNBarcodeSymbology: [ScannedBarcode]] {
        return Dictionary(grouping: barcodes) { $0.symbology }
    }
}
