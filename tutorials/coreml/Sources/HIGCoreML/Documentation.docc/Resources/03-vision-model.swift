import CoreML
import Vision

/// Vision에서 CoreML 모델 사용하기
///
/// VNCoreMLModel로 래핑하면 이미지 전처리가 자동 처리됩니다.
struct VisionModelSetup {
    
    /// VNCoreMLModel 생성
    func createVisionModel() throws -> VNCoreMLModel {
        // 1. CoreML 모델 로드
        let configuration = MLModelConfiguration()
        let coreMLModel = try MobileNetV2(configuration: configuration)
        
        // 2. Vision용 모델로 래핑
        let visionModel = try VNCoreMLModel(for: coreMLModel.model)
        
        return visionModel
    }
    
    /// Vision 사용의 장점
    ///
    /// 1. 자동 이미지 리사이징
    ///    - 모델이 224×224를 요구하면 자동 변환
    ///
    /// 2. 자동 색상 공간 변환
    ///    - sRGB, Display P3 등 자동 처리
    ///
    /// 3. 자동 방향 보정
    ///    - EXIF orientation 자동 적용
    ///
    /// 4. 배치 처리 지원
    ///    - 여러 이미지 동시 분석
}

// Vision 없이 직접 CoreML 사용 시 필요한 전처리 (비교용)
extension VisionModelSetup {
    
    /// 직접 전처리 (Vision 없이) - 복잡함!
    func manualPreprocessing(image: UIImage) -> CVPixelBuffer? {
        // 1. 이미지 리사이징
        let targetSize = CGSize(width: 224, height: 224)
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = resizedImage?.cgImage else { return nil }
        
        // 2. CVPixelBuffer 생성
        var pixelBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            224, 224,
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        
        guard let buffer = pixelBuffer else { return nil }
        
        // 3. 이미지 그리기
        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: 224,
            height: 224,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: 224, height: 224))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}

import UIKit
