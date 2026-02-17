import SwiftUI
import ImagePlayground
import Observation

// MARK: - ImageMakerViewModel
// 이미지 생성 앱의 메인 뷰모델
// Image Playground API와 상호작용하고 상태를 관리

/// 이미지 메이커 뷰모델
/// Image Playground 기능 가용성 확인 및 이미지 생성 로직 관리
@MainActor
@Observable
final class ImageMakerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 현재 입력된 프롬프트
    var currentPrompt: String = ""
    
    /// 선택된 스타일
    var selectedStyle: ImageStyle = .animation
    
    /// Image Playground 표시 여부
    var showingImagePlayground: Bool = false
    
    /// 마지막으로 생성된 이미지
    var lastGeneratedImage: GeneratedImage?
    
    /// 로딩 상태
    var isLoading: Bool = false
    
    /// 에러 메시지
    var errorMessage: String?
    
    /// 성공 메시지
    var successMessage: String?
    
    /// 상세 보기 중인 이미지
    var selectedImageForDetail: GeneratedImage?
    
    /// 검색 쿼리
    var searchQuery: String = ""
    
    /// 현재 필터 (스타일)
    var filterStyle: ImageStyle?
    
    /// 즐겨찾기만 표시
    var showFavoritesOnly: Bool = false
    
    // MARK: - Computed Properties
    
    /// 프롬프트가 유효한지 확인
    var isPromptValid: Bool {
        let trimmed = currentPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 3 && trimmed.count <= AppConstants.maxPromptLength
    }
    
    /// 프롬프트 글자 수
    var promptCharacterCount: Int {
        currentPrompt.count
    }
    
    /// 남은 글자 수
    var remainingCharacters: Int {
        AppConstants.maxPromptLength - promptCharacterCount
    }
    
    /// Image Playground 사용 가능 여부
    @available(iOS 26.0, *)
    var isImagePlaygroundAvailable: Bool {
        ImagePlaygroundViewController.isAvailable
    }
    
    /// 필터링된 이미지 목록
    var filteredImages: [GeneratedImage] {
        var result = ImageStorageManager.shared.images
        
        // 검색어 필터
        if !searchQuery.isEmpty {
            result = result.filter {
                $0.prompt.localizedCaseInsensitiveContains(searchQuery) ||
                $0.note?.localizedCaseInsensitiveContains(searchQuery) == true
            }
        }
        
        // 스타일 필터
        if let style = filterStyle {
            result = result.filter { $0.style == style }
        }
        
        // 즐겨찾기 필터
        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }
        
        return result
    }
    
    // MARK: - Initialization
    
    init() {
        // 초기화 시 저장된 이미지 로드
        ImageStorageManager.shared.loadImages()
    }
    
    // MARK: - Image Playground Integration
    
    /// Image Playground 열기
    func openImagePlayground() {
        guard isPromptValid else {
            errorMessage = "프롬프트를 3자 이상 입력해주세요"
            return
        }
        
        showingImagePlayground = true
        HapticFeedback.medium()
    }
    
    /// 이미지 생성 완료 처리
    /// - Parameter url: 생성된 이미지 URL
    func handleGeneratedImage(_ url: URL) {
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            // 이미지 저장
            if let savedImage = await ImageStorageManager.shared.saveImage(
                from: url,
                prompt: currentPrompt,
                style: selectedStyle
            ) {
                lastGeneratedImage = savedImage
                successMessage = "이미지가 저장되었습니다!"
                HapticFeedback.success()
                
                // 프롬프트 초기화
                currentPrompt = ""
            } else {
                errorMessage = "이미지 저장에 실패했습니다"
                HapticFeedback.error()
            }
        }
    }
    
    /// Image Playground에서 이미지 직접 처리 (UIImage)
    /// - Parameter image: 생성된 UIImage
    func handleGeneratedImage(_ image: UIImage) {
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            if let savedImage = ImageStorageManager.shared.saveImage(
                image,
                prompt: currentPrompt,
                style: selectedStyle
            ) {
                lastGeneratedImage = savedImage
                successMessage = "이미지가 저장되었습니다!"
                HapticFeedback.success()
                currentPrompt = ""
            } else {
                errorMessage = "이미지 저장에 실패했습니다"
                HapticFeedback.error()
            }
        }
    }
    
    // MARK: - Prompt Management
    
    /// 프리셋 프롬프트 적용
    /// - Parameter preset: 스타일 프리셋
    func applyPreset(_ preset: StylePreset) {
        currentPrompt = preset.prompt
        selectedStyle = preset.style
        HapticFeedback.selection()
    }
    
    /// 프롬프트 초기화
    func clearPrompt() {
        currentPrompt = ""
        HapticFeedback.light()
    }
    
    /// 프롬프트에 키워드 추가
    /// - Parameter keyword: 추가할 키워드
    func addKeyword(_ keyword: String) {
        if currentPrompt.isEmpty {
            currentPrompt = keyword
        } else {
            currentPrompt += " \(keyword)"
        }
        HapticFeedback.light()
    }
    
    // MARK: - Image Management
    
    /// 이미지 삭제
    /// - Parameter image: 삭제할 이미지
    func deleteImage(_ image: GeneratedImage) {
        ImageStorageManager.shared.deleteImage(image)
        
        if selectedImageForDetail?.id == image.id {
            selectedImageForDetail = nil
        }
        
        HapticFeedback.medium()
    }
    
    /// 이미지 즐겨찾기 토글
    /// - Parameter image: 대상 이미지
    func toggleFavorite(_ image: GeneratedImage) {
        ImageStorageManager.shared.toggleFavorite(image)
        HapticFeedback.selection()
    }
    
    /// 이미지 상세 보기
    /// - Parameter image: 볼 이미지
    func showImageDetail(_ image: GeneratedImage) {
        selectedImageForDetail = image
    }
    
    /// 상세 보기 닫기
    func closeImageDetail() {
        selectedImageForDetail = nil
    }
    
    // MARK: - Filter Management
    
    /// 필터 초기화
    func clearFilters() {
        searchQuery = ""
        filterStyle = nil
        showFavoritesOnly = false
    }
    
    /// 스타일 필터 토글
    /// - Parameter style: 필터링할 스타일
    func toggleStyleFilter(_ style: ImageStyle) {
        if filterStyle == style {
            filterStyle = nil
        } else {
            filterStyle = style
        }
        HapticFeedback.selection()
    }
    
    // MARK: - Message Handling
    
    /// 에러 메시지 초기화
    func clearError() {
        errorMessage = nil
    }
    
    /// 성공 메시지 초기화
    func clearSuccess() {
        successMessage = nil
    }
    
    /// 모든 메시지 초기화
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}

// MARK: - ImagePlaygroundSource Extension
// Image Playground 컨셉 생성 헬퍼

@available(iOS 26.0, *)
extension ImageMakerViewModel {
    
    /// 현재 설정으로 Image Playground 컨셉 생성
    var playgroundConcepts: [ImagePlaygroundConcept] {
        var concepts: [ImagePlaygroundConcept] = []
        
        // 텍스트 컨셉 추가
        if !currentPrompt.isEmpty {
            concepts.append(.text(currentPrompt))
        }
        
        return concepts
    }
}
