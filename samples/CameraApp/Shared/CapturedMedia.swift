import Foundation
import UIKit
import Photos
import AVFoundation

// MARK: - 촬영 미디어 모델
// 카메라로 촬영한 사진/비디오를 나타내는 모델입니다.
// HIG: 미디어 정보를 명확하고 일관되게 표시합니다.

// MARK: - 미디어 타입

/// 촬영된 미디어 타입
enum MediaType: String, Codable, CaseIterable {
    case photo = "사진"
    case video = "비디오"
    case livePhoto = "라이브 포토"
    case burst = "연속 촬영"
    
    /// SF Symbol 아이콘
    var symbol: String {
        switch self {
        case .photo: "photo.fill"
        case .video: "video.fill"
        case .livePhoto: "livephoto"
        case .burst: "square.stack.3d.down.right.fill"
        }
    }
    
    /// 배지 색상
    var badgeColor: UIColor {
        switch self {
        case .photo: .systemBlue
        case .video: .systemRed
        case .livePhoto: .systemYellow
        case .burst: .systemGreen
        }
    }
}

// MARK: - 촬영 미디어

/// 촬영된 미디어 아이템
struct CapturedMedia: Identifiable, Equatable {
    
    // MARK: - Properties
    
    /// 고유 식별자
    let id: UUID
    
    /// 미디어 타입
    let type: MediaType
    
    /// 대표 이미지 (사진 또는 비디오 썸네일)
    let image: UIImage
    
    /// 촬영 시간
    let capturedAt: Date
    
    /// 저장된 파일 경로 (로컬)
    let fileURL: URL?
    
    /// PHAsset 식별자 (포토 라이브러리)
    let assetIdentifier: String?
    
    /// 비디오 길이 (초)
    let duration: TimeInterval?
    
    /// 연속 촬영 수
    let burstCount: Int?
    
    /// 파일 크기 (bytes)
    var fileSize: Int64?
    
    /// 이미지 해상도
    var resolution: CGSize?
    
    /// 위치 정보
    var location: CLLocationCoordinate2D?
    
    /// 즐겨찾기 여부
    var isFavorite: Bool
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        type: MediaType = .photo,
        image: UIImage,
        capturedAt: Date = Date(),
        fileURL: URL? = nil,
        assetIdentifier: String? = nil,
        duration: TimeInterval? = nil,
        burstCount: Int? = nil,
        fileSize: Int64? = nil,
        resolution: CGSize? = nil,
        location: CLLocationCoordinate2D? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.type = type
        self.image = image
        self.capturedAt = capturedAt
        self.fileURL = fileURL
        self.assetIdentifier = assetIdentifier
        self.duration = duration
        self.burstCount = burstCount
        self.fileSize = fileSize
        self.resolution = resolution
        self.location = location
        self.isFavorite = isFavorite
    }
    
    // MARK: - Equatable
    
    static func == (lhs: CapturedMedia, rhs: CapturedMedia) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 날짜/시간 포맷터

extension CapturedMedia {
    
    /// 촬영 시간 (오전/오후 시:분)
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter.string(from: capturedAt)
    }
    
    /// 촬영 날짜 (M월 d일)
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: capturedAt)
    }
    
    /// 촬영 날짜/시간 (전체)
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 a h:mm"
        return formatter.string(from: capturedAt)
    }
    
    /// 상대적 시간 (방금, 1분 전, 1시간 전 등)
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: capturedAt, relativeTo: Date())
    }
}

// MARK: - 비디오 정보

extension CapturedMedia {
    
    /// 비디오 길이 (포맷된 문자열)
    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    /// 비디오 여부
    var isVideo: Bool {
        type == .video
    }
}

// MARK: - 파일 정보

extension CapturedMedia {
    
    /// 파일 크기 (포맷된 문자열)
    var formattedFileSize: String? {
        guard let size = fileSize else { return nil }
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    /// 해상도 문자열
    var formattedResolution: String? {
        guard let res = resolution else { return nil }
        return "\(Int(res.width)) × \(Int(res.height))"
    }
    
    /// 메가픽셀
    var megapixels: Double? {
        guard let res = resolution else { return nil }
        return (res.width * res.height) / 1_000_000
    }
    
    /// 메가픽셀 문자열
    var formattedMegapixels: String? {
        guard let mp = megapixels else { return nil }
        return String(format: "%.1f MP", mp)
    }
}

// MARK: - 공유

extension CapturedMedia {
    
