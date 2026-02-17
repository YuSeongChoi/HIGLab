// ExtensibleImageWrapper.swift
// SmartCrop - HIG Lab 샘플 프로젝트
// iOS 26 ExtensibleImage API 래퍼

import UIKit
import ExtensibleImage

// MARK: - 피사체 분석기

/// ExtensibleImage의 피사체 분석 기능을 래핑하는 클래스
/// 이미지에서 주요 피사체를 감지하고 영역을 반환합니다
final class ImageSubjectAnalyzer {
    /// 내부 분석기
    private let analyzer: SubjectAnalyzer
    
    /// 초기화
    /// - Throws: API 사용 불가 시 오류
    init() throws {
        // iOS 26의 ExtensibleImage SubjectAnalyzer 초기화
        guard #available(iOS 26, *) else {
            throw ProcessingError.apiUnavailable
        }
        
        self.analyzer = SubjectAnalyzer()
    }
    
    /// 이미지에서 피사체 영역 분석
    /// - Parameter image: 분석할 이미지
    /// - Returns: 피사체 영역 (없으면 nil)
    @available(iOS 26, *)
    func analyzeSubject(in image: UIImage) async throws -> CGRect? {
        guard let cgImage = image.cgImage else {
            throw ProcessingError.loadFailed
        }
        
        // ExtensibleImage API를 사용한 피사체 감지
        let result = try await analyzer.analyze(cgImage)
        
        // 피사체 영역 반환
        guard let subjectRect = result.primarySubjectBounds else {
            return nil
        }
        
        // CGImage 좌표를 UIImage 좌표로 변환
        let normalizedRect = CGRect(
            x: subjectRect.origin.x / CGFloat(cgImage.width),
            y: subjectRect.origin.y / CGFloat(cgImage.height),
            width: subjectRect.width / CGFloat(cgImage.width),
            height: subjectRect.height / CGFloat(cgImage.height)
        )
        
        return normalizedRect.denormalized(for: image.size)
    }
    
    /// 여러 피사체 영역 분석
    /// - Parameter image: 분석할 이미지
    /// - Returns: 감지된 모든 피사체 영역 배열
    @available(iOS 26, *)
    func analyzeAllSubjects(in image: UIImage) async throws -> [CGRect] {
        guard let cgImage = image.cgImage else {
            throw ProcessingError.loadFailed
        }
        
        let result = try await analyzer.analyze(cgImage)
        
        // 모든 피사체 영역을 UIImage 좌표로 변환
        return result.allSubjectBounds.map { rect in
            let normalized = CGRect(
                x: rect.origin.x / CGFloat(cgImage.width),
                y: rect.origin.y / CGFloat(cgImage.height),
                width: rect.width / CGFloat(cgImage.width),
                height: rect.height / CGFloat(cgImage.height)
            )
            return normalized.denormalized(for: image.size)
        }
    }
}

// MARK: - 배경 제거기

/// ExtensibleImage의 배경 제거 기능을 래핑하는 클래스
/// 피사체를 추출하고 배경을 투명하게 만듭니다
final class BackgroundRemover {
    /// 내부 제거기
    private let remover: ImageMasker
    
    /// 출력 형식
    enum OutputFormat {
        case rgba       // 투명 배경 (PNG)
        case whiteBackground  // 흰색 배경
        case customColor(UIColor)  // 사용자 지정 색상
    }
    
    /// 초기화
    /// - Throws: API 사용 불가 시 오류
    init() throws {
        guard #available(iOS 26, *) else {
            throw ProcessingError.apiUnavailable
        }
        
        self.remover = ImageMasker()
    }
    
    /// 배경 제거 수행
    /// - Parameters:
    ///   - image: 원본 이미지
    ///   - outputFormat: 출력 형식
    /// - Returns: 배경이 제거된 이미지
    @available(iOS 26, *)
    func removeBackground(
        from image: UIImage,
        outputFormat: OutputFormat = .rgba
    ) async throws -> UIImage {
        guard let cgImage = image.cgImage else {
            throw ProcessingError.loadFailed
        }
        
        // ExtensibleImage API로 마스크 생성
        let mask = try await remover.createSubjectMask(for: cgImage)
        
        // 마스크 적용하여 배경 제거
        let resultImage = try applyMask(mask, to: cgImage, format: outputFormat)
        
        return UIImage(
            cgImage: resultImage,
            scale: image.scale,
            orientation: image.imageOrientation
        )
    }
    
    /// 마스크 적용
    private func applyMask(
        _ mask: CGImage,
        to image: CGImage,
        format: OutputFormat
    ) throws -> CGImage {
        let width = image.width
        let height = image.height
        
        // RGBA 컬러 스페이스 생성
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw ProcessingError.backgroundRemovalFailed
        }
        
        // 비트맵 컨텍스트 생성
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw ProcessingError.backgroundRemovalFailed
        }
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        // 배경 색상 적용 (필요한 경우)
        switch format {
        case .rgba:
            // 투명 배경 - 아무것도 그리지 않음
            break
        case .whiteBackground:
            context.setFillColor(UIColor.white.cgColor)
            context.fill(rect)
        case .customColor(let color):
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
        
        // 마스크를 클리핑 영역으로 설정
        context.clip(to: rect, mask: mask)
        
        // 원본 이미지 그리기
        context.draw(image, in: rect)
        
        // 결과 이미지 생성
        guard let result = context.makeImage() else {
            throw ProcessingError.backgroundRemovalFailed
        }
        
        return result
    }
}

