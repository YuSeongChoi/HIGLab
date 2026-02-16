import Vision

extension BarcodeScanner {
    
    /// 특정 바코드 형식만 감지
    func detectBarcodes(
        in image: UIImage,
        symbologies: [VNBarcodeSymbology]
    ) async throws -> [VNBarcodeObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        let request = VNDetectBarcodesRequest()
        
        // 감지할 바코드 형식 지정
        // 필요한 형식만 지정하면 성능 향상
        request.symbologies = symbologies
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        
        return request.results ?? []
    }
    
    // 일반적인 바코드 형식
    static let retailSymbologies: [VNBarcodeSymbology] = [
        .ean13,    // 상품 바코드
        .ean8,     // 짧은 상품 바코드
        .upce,     // 미국 상품 바코드
        .code128,  // 물류/택배
        .code39    // 산업용
    ]
    
    // 2D 바코드 형식
    static let twoDimensionalSymbologies: [VNBarcodeSymbology] = [
        .qr,       // QR코드
        .pdf417,   // PDF417
        .dataMatrix,// Data Matrix
        .aztec     // Aztec
    ]
}
