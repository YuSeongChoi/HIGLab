import Photos
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - 사진 편집 서비스
/// PHContentEditingInput/Output을 사용한 비파괴 사진 편집 서비스
/// Core Image 필터를 활용한 다양한 편집 기능 제공
@MainActor
final class PhotoEditingService: ObservableObject {
    
    // MARK: - 싱글톤
    
    static let shared = PhotoEditingService()
    
    // MARK: - Core Image 컨텍스트
    
    /// GPU 가속을 사용하는 CIContext
    private let ciContext: CIContext = {
        let options: [CIContextOption: Any] = [
            .useSoftwareRenderer: false,
            .highQualityDownsample: true
        ]
        return CIContext(options: options)
    }()
    
    // MARK: - 편집 상태
    
    /// 현재 편집 중인 에셋
    @Published private(set) var currentAsset: PHAsset?
    
    /// 현재 편집 입력
    @Published private(set) var editingInput: PHContentEditingInput?
    
    /// 원본 이미지
    @Published private(set) var originalImage: CIImage?
    
    /// 편집된 이미지
    @Published private(set) var editedImage: CIImage?
    
    /// 적용된 편집 항목들
    @Published var adjustments = EditAdjustments()
    
    /// 로딩 상태
    @Published private(set) var isLoading = false
    
    /// 편집 가능 여부
    @Published private(set) var canEdit = false
    
    // MARK: - 초기화
    
    private init() {}
    
    // MARK: - 편집 세션 관리
    
    /// 편집 세션 시작
    /// - Parameter asset: 편집할 에셋
    /// - Returns: 성공 여부
    func startEditing(asset: PHAsset) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        // 편집 입력 요청
        guard let input = await AssetCachingManager.shared.loadContentEditingInput(for: asset) else {
            canEdit = false
            return false
        }
        
        // 원본 이미지 로드
        guard let fullSizeURL = input.fullSizeImageURL,
              let ciImage = CIImage(contentsOf: fullSizeURL) else {
            canEdit = false
            return false
        }
        
