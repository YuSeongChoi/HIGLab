import Foundation
import UIKit

// MARK: - 촬영 미디어 모델
// 카메라로 촬영한 사진/비디오를 나타내는 모델입니다.

/// 촬영된 미디어 타입
enum MediaType: String, Codable {
    case photo = "사진"
    case video = "비디오"
    
    var symbol: String {
        switch self {
        case .photo: "photo.fill"
        case .video: "video.fill"
        }
    }
}

/// 촬영된 미디어 아이템
struct CapturedMedia: Identifiable {
    let id: UUID
    let type: MediaType
    let image: UIImage           // 사진 또는 비디오 썸네일
    let capturedAt: Date
    let fileURL: URL?            // 저장된 파일 경로 (옵션)
    
    init(
        id: UUID = UUID(),
        type: MediaType = .photo,
        image: UIImage,
        capturedAt: Date = Date(),
        fileURL: URL? = nil
    ) {
        self.id = id
        self.type = type
        self.image = image
        self.capturedAt = capturedAt
        self.fileURL = fileURL
    }
}

// MARK: - 날짜 포맷터

extension CapturedMedia {
    /// 촬영 시간을 포맷팅된 문자열로 반환
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter.string(from: capturedAt)
    }
    
    /// 촬영 날짜를 포맷팅된 문자열로 반환
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: capturedAt)
    }
}

// MARK: - Preview / Mock Data

extension CapturedMedia {
    /// 프리뷰용 샘플 미디어
    static let preview = CapturedMedia(
        type: .photo,
        image: UIImage(systemName: "photo")!
    )
    
    /// 프리뷰용 샘플 미디어 배열
    static let previewList: [CapturedMedia] = [
        CapturedMedia(type: .photo, image: UIImage(systemName: "photo.fill")!),
        CapturedMedia(type: .photo, image: UIImage(systemName: "photo.fill")!),
        CapturedMedia(type: .video, image: UIImage(systemName: "video.fill")!),
        CapturedMedia(type: .photo, image: UIImage(systemName: "photo.fill")!),
    ]
}
