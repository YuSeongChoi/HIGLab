// ImageProcessingModel.swift
// SmartCrop - HIG Lab 샘플 프로젝트
// iOS 26 ExtensibleImage API 활용

import SwiftUI
import ExtensibleImage
import Observation

/// 이미지 처리를 담당하는 핵심 모델
/// ExtensibleImage API를 사용하여 스마트 크롭, 배경 제거, 이미지 확장을 수행합니다
@Observable
@MainActor
final class ImageProcessingModel {
    // MARK: - 속성
    
    /// 원본 이미지
    var originalImage: UIImage?
    
    /// 처리된 결과 이미지
    var processedImage: UIImage?
    
    /// 현재 처리 상태
    var state: ProcessingState = .idle
    
    /// 선택된 처리 모드
    var selectedMode: ProcessingMode = .smartCrop
    
    /// 이미지 확장 시 확장할 방향 및 크기
    var extensionSettings = ExtensionSettings()
    
    /// 처리 히스토리 (실행 취소용)
    private var history: [UIImage] = []
    
    /// 최대 히스토리 개수
    private let maxHistoryCount = 10
    
    // MARK: - 계산 속성
    
    /// 원본 이미지가 로드되었는지 여부
    var hasOriginalImage: Bool {
        originalImage != nil
    }
    
    /// 결과 이미지가 있는지 여부
    var hasProcessedImage: Bool {
        processedImage != nil
    }
    
    /// 실행 취소 가능 여부
    var canUndo: Bool {
        !history.isEmpty
    }
    
    // MARK: - 공개 메서드
    
    /// 이미지 로드
    /// - Parameter image: 로드할 UIImage
    func loadImage(_ image: UIImage) {
        originalImage = image
        processedImage = nil
        history.removeAll()
        state = .idle
    }
    
    /// 현재 선택된 모드로 이미지 처리 시작
    func processImage() async {
        guard let original = originalImage else {
            state = .failed(.loadFailed)
            return
        }
        
        // 현재 결과를 히스토리에 저장
        if let current = processedImage {
            addToHistory(current)
        }
        
        switch selectedMode {
        case .smartCrop:
            await performSmartCrop(on: original)
        case .removeBackground:
            await performBackgroundRemoval(on: original)
        case .extend:
            await performImageExtension(on: original)
        }
    }
    
    /// 스마트 크롭 수행
    /// ExtensibleImage의 피사체 감지 기능을 사용합니다
    /// - Parameter image: 처리할 이미지
    private func performSmartCrop(on image: UIImage) async {
        state = .analyzingSubject
        
        do {
            // ExtensibleImage API를 사용한 피사체 감지
            let processor = try ImageSubjectAnalyzer()
            
            state = .croppingSubject
            
            // 피사체 영역 분석
            let subjectBounds = try await processor.analyzeSubject(in: image)
            
            guard let bounds = subjectBounds else {
                state = .failed(.noSubjectFound)
                return
            }
            
            // 크롭 영역 계산 (피사체 주변에 여백 추가)
            let cropRect = calculateCropRect(
                subjectBounds: bounds,
                imageSize: image.size,
                padding: 0.1 // 10% 여백
            )
            
            // 이미지 크롭 수행
            if let croppedImage = cropImage(image, to: cropRect) {
                processedImage = croppedImage
                state = .completed
            } else {
                state = .failed(.unknown("크롭 처리 실패"))
            }
            
        } catch {
            state = .failed(.noSubjectFound)
        }
    }
    
    /// 배경 제거 수행
    /// ExtensibleImage의 배경 제거 기능을 사용합니다
    /// - Parameter image: 처리할 이미지
    private func performBackgroundRemoval(on image: UIImage) async {
        state = .analyzingSubject
        
        do {
            // ExtensibleImage API를 사용한 배경 제거
            let remover = try BackgroundRemover()
            
            state = .removingBackground
            
            // 배경 제거 수행 (투명 배경)
            let result = try await remover.removeBackground(
                from: image,
                outputFormat: .rgba
            )
            
            processedImage = result
            state = .completed
            
        } catch {
            state = .failed(.backgroundRemovalFailed)
        }
    }
    