        // 방향 보정
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(input.fullSizeImageOrientation))
        
        currentAsset = asset
        editingInput = input
        originalImage = orientedImage
        editedImage = orientedImage
        adjustments = EditAdjustments()
        canEdit = true
        
        return true
    }
    
    /// 편집 세션 종료
    func endEditing() {
        currentAsset = nil
        editingInput = nil
        originalImage = nil
        editedImage = nil
        adjustments = EditAdjustments()
        canEdit = false
    }
    
    // MARK: - 편집 적용
    
    /// 현재 조정값으로 편집 이미지 업데이트
    func applyAdjustments() {
        guard var image = originalImage else { return }
        
        // 노출 조정
        if adjustments.exposure != 0 {
            image = applyExposure(to: image, value: adjustments.exposure)
        }
        
        // 밝기 조정
        if adjustments.brightness != 0 {
            image = applyBrightness(to: image, value: adjustments.brightness)
        }
        
        // 대비 조정
        if adjustments.contrast != 1 {
            image = applyContrast(to: image, value: adjustments.contrast)
        }
        
        // 채도 조정
        if adjustments.saturation != 1 {
            image = applySaturation(to: image, value: adjustments.saturation)
        }
        
        // 선명도 조정
        if adjustments.sharpness != 0 {
            image = applySharpness(to: image, value: adjustments.sharpness)
        }
        
        // 비네팅 조정
        if adjustments.vignette != 0 {
            image = applyVignette(to: image, value: adjustments.vignette)
        }
        
        // 온도 조정
        if adjustments.temperature != 6500 {
            image = applyTemperature(to: image, value: adjustments.temperature)
        }
        
        // 틴트 조정
        if adjustments.tint != 0 {
            image = applyTint(to: image, value: adjustments.tint)
        }
        
        // 하이라이트/섀도우 조정
        if adjustments.highlights != 0 || adjustments.shadows != 0 {
            image = applyHighlightShadow(
                to: image,
                highlights: adjustments.highlights,
                shadows: adjustments.shadows
            )
        }
        
        // 필터 적용
        if let filter = adjustments.selectedFilter {
            image = applyFilter(filter, to: image)
        }
        
        // 크롭 적용
        if let cropRect = adjustments.cropRect {
            image = applyCrop(to: image, rect: cropRect)
        }
        
        // 회전 적용
        if adjustments.rotation != 0 {
            image = applyRotation(to: image, angle: adjustments.rotation)
        }
        
        editedImage = image
    }
    
    // MARK: - 개별 필터 적용
    
    /// 노출 조정
    private func applyExposure(to image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.exposureAdjust()
        filter.inputImage = image
        filter.ev = value
        return filter.outputImage ?? image
    }
    
    /// 밝기 조정
    private func applyBrightness(to image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.brightness = value
        return filter.outputImage ?? image
    }
    
    /// 대비 조정
    private func applyContrast(to image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.contrast = value
        return filter.outputImage ?? image
    }
    
    /// 채도 조정
    private func applySaturation(to image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.saturation = value
        return filter.outputImage ?? image
    }
    
    /// 선명도 조정
    private func applySharpness(to image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.sharpenLuminance()
        filter.inputImage = image
        filter.sharpness = value
        return filter.outputImage ?? image
    }
    
    /// 비네팅 조정
    private func applyVignette(to image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.vignette()
        filter.inputImage = image
        filter.intensity = value
        filter.radius = Float(min(image.extent.width, image.extent.height)) / 2
        return filter.outputImage ?? image
    }
    
    /// 색온도 조정
    private func applyTemperature(to image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = image
        filter.neutral = CIVector(x: CGFloat(value), y: 0)
        return filter.outputImage ?? image
    }
    
    /// 틴트 조정
    private func applyTint(to image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = image
        filter.neutral = CIVector(x: 6500, y: CGFloat(value))
        return filter.outputImage ?? image
    }
    
    /// 하이라이트/섀도우 조정
    private func applyHighlightShadow(to image: CIImage, highlights: Float, shadows: Float) -> CIImage {
        let filter = CIFilter.highlightShadowAdjust()
        filter.inputImage = image
        filter.highlightAmount = 1 - highlights
        filter.shadowAmount = shadows + 1
        return filter.outputImage ?? image
    }
    
    /// 크롭 적용
    private func applyCrop(to image: CIImage, rect: CGRect) -> CIImage {
        return image.cropped(to: rect)
    }
    
    /// 회전 적용
    private func applyRotation(to image: CIImage, angle: Float) -> CIImage {
        let radians = CGFloat(angle) * .pi / 180
        return image.transformed(by: CGAffineTransform(rotationAngle: radians))
    }
    
    // MARK: - 사전 정의 필터
    
    /// 필터 적용
    private func applyFilter(_ filter: PhotoFilter, to image: CIImage) -> CIImage {
        switch filter {
        case .none:
            return image
            
        case .mono:
            let ciFilter = CIFilter.photoEffectMono()
            ciFilter.inputImage = image
            return ciFilter.outputImage ?? image
            
        case .chrome:
            let ciFilter = CIFilter.photoEffectChrome()
            ciFilter.inputImage = image
            return ciFilter.outputImage ?? image
            
        case .fade:
            let ciFilter = CIFilter.photoEffectFade()
            ciFilter.inputImage = image
            return ciFilter.outputImage ?? image
            
        case .instant:
            let ciFilter = CIFilter.photoEffectInstant()
            ciFilter.inputImage = image
            return ciFilter.outputImage ?? image
            
        case .noir:
            let ciFilter = CIFilter.photoEffectNoir()
            ciFilter.inputImage = image
            return ciFilter.outputImage ?? image
            
        case .process:
            let ciFilter = CIFilter.photoEffectProcess()
            ciFilter.inputImage = image
            return ciFilter.outputImage ?? image
            
        case .tonal:
            let ciFilter = CIFilter.photoEffectTonal()
            ciFilter.inputImage = image
            return ciFilter.outputImage ?? image
            
        case .transfer:
            let ciFilter = CIFilter.photoEffectTransfer()
            ciFilter.inputImage = image
            return ciFilter.outputImage ?? image
            
        case .sepia:
            let ciFilter = CIFilter.sepiaTone()
            ciFilter.inputImage = image
            ciFilter.intensity = 0.8
            return ciFilter.outputImage ?? image
            
        case .vibrant:
            let ciFilter = CIFilter.vibrance()
            ciFilter.inputImage = image
            ciFilter.amount = 1.5
            return ciFilter.outputImage ?? image
        }
    }
    
    // MARK: - 저장
    
    /// 편집된 이미지를 Photos 라이브러리에 저장
    /// - Returns: 성공 여부
    func saveEditedPhoto() async -> Bool {
        guard let asset = currentAsset,
              let input = editingInput,
              let editedImage = editedImage else {
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // UIImage로 변환
        guard let cgImage = ciContext.createCGImage(editedImage, from: editedImage.extent) else {
            return false
        }
        let uiImage = UIImage(cgImage: cgImage)
        
        // JPEG 데이터로 변환
        guard let imageData = uiImage.jpegData(compressionQuality: 0.9) else {
            return false
        }
        
        // 편집 출력 생성
        let output = PHContentEditingOutput(contentEditingInput: input)
        
        // 조정 데이터 저장
        let adjustmentData = PHAdjustmentData(
            formatIdentifier: "com.photogallery.editor",
            formatVersion: "1.0",
            data: try! JSONEncoder().encode(adjustments)
        )
        output.adjustmentData = adjustmentData
        
        // 편집된 이미지 파일 작성
        do {
            try imageData.write(to: output.renderedContentURL)
        } catch {
            print("편집된 이미지 저장 실패: \(error.localizedDescription)")
            return false
        }
        
        // Photos 라이브러리에 변경사항 저장
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest(for: asset)
                request.contentEditingOutput = output
            }
            return true
        } catch {
            print("Photos 라이브러리 저장 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 새 사진으로 저장 (원본 유지)
    /// - Returns: 성공 여부
    func saveAsNewPhoto() async -> Bool {
        guard let editedImage = editedImage else { return false }
        
        isLoading = true
        defer { isLoading = false }
        
        // UIImage로 변환
        guard let cgImage = ciContext.createCGImage(editedImage, from: editedImage.extent) else {
            return false
        }
        let uiImage = UIImage(cgImage: cgImage)
        
        // Photos 라이브러리에 새 사진으로 저장
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
            }
            return true
        } catch {
            print("새 사진 저장 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 원본으로 되돌리기
    /// - Returns: 성공 여부
    func revertToOriginal() async -> Bool {
        guard let asset = currentAsset else { return false }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest(for: asset)
                request.revertAssetContentToOriginal()
            }
            
            // 편집 세션 재시작
            return await startEditing(asset: asset)
        } catch {
            print("원본 복원 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 프리뷰 생성
    
    /// 미리보기용 UIImage 생성
    /// - Returns: UIImage
    func generatePreviewImage() -> UIImage? {
        guard let editedImage = editedImage else { return nil }
        
        guard let cgImage = ciContext.createCGImage(editedImage, from: editedImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// 필터 프리뷰 썸네일 생성
    /// - Parameter filter: 적용할 필터
    /// - Returns: 필터가 적용된 UIImage
    func generateFilterPreview(_ filter: PhotoFilter) -> UIImage? {
        guard let original = originalImage else { return nil }
        
        // 썸네일 크기로 축소
        let scale = 100.0 / max(original.extent.width, original.extent.height)
        let thumbnail = original.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        // 필터 적용
        let filtered = applyFilter(filter, to: thumbnail)
        
        // UIImage로 변환
        guard let cgImage = ciContext.createCGImage(filtered, from: filtered.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - 편집 조정값 모델
/// 사진 편집에 사용되는 모든 조정값을 담는 구조체
struct EditAdjustments: Codable, Equatable {
    
    // MARK: - 기본 조정
    
    /// 노출 (-2.0 ~ 2.0, 기본 0)
    var exposure: Float = 0
    
    /// 밝기 (-1.0 ~ 1.0, 기본 0)
    var brightness: Float = 0
    
    /// 대비 (0.0 ~ 2.0, 기본 1)
    var contrast: Float = 1
    
    /// 채도 (0.0 ~ 2.0, 기본 1)
    var saturation: Float = 1
    
    /// 선명도 (0.0 ~ 2.0, 기본 0)
    var sharpness: Float = 0
    
    // MARK: - 고급 조정
    
    /// 하이라이트 (-1.0 ~ 1.0, 기본 0)
    var highlights: Float = 0
    
    /// 섀도우 (-1.0 ~ 1.0, 기본 0)
    var shadows: Float = 0
    
    /// 비네팅 (0.0 ~ 2.0, 기본 0)
    var vignette: Float = 0
    
    /// 색온도 (2000 ~ 10000, 기본 6500)
    var temperature: Float = 6500
    
    /// 틴트 (-100 ~ 100, 기본 0)
    var tint: Float = 0
    
    // MARK: - 필터
    
    /// 선택된 필터
    var selectedFilter: PhotoFilter? = nil
    
    // MARK: - 크롭 및 회전
    
    /// 크롭 영역
    var cropRect: CGRect? = nil
    
    /// 회전 각도 (도 단위)
    var rotation: Float = 0
    
    // MARK: - 초기화 상태 확인
    
    /// 기본값 상태인지 확인
    var isDefault: Bool {
        exposure == 0 &&
        brightness == 0 &&
        contrast == 1 &&
        saturation == 1 &&
        sharpness == 0 &&
        highlights == 0 &&
        shadows == 0 &&
        vignette == 0 &&
        temperature == 6500 &&
        tint == 0 &&
        selectedFilter == nil &&
        cropRect == nil &&
        rotation == 0
    }
    
    /// 모든 값을 기본값으로 초기화
    mutating func reset() {
        self = EditAdjustments()
    }
}

// MARK: - 사진 필터 열거형
/// 사용 가능한 사진 필터 목록
enum PhotoFilter: String, CaseIterable, Codable {
    case none = "원본"
    case mono = "모노"
    case chrome = "크롬"
    case fade = "페이드"
    case instant = "인스턴트"
    case noir = "느와르"
    case process = "프로세스"
    case tonal = "토날"
    case transfer = "트랜스퍼"
    case sepia = "세피아"
    case vibrant = "비비드"
    
    /// 아이콘 이름
    var iconName: String {
        switch self {
        case .none: return "photo"
        default: return "camera.filters"
        }
    }
}
