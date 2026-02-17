import SwiftUI
import PhotosUI

// MARK: - 미디어 아이템 모델
/// PhotosPicker에서 선택된 미디어를 표현하는 모델
struct MediaItem: Identifiable {
    let id = UUID()
    
    /// 미디어 타입
    enum MediaType {
        case image
        case video
        case livePhoto
        case unknown
    }
    
    /// 로딩 상태
    enum LoadingState {
        case idle           // 대기 중
        case loading        // 로딩 중
        case loaded         // 로딩 완료
        case failed(Error)  // 실패
    }
    
    // MARK: - 프로퍼티
    
    /// PhotosPicker에서 받은 원본 아이템
    let pickerItem: PhotosPickerItem
    
    /// 미디어 타입
    var mediaType: MediaType {
        // 지원되는 콘텐츠 타입으로 미디어 종류 판별
        if pickerItem.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
            return .video
        } else if pickerItem.supportedContentTypes.contains(where: { $0.conforms(to: .livePhoto) }) {
            return .livePhoto
        } else if pickerItem.supportedContentTypes.contains(where: { $0.conforms(to: .image) }) {
            return .image
        }
        return .unknown
    }
    
    /// 로드된 이미지 (이미지/라이브포토 썸네일용)
    var image: Image?
    
    /// 로드된 비디오 URL
    var videoURL: URL?
    
    /// 현재 로딩 상태
    var loadingState: LoadingState = .idle
    
    // MARK: - 초기화
    
    init(pickerItem: PhotosPickerItem) {
        self.pickerItem = pickerItem
    }
}

// MARK: - Equatable 준수
extension MediaItem: Equatable {
    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable 준수
extension MediaItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
