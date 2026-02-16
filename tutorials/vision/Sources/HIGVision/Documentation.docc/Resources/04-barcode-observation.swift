import Vision

extension BarcodeScanner {
    
    func processObservations(_ observations: [VNBarcodeObservation]) -> [ScannedBarcode] {
        return observations.compactMap { observation in
            // 바코드 값 추출
            guard let payload = observation.payloadStringValue else {
                return nil
            }
            
            return ScannedBarcode(
                value: payload,
                symbology: observation.symbology,
                boundingBox: observation.boundingBox,
                confidence: observation.confidence
            )
        }
    }
}
