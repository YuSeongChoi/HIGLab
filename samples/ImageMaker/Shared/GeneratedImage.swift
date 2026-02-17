import Foundation
import SwiftUI

// MARK: - GeneratedImage
// 생성된 이미지 데이터 모델
// Image Playground에서 생성된 이미지의 메타데이터와 실제 이미지를 관리

/// 생성된 이미지를 나타내는 모델
/// Identifiable, Codable을 채택하여 리스트 표시 및 영구 저장 지원
struct GeneratedImage: Identifiable, Codable, Hashable {
    /// 고유 식별자
    let id: UUID
    
    /// 이미지 생성에 사용된 프롬프트
    let prompt: String
    
    /// 적용된 스타일
    let style: ImageStyle
    
    /// 생성 날짜/시간
    let createdAt: Date
    
    /// 이미지 파일명 (로컬 저장소 참조용)
    let fileName: String
    
    /// 즐겨찾기 여부
    var isFavorite: Bool
    
    /// 사용자 메모 (선택적)
    var note: String?
    
    // MARK: - Initializers
    
    /// 새 이미지 생성 시 사용하는 초기화
    /// - Parameters:
    ///   - prompt: 생성 프롬프트
    ///   - style: 이미지 스타일
    init(prompt: String, style: ImageStyle) {
        self.id = UUID()
        self.prompt = prompt
        self.style = style
        self.createdAt = Date()
        self.fileName = "\(id.uuidString).png"
        self.isFavorite = false
        self.note = nil
    }
    
    /// 디코딩용 초기화 (Codable)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        prompt = try container.decode(String.self, forKey: .prompt)
        style = try container.decode(ImageStyle.self, forKey: .style)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        fileName = try container.decode(String.self, forKey: .fileName)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        note = try container.decodeIfPresent(String.self, forKey: .note)
    }
    
    // MARK: - Computed Properties
    
    /// 상대적 시간 표시 (예: "3분 전", "어제")
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    /// 상세 날짜 문자열 (예: "2026년 2월 17일 오전 10:30")
    var detailedDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    /// 짧은 프롬프트 (미리보기용, 최대 50자)
    var shortPrompt: String {
        if prompt.count <= 50 {
            return prompt
        }
        return String(prompt.prefix(47)) + "..."
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GeneratedImage, rhs: GeneratedImage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 샘플 데이터 (프리뷰 및 테스트용)
extension GeneratedImage {
    /// 프리뷰용 샘플 이미지
    static let sample = GeneratedImage(
        prompt: "우주를 여행하는 귀여운 고양이",
        style: .animation
    )
    
    /// 프리뷰용 샘플 이미지 배열
    static let samples: [GeneratedImage] = [
        GeneratedImage(prompt: "우주를 여행하는 귀여운 고양이", style: .animation),
        GeneratedImage(prompt: "해변에서 서핑하는 펭귄", style: .illustration),
        GeneratedImage(prompt: "미래 도시의 야경", style: .sketch),
        GeneratedImage(prompt: "마법의 숲에서 책 읽는 여우", style: .animation),
        GeneratedImage(prompt: "빈티지 카페에서 커피 마시는 로봇", style: .illustration)
    ]
}

// MARK: - ImageCollection
// 이미지 컬렉션 (그룹화된 이미지 관리용)

/// 이미지 컬렉션 모델
/// 여러 이미지를 그룹으로 관리할 때 사용
struct ImageCollection: Identifiable, Codable {
    let id: UUID
    var name: String
    var imageIds: [UUID]
    let createdAt: Date
    var updatedAt: Date
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.imageIds = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// 이미지 추가
    mutating func addImage(_ image: GeneratedImage) {
        if !imageIds.contains(image.id) {
            imageIds.append(image.id)
            updatedAt = Date()
        }
    }
    
    /// 이미지 제거
    mutating func removeImage(_ image: GeneratedImage) {
        imageIds.removeAll { $0 == image.id }
        updatedAt = Date()
    }
    
    /// 이미지 개수
    var count: Int {
        imageIds.count
    }
}