// MARK: - 이미지 확장기

/// ExtensibleImage의 이미지 확장(아웃페인팅) 기능을 래핑하는 클래스
/// 이미지 영역을 자연스럽게 확장합니다
final class ImageExtender {
    /// 내부 확장기
    private let extender: ImageOutpainter
    
    /// 블렌드 모드
    enum BlendMode {
        case seamless   // 자연스러운 블렌딩
        case sharp      // 경계 유지
    }
    
    /// 초기화
    /// - Throws: API 사용 불가 시 오류
    init() throws {
        guard #available(iOS 26, *) else {
            throw ProcessingError.apiUnavailable
        }
        
        self.extender = ImageOutpainter()
    }
    
    /// 이미지 확장 수행
    /// - Parameters:
    ///   - image: 원본 이미지
    ///   - configuration: 확장 설정
    /// - Returns: 확장된 이미지
    @available(iOS 26, *)
    func extend(
        image: UIImage,
        configuration: ImageExtensionConfiguration
    ) async throws -> UIImage {
        guard let cgImage = image.cgImage else {
            throw ProcessingError.loadFailed
        }
        
        // 새 캔버스 크기 계산
        let originalSize = image.size
        let newWidth = originalSize.width * (1 + configuration.leftPadding + configuration.rightPadding)
        let newHeight = originalSize.height * (1 + configuration.topPadding + configuration.bottomPadding)
        
        // 원본 이미지 위치 계산
        let originX = originalSize.width * configuration.leftPadding
        let originY = originalSize.height * configuration.topPadding
        
        // ExtensibleImage API로 아웃페인팅 수행
        let outpaintConfig = OutpaintConfiguration(
            targetSize: CGSize(width: newWidth, height: newHeight),
            originalImageRect: CGRect(
                x: originX,
                y: originY,
                width: originalSize.width,
                height: originalSize.height
            ),
            blendRadius: configuration.blendMode == .seamless ? 20 : 5
        )
        
        let extendedCGImage = try await extender.outpaint(
            image: cgImage,
            configuration: outpaintConfig
        )
        
        return UIImage(
            cgImage: extendedCGImage,
            scale: image.scale,
            orientation: image.imageOrientation
        )
    }
}

// MARK: - 이미지 확장 설정

/// 이미지 확장을 위한 설정
struct ImageExtensionConfiguration {
    /// 상단 확장 비율
    var topPadding: CGFloat
    
    /// 하단 확장 비율
    var bottomPadding: CGFloat
    
    /// 좌측 확장 비율
    var leftPadding: CGFloat
    
    /// 우측 확장 비율
    var rightPadding: CGFloat
    
    /// 블렌드 모드
    var blendMode: ImageExtender.BlendMode
    
    init(
        topPadding: CGFloat = 0.2,
        bottomPadding: CGFloat = 0.2,
        leftPadding: CGFloat = 0.2,
        rightPadding: CGFloat = 0.2,
        blendMode: ImageExtender.BlendMode = .seamless
    ) {
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        self.leftPadding = leftPadding
        self.rightPadding = rightPadding
        self.blendMode = blendMode
    }
}

// MARK: - ExtensibleImage API 스텁

// 실제 iOS 26 ExtensibleImage 프레임워크가 출시되면
// 아래 스텁은 실제 API로 대체됩니다

/// 피사체 분석기 (ExtensibleImage API)
@available(iOS 26, *)
struct SubjectAnalyzer {
    struct AnalysisResult {
        var primarySubjectBounds: CGRect?
        var allSubjectBounds: [CGRect]
    }
    
    func analyze(_ image: CGImage) async throws -> AnalysisResult {
        // 실제 구현은 ExtensibleImage 프레임워크에서 제공
        // 여기서는 중앙 영역을 피사체로 가정하는 시뮬레이션
        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        
        let subjectRect = CGRect(
            x: width * 0.2,
            y: height * 0.2,
            width: width * 0.6,
            height: height * 0.6
        )
        
        return AnalysisResult(
            primarySubjectBounds: subjectRect,
            allSubjectBounds: [subjectRect]
        )
    }
}

/// 이미지 마스커 (ExtensibleImage API)
@available(iOS 26, *)
struct ImageMasker {
    func createSubjectMask(for image: CGImage) async throws -> CGImage {
        // 실제 구현은 ExtensibleImage 프레임워크에서 제공
        // 여기서는 전체 영역을 마스크로 반환하는 시뮬레이션
        return image
    }
}

/// 이미지 아웃페인터 (ExtensibleImage API)
@available(iOS 26, *)
struct ImageOutpainter {
    struct OutpaintConfiguration {
        var targetSize: CGSize
        var originalImageRect: CGRect
        var blendRadius: CGFloat
    }
    
    func outpaint(
        image: CGImage,
        configuration: OutpaintConfiguration
    ) async throws -> CGImage {
        // 실제 구현은 ExtensibleImage 프레임워크에서 제공
        // 여기서는 원본 이미지를 새 캔버스에 배치하는 시뮬레이션
        
        let width = Int(configuration.targetSize.width)
        let height = Int(configuration.targetSize.height)
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ) else {
            throw ProcessingError.extensionFailed
        }
        
        // 배경색 채우기
        context.setFillColor(UIColor.systemGray5.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        
        // 원본 이미지 그리기
        context.draw(image, in: configuration.originalImageRect)
        
        guard let result = context.makeImage() else {
            throw ProcessingError.extensionFailed
        }
        
        return result
    }
}
