import Vision
import UIKit

/// VNImageRequestHandler로 요청 실행
///
/// 다양한 이미지 소스를 지원합니다.
struct RequestHandlerExamples {
    
    // MARK: - CGImage에서
    func classifyFromCGImage(cgImage: CGImage, request: VNCoreMLRequest) throws {
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: .up,  // EXIF orientation
            options: [:]
        )
        try handler.perform([request])
    }
    
    // MARK: - CIImage에서
    func classifyFromCIImage(ciImage: CIImage, request: VNCoreMLRequest) throws {
        let handler = VNImageRequestHandler(
            ciImage: ciImage,
            options: [:]
        )
        try handler.perform([request])
    }
    
    // MARK: - URL에서
    func classifyFromURL(url: URL, request: VNCoreMLRequest) throws {
        let handler = VNImageRequestHandler(
            url: url,
            options: [:]
        )
        try handler.perform([request])
    }
    
    // MARK: - Data에서
    func classifyFromData(data: Data, request: VNCoreMLRequest) throws {
        let handler = VNImageRequestHandler(
            data: data,
            options: [:]
        )
        try handler.perform([request])
    }
    
    // MARK: - CVPixelBuffer에서 (카메라 프레임)
    func classifyFromPixelBuffer(
        pixelBuffer: CVPixelBuffer,
        request: VNCoreMLRequest
    ) throws {
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .right,  // 카메라 방향
            options: [:]
        )
        try handler.perform([request])
    }
    
    // MARK: - UIImage에서 (실용적인 예시)
    func classifyFromUIImage(image: UIImage, request: VNCoreMLRequest) throws {
        guard let cgImage = image.cgImage else {
            throw ClassificationError.invalidResults
        }
        
        // UIImage의 orientation을 Vision orientation으로 변환
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: orientation,
            options: [:]
        )
        try handler.perform([request])
    }
}

// MARK: - Orientation 변환 헬퍼
extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
