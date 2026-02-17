//
//  ImageProcessor.swift
//  VisionScanner
//
//  이미지 변환 및 처리 유틸리티
//

import Foundation
import UIKit
import CoreImage

// MARK: - 이미지 프로세서

/// 이미지 전처리 및 변환을 담당하는 유틸리티
struct ImageProcessor {
    
    // MARK: - 이미지 크기 조정
    
    /// 이미지를 지정된 최대 크기에 맞게 리사이즈합니다
    /// Vision 처리 전 이미지 크기를 줄여 성능을 향상시킵니다
    /// - Parameters:
    ///   - image: 원본 이미지
    ///   - maxDimension: 가로/세로 중 큰 쪽의 최대 크기
    /// - Returns: 리사이즈된 이미지
    static func resize(_ image: UIImage, maxDimension: CGFloat = 2048) -> UIImage {
        let size = image.size
        
        // 이미 충분히 작으면 그대로 반환
        guard size.width > maxDimension || size.height > maxDimension else {
            return image
        }
        
        // 비율 유지하며 크기 계산
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // 이미지 렌더링
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    // MARK: - 이미지 회전 보정
    
    /// 이미지의 EXIF 방향 정보를 적용하여 올바른 방향으로 회전시킵니다
    /// - Parameter image: 원본 이미지
    /// - Returns: 방향이 보정된 이미지
    static func fixOrientation(_ image: UIImage) -> UIImage {
        // 이미 올바른 방향이면 그대로 반환
        guard image.imageOrientation != .up else { return image }
        
        // 새 이미지 컨텍스트에서 올바른 방향으로 다시 그리기
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in
            image.draw(at: .zero)
        }
    }
    
    // MARK: - 그레이스케일 변환
    
    /// 이미지를 그레이스케일로 변환합니다
    /// OCR 성능 향상에 도움이 될 수 있습니다
    /// - Parameter image: 원본 이미지
    /// - Returns: 그레이스케일 이미지
    static func convertToGrayscale(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        
        // 그레이스케일 필터 적용
        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)  // 채도를 0으로
        
        guard let outputImage = filter.outputImage,
              let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    // MARK: - 대비 향상
    
    /// 이미지의 대비를 향상시킵니다
    /// 텍스트 인식률 향상에 도움이 됩니다
    /// - Parameters:
    ///   - image: 원본 이미지
    ///   - contrast: 대비 값 (1.0 = 원본, 1.5 = 50% 증가)
    /// - Returns: 대비가 조정된 이미지
    static func enhanceContrast(_ image: UIImage, contrast: Float = 1.3) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        
        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(contrast, forKey: kCIInputContrastKey)
        
        guard let outputImage = filter.outputImage,
              let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    // MARK: - 이진화 (흑백 변환)
    
    /// 이미지를 흑백 이진화합니다
    /// 바코드 인식률 향상에 도움이 됩니다
    /// - Parameters:
    ///   - image: 원본 이미지
    ///   - threshold: 임계값 (0.0 ~ 1.0)
    /// - Returns: 이진화된 이미지
    static func binarize(_ image: UIImage, threshold: Float = 0.5) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        
        // 먼저 그레이스케일로 변환
        guard let monoFilter = CIFilter(name: "CIColorMonochrome") else { return nil }
        monoFilter.setValue(ciImage, forKey: kCIInputImageKey)
        monoFilter.setValue(CIColor(red: 0.5, green: 0.5, blue: 0.5), forKey: kCIInputColorKey)
        monoFilter.setValue(1.0, forKey: kCIInputIntensityKey)
        
        guard let monoOutput = monoFilter.outputImage else { return nil }
        
        // 임계값 적용하여 이진화
        guard let thresholdFilter = CIFilter(name: "CIColorThreshold") else {
            // iOS 17 미만에서는 CIColorThreshold가 없을 수 있음
            // 대비를 극대화하여 대체
            guard let contrastFilter = CIFilter(name: "CIColorControls") else { return nil }
            contrastFilter.setValue(monoOutput, forKey: kCIInputImageKey)
            contrastFilter.setValue(4.0, forKey: kCIInputContrastKey)  // 극단적 대비
            
            guard let outputImage = contrastFilter.outputImage,
                  let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return nil
            }
            return UIImage(cgImage: outputCGImage)
        }
        
        thresholdFilter.setValue(monoOutput, forKey: kCIInputImageKey)
        thresholdFilter.setValue(threshold, forKey: "inputThreshold")
        
        guard let outputImage = thresholdFilter.outputImage,
              let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    // MARK: - 이미지 자르기
    
    /// 이미지의 특정 영역을 자릅니다
    /// - Parameters:
    ///   - image: 원본 이미지
    ///   - normalizedRect: 정규화된 좌표의 영역 (0.0 ~ 1.0)
    /// - Returns: 잘린 이미지
    static func crop(_ image: UIImage, to normalizedRect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        
        // 정규화된 좌표를 실제 픽셀 좌표로 변환
        // Vision 좌표계는 좌하단이 원점이므로 Y축 변환 필요
        let cropRect = CGRect(
            x: normalizedRect.origin.x * imageSize.width,
            y: (1 - normalizedRect.origin.y - normalizedRect.height) * imageSize.height,
            width: normalizedRect.width * imageSize.width,
            height: normalizedRect.height * imageSize.height
        )
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }
        
        return UIImage(cgImage: croppedCGImage)
    }
    
    // MARK: - 전처리 파이프라인
    
    /// OCR을 위한 이미지 전처리를 수행합니다
    /// - Parameter image: 원본 이미지
    /// - Returns: 전처리된 이미지
    static func preprocessForOCR(_ image: UIImage) -> UIImage {
        var processed = fixOrientation(image)
        processed = resize(processed, maxDimension: 2048)
        
        // 대비 향상 (선택적)
        if let enhanced = enhanceContrast(processed, contrast: 1.2) {
            processed = enhanced
        }
        
        return processed
    }
    
    /// 바코드 스캔을 위한 이미지 전처리를 수행합니다
    /// - Parameter image: 원본 이미지
    /// - Returns: 전처리된 이미지
    static func preprocessForBarcode(_ image: UIImage) -> UIImage {
        var processed = fixOrientation(image)
        processed = resize(processed, maxDimension: 1024)  // 바코드는 더 작아도 됨
        
        return processed
    }
    
    /// 얼굴 인식을 위한 이미지 전처리를 수행합니다
    /// - Parameter image: 원본 이미지
    /// - Returns: 전처리된 이미지
    static func preprocessForFaceDetection(_ image: UIImage) -> UIImage {
        var processed = fixOrientation(image)
        processed = resize(processed, maxDimension: 1280)
        
        return processed
    }
}

// MARK: - UIImage 확장

extension UIImage {
    
    /// Vision 분석을 위해 이미지 방향을 보정합니다
    var orientationCorrected: UIImage {
        ImageProcessor.fixOrientation(self)
    }
    
    /// 이미지를 Data로 변환합니다 (JPEG 형식)
    /// - Parameter compressionQuality: 압축 품질 (0.0 ~ 1.0)
    /// - Returns: JPEG 데이터
    func jpegData(compressionQuality: CGFloat = 0.8) -> Data? {
        jpegData(compressionQuality: compressionQuality)
    }
}