    /// 공유용 아이템
    var shareItem: Any {
        if let url = fileURL {
            return url
        }
        return image
    }
    
    /// 공유 제목
    var shareTitle: String {
        "\(formattedDate) \(formattedTime)에 촬영한 \(type.rawValue)"
    }
}

// MARK: - 프리뷰 / 목업 데이터

extension CapturedMedia {
    
    /// 프리뷰용 샘플 사진
    static let previewPhoto = CapturedMedia(
        type: .photo,
        image: UIImage(systemName: "photo.fill")!,
        resolution: CGSize(width: 4032, height: 3024),
        fileSize: 2_500_000
    )
    
    /// 프리뷰용 샘플 비디오
    static let previewVideo = CapturedMedia(
        type: .video,
        image: UIImage(systemName: "video.fill")!,
        duration: 15.5,
        fileSize: 25_000_000
    )
    
    /// 프리뷰용 샘플 라이브 포토
    static let previewLivePhoto = CapturedMedia(
        type: .livePhoto,
        image: UIImage(systemName: "livephoto")!,
        duration: 1.5
    )
    
    /// 프리뷰용 샘플 리스트
    static let previewList: [CapturedMedia] = [
        CapturedMedia(type: .photo, image: UIImage(systemName: "photo.fill")!),
        CapturedMedia(type: .photo, image: UIImage(systemName: "photo.fill")!),
        CapturedMedia(type: .video, image: UIImage(systemName: "video.fill")!, duration: 30.0),
        CapturedMedia(type: .photo, image: UIImage(systemName: "photo.fill")!),
        CapturedMedia(type: .livePhoto, image: UIImage(systemName: "livephoto")!, duration: 1.5),
        CapturedMedia(type: .photo, image: UIImage(systemName: "photo.fill")!),
    ]
    
    /// 다양한 날짜의 프리뷰 리스트
    static var previewListWithDates: [CapturedMedia] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            CapturedMedia(type: .photo, image: UIImage(systemName: "photo.fill")!, capturedAt: now),
            CapturedMedia(type: .video, image: UIImage(systemName: "video.fill")!, capturedAt: calendar.date(byAdding: .hour, value: -1, to: now)!, duration: 45.0),
            CapturedMedia(type: .photo, image: UIImage(systemName: "photo.fill")!, capturedAt: calendar.date(byAdding: .day, value: -1, to: now)!),
            CapturedMedia(type: .livePhoto, image: UIImage(systemName: "livephoto")!, capturedAt: calendar.date(byAdding: .day, value: -2, to: now)!, duration: 1.5),
            CapturedMedia(type: .burst, image: UIImage(systemName: "square.stack.3d.down.right.fill")!, capturedAt: calendar.date(byAdding: .day, value: -3, to: now)!, burstCount: 10),
        ]
    }
}

// MARK: - 미디어 그룹핑

extension Array where Element == CapturedMedia {
    
    /// 날짜별 그룹핑
    func groupedByDate() -> [(date: String, media: [CapturedMedia])] {
        let grouped = Dictionary(grouping: self) { media in
            media.formattedDate
        }
        
        return grouped
            .sorted { $0.value.first!.capturedAt > $1.value.first!.capturedAt }
            .map { (date: $0.key, media: $0.value) }
    }
    
    /// 타입별 필터링
    func filtered(by type: MediaType) -> [CapturedMedia] {
        filter { $0.type == type }
    }
    
    /// 사진만
    var photos: [CapturedMedia] {
        filtered(by: .photo)
    }
    
    /// 비디오만
    var videos: [CapturedMedia] {
        filtered(by: .video)
    }
    
    /// 즐겨찾기만
    var favorites: [CapturedMedia] {
        filter { $0.isFavorite }
    }
}

// MARK: - 위치 정보 헬퍼

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