    /// 이미지 확장 (아웃페인팅) 수행
    /// ExtensibleImage의 이미지 확장 기능을 사용합니다
    /// - Parameter image: 처리할 이미지
    private func performImageExtension(on image: UIImage) async {
        state = .analyzingSubject
        
        do {
            // ExtensibleImage API를 사용한 이미지 확장
            let extender = try ImageExtender()
            
            state = .extending
            
            // 확장 설정 적용
            let config = ImageExtensionConfiguration(
                topPadding: extensionSettings.topPadding,
                bottomPadding: extensionSettings.bottomPadding,
                leftPadding: extensionSettings.leftPadding,
                rightPadding: extensionSettings.rightPadding,
                blendMode: .seamless
            )
            
            // 이미지 확장 수행
            let extendedImage = try await extender.extend(
                image: image,
                configuration: config
            )
            
            processedImage = extendedImage
            state = .completed
            
        } catch {
            state = .failed(.extensionFailed)
        }
    }
    
    /// 실행 취소
    func undo() {
        guard let previousImage = history.popLast() else { return }
        processedImage = previousImage
    }
    
    /// 모든 처리 초기화
    func reset() {
        processedImage = nil
        history.removeAll()
        state = .idle
    }
    
    /// 원본으로 복원
    func restoreOriginal() {
        processedImage = nil
        history.removeAll()
        state = .idle
    }
    
    // MARK: - 비공개 메서드
    
    /// 히스토리에 이미지 추가
    private func addToHistory(_ image: UIImage) {
        history.append(image)
        // 최대 개수 초과 시 가장 오래된 항목 제거
        if history.count > maxHistoryCount {
            history.removeFirst()
        }
    }
    
    /// 크롭 영역 계산
    /// - Parameters:
    ///   - subjectBounds: 피사체 영역
    ///   - imageSize: 전체 이미지 크기
    ///   - padding: 여백 비율 (0.0 ~ 1.0)
    /// - Returns: 크롭할 CGRect
    private func calculateCropRect(
        subjectBounds: CGRect,
        imageSize: CGSize,
        padding: CGFloat
    ) -> CGRect {
        // 피사체 크기에 비례한 패딩 계산
        let paddingX = subjectBounds.width * padding
        let paddingY = subjectBounds.height * padding
        
        // 패딩을 포함한 크롭 영역
        var cropRect = subjectBounds.insetBy(dx: -paddingX, dy: -paddingY)
        
        // 이미지 범위 내로 제한
        cropRect = cropRect.intersection(
            CGRect(origin: .zero, size: imageSize)
        )
        
        return cropRect
    }
    
    /// 이미지 크롭 수행
    /// - Parameters:
    ///   - image: 원본 이미지
    ///   - rect: 크롭할 영역
    /// - Returns: 크롭된 이미지
    private func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
        // CGImage 스케일 보정
        let scale = image.scale
        let scaledRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.width * scale,
            height: rect.height * scale
        )
        
        guard let cgImage = image.cgImage,
              let croppedCGImage = cgImage.cropping(to: scaledRect) else {
            return nil
        }
        
        return UIImage(
            cgImage: croppedCGImage,
            scale: scale,
            orientation: image.imageOrientation
        )
    }
}

/// 이미지 확장 설정
struct ExtensionSettings {
    /// 상단 확장 비율 (0.0 ~ 1.0)
    var topPadding: CGFloat = 0.2
    
    /// 하단 확장 비율
    var bottomPadding: CGFloat = 0.2
    
    /// 좌측 확장 비율
    var leftPadding: CGFloat = 0.2
    
    /// 우측 확장 비율
    var rightPadding: CGFloat = 0.2
    
    /// 균등 확장 설정
    mutating func setUniform(_ value: CGFloat) {
        topPadding = value
        bottomPadding = value
        leftPadding = value
        rightPadding = value
    }
    
    /// 세로 확장만 설정
    mutating func setVertical(_ value: CGFloat) {
        topPadding = value
        bottomPadding = value
        leftPadding = 0
        rightPadding = 0
    }
    
    /// 가로 확장만 설정
    mutating func setHorizontal(_ value: CGFloat) {
        topPadding = 0
        bottomPadding = 0
        leftPadding = value
        rightPadding = value
    }
}
