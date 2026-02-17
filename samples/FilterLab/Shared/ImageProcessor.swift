// ImageProcessor.swift
// FilterLab - Core Image 처리 엔진
// HIG Lab 샘플 프로젝트

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - 이미지 프로세서
/// Core Image를 사용하여 이미지에 필터를 적용하는 프로세서
@Observable
class ImageProcessor {
    /// 원본 이미지
    var originalImage: UIImage?
    
    /// 필터가 적용된 이미지
    var processedImage: UIImage?
    
    /// 처리 중 여부
    var isProcessing: Bool = false
    
    /// 에러 메시지
    var errorMessage: String?
    
    /// Core Image 컨텍스트 (성능을 위해 재사용)
    private let context: CIContext
    
    /// 커스텀 커널 프로세서
    private let customKernels = CustomKernels()
    
    /// 마지막 처리 시간 (디버깅용)
    var lastProcessingTime: TimeInterval = 0
    
    init() {
        // Metal 기반 컨텍스트 생성 (최적의 성능)
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            context = CIContext(mtlDevice: metalDevice, options: [
                .cacheIntermediates: false,
                .priorityRequestLow: false
            ])
        } else {
            context = CIContext(options: [
                .useSoftwareRenderer: false
            ])
        }
    }
    
    /// 이미지 설정
    func setImage(_ image: UIImage?) {
        originalImage = image
        processedImage = image
        errorMessage = nil
    }
    
    /// 필터 체인 적용
    @MainActor
    func applyFilters(chain: FilterChain) async {
        guard let originalImage = originalImage,
              let inputCIImage = CIImage(image: originalImage) else {
            errorMessage = "이미지를 로드할 수 없습니다"
            return
        }
        
        // 활성화된 필터가 없으면 원본 반환
        guard chain.hasActiveFilters else {
            processedImage = originalImage
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            // 백그라운드에서 필터 처리
            let result = try await Task.detached(priority: .userInitiated) { [weak self] in
                guard let self = self else { throw ProcessingError.cancelled }
                return try self.processFilterChain(inputImage: inputCIImage, chain: chain)
            }.value
            
            processedImage = result
            lastProcessingTime = CFAbsoluteTimeGetCurrent() - startTime
        } catch {
            errorMessage = "필터 처리 중 오류: \(error.localizedDescription)"
            processedImage = originalImage
        }
        
        isProcessing = false
    }
    
    /// 단일 필터 프리뷰 (썸네일용)
    func previewFilter(_ filterType: FilterType, on image: UIImage, size: CGSize) -> UIImage? {
        // 썸네일 크기로 리사이즈
        guard let resized = image.resized(to: size),
              let inputCIImage = CIImage(image: resized) else {
            return nil
        }
        
        let chain = FilterChain()
        chain.addFilter(filterType)
        
        do {
            return try processFilterChain(inputImage: inputCIImage, chain: chain)
        } catch {
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    /// 필터 체인 처리 (내부)
    private func processFilterChain(inputImage: CIImage, chain: FilterChain) throws -> UIImage {
        var currentImage = inputImage
        
        for node in chain.activeNodes {
            currentImage = try applyFilter(node: node, to: currentImage)
        }
        
        // CIImage를 UIImage로 변환
        guard let cgImage = context.createCGImage(currentImage, from: currentImage.extent) else {
            throw ProcessingError.renderFailed
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// 개별 필터 적용
    private func applyFilter(node: FilterNode, to inputImage: CIImage) throws -> CIImage {
        let filterType = node.filterType
        
        // 커스텀 필터 처리
        if filterType.category == .custom {
            return try applyCustomFilter(node: node, to: inputImage)
        }
        
        // 빌트인 필터 처리
        guard let filterName = filterType.ciFilterName,
              let filter = CIFilter(name: filterName) else {
            throw ProcessingError.filterNotFound(filterType.rawValue)
        }
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        // 강도 파라미터 설정
        if filterType.hasIntensity,
           let paramName = filterType.intensityParameterName {
            filter.setValue(node.intensity, forKey: paramName)
        }
        
        // 특수 파라미터 설정
        configureSpecialParameters(filter: filter, filterType: filterType, inputImage: inputImage)
        
        guard let outputImage = filter.outputImage else {
            throw ProcessingError.filterFailed(filterType.rawValue)
        }
        
        // 블러 필터의 경우 원본 크기로 크롭
        if filterType.category == .blur || filterType.category == .stylize {
            return outputImage.cropped(to: inputImage.extent)
        }
        
        return outputImage
    }
    
    /// 커스텀 필터 적용
    private func applyCustomFilter(node: FilterNode, to inputImage: CIImage) throws -> CIImage {
        switch node.filterType {
        case .customVignette:
            return customKernels.applyVignette(to: inputImage, intensity: node.intensity)
        case .customColorShift:
            return customKernels.applyColorShift(to: inputImage, intensity: node.intensity)
        default:
            throw ProcessingError.filterNotFound(node.filterType.rawValue)
        }
    }
    
    /// 특수 파라미터 설정
    private func configureSpecialParameters(filter: CIFilter, filterType: FilterType, inputImage: CIImage) {
        let center = CIVector(x: inputImage.extent.midX, y: inputImage.extent.midY)
        
        switch filterType {
        case .colorMonochrome:
            // 흑백의 경우 회색 사용
            filter.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: kCIInputColorKey)
            
        case .vignette:
            filter.setValue(inputImage.extent.width / 2, forKey: kCIInputRadiusKey)
            
        case .vignetteEffect:
            filter.setValue(center, forKey: kCIInputCenterKey)
            filter.setValue(inputImage.extent.width / 2, forKey: kCIInputRadiusKey)
            
        case .motionBlur:
            filter.setValue(0, forKey: kCIInputAngleKey) // 수평 방향
            
        case .zoomBlur:
            filter.setValue(center, forKey: kCIInputCenterKey)
            
        case .bloom, .gloom:
            filter.setValue(10, forKey: kCIInputRadiusKey)
            
        case .crystallize, .pixellate, .pointillize:
            filter.setValue(center, forKey: kCIInputCenterKey)
            
        case .bumpDistortion, .twirlDistortion, .pinchDistortion:
            filter.setValue(center, forKey: kCIInputCenterKey)
            if filterType == .twirlDistortion {
                filter.setValue(Float.pi, forKey: kCIInputAngleKey)
            }
            if filterType == .pinchDistortion {
                filter.setValue(0.5, forKey: kCIInputScaleKey)
            }
            
        case .circularWrap:
            filter.setValue(center, forKey: kCIInputCenterKey)
            filter.setValue(Float.pi, forKey: kCIInputAngleKey)
            
        default:
            break
        }
    }
    
    /// 이미지 저장
    func saveToPhotoLibrary(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let imageToSave = processedImage else {
            completion(.failure(ProcessingError.noImageToSave))
            return
        }
        
        let imageSaver = ImageSaver()
        imageSaver.saveToPhotoLibrary(imageToSave, completion: completion)
    }
    
    /// 이미지 초기화
    func reset() {
        processedImage = originalImage
        errorMessage = nil
    }
}

// MARK: - 처리 에러
enum ProcessingError: LocalizedError {
    case filterNotFound(String)
    case filterFailed(String)
    case renderFailed
    case noImageToSave
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .filterNotFound(let name):
            return "필터를 찾을 수 없습니다: \(name)"
        case .filterFailed(let name):
            return "필터 적용 실패: \(name)"
        case .renderFailed:
            return "이미지 렌더링 실패"
        case .noImageToSave:
            return "저장할 이미지가 없습니다"
        case .cancelled:
            return "작업이 취소되었습니다"
        }
    }
}

// MARK: - 이미지 저장 헬퍼
class ImageSaver: NSObject {
    private var completion: ((Result<Void, Error>) -> Void)?
    
    func saveToPhotoLibrary(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        self.completion = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        if let error = error {
            completion?(.failure(error))
        } else {
            completion?(.success(()))
        }
        completion = nil
    }
}

// MARK: - UIImage 확장
extension UIImage {
    /// 지정된 크기로 리사이즈
    func resized(to targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
