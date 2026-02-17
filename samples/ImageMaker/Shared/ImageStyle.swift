import Foundation
import SwiftUI
import ImagePlayground

// MARK: - ImageStyle
// Image Playground에서 지원하는 이미지 스타일 열거형
// iOS 26 ImagePlayground API의 ImagePlaygroundStyle과 매핑

/// 이미지 생성 스타일
/// Image Playground가 지원하는 세 가지 스타일을 정의
enum ImageStyle: String, CaseIterable, Codable, Identifiable {
    /// 애니메이션 스타일 - 생동감 있는 캐릭터와 장면
    case animation = "animation"
    
    /// 일러스트레이션 스타일 - 손으로 그린 듯한 아트워크
    case illustration = "illustration"
    
    /// 스케치 스타일 - 연필/펜으로 그린 듯한 스타일
    case sketch = "sketch"
    
    // MARK: - Identifiable
    
    var id: String { rawValue }
    
    // MARK: - Display Properties
    
    /// 한글 표시명
    var displayName: String {
        switch self {
        case .animation:
            return "애니메이션"
        case .illustration:
            return "일러스트"
        case .sketch:
            return "스케치"
        }
    }
    
    /// 스타일 설명
    var description: String {
        switch self {
        case .animation:
            return "생동감 넘치는 3D 애니메이션 스타일로 캐릭터와 장면을 표현합니다."
        case .illustration:
            return "따뜻한 손그림 느낌의 일러스트레이션 스타일입니다."
        case .sketch:
            return "연필이나 펜으로 그린 듯한 감성적인 스케치 스타일입니다."
        }
    }
    
    /// SF Symbol 아이콘 이름
    var iconName: String {
        switch self {
        case .animation:
            return "figure.run.motion"
        case .illustration:
            return "paintbrush.fill"
        case .sketch:
            return "pencil.tip"
        }
    }
    
    /// 스타일 대표 색상
    var themeColor: Color {
        switch self {
        case .animation:
            return .blue
        case .illustration:
            return .orange
        case .sketch:
            return .gray
        }
    }
    
    /// 그라데이션 색상 (배경용)
    var gradientColors: [Color] {
        switch self {
        case .animation:
            return [.blue, .cyan, .mint]
        case .illustration:
            return [.orange, .pink, .red]
        case .sketch:
            return [.gray, .secondary, .primary.opacity(0.3)]
        }
    }
    
    // MARK: - ImagePlayground Integration
    
    /// ImagePlayground API의 스타일로 변환
    /// iOS 26 Image Playground 프레임워크와 연동
    @available(iOS 26.0, *)
    var playgroundStyle: ImagePlaygroundStyle {
        switch self {
        case .animation:
            return .animation
        case .illustration:
            return .illustration
        case .sketch:
            return .sketch
        }
    }
    
    // MARK: - Factory Methods
    
    /// ImagePlaygroundStyle에서 변환
    @available(iOS 26.0, *)
    static func from(_ playgroundStyle: ImagePlaygroundStyle) -> ImageStyle {
        switch playgroundStyle {
        case .animation:
            return .animation
        case .illustration:
            return .illustration
        case .sketch:
            return .sketch
        @unknown default:
            return .animation
        }
    }
}

// MARK: - StylePreset
// 미리 정의된 스타일 프리셋 (프롬프트 + 스타일 조합)

/// 스타일 프리셋
/// 자주 사용되는 프롬프트와 스타일 조합을 미리 정의
struct StylePreset: Identifiable {
    let id = UUID()
    let name: String
    let prompt: String
    let style: ImageStyle
    let emoji: String
    
    /// 미리 정의된 프리셋들
    static let presets: [StylePreset] = [
        StylePreset(
            name: "우주 탐험",
            prompt: "은하수와 별들 사이를 여행하는 우주비행사",
            style: .animation,
            emoji: "🚀"
        ),
        StylePreset(
            name: "마법의 숲",
            prompt: "빛나는 버섯과 요정이 있는 신비로운 숲",
            style: .illustration,
            emoji: "🌲"
        ),
        StylePreset(
            name: "귀여운 동물",
            prompt: "꽃밭에서 뛰노는 아기 토끼와 강아지",
            style: .animation,
            emoji: "🐰"
        ),
        StylePreset(
            name: "도시 풍경",
            prompt: "네온사인이 빛나는 미래 도시의 밤거리",
            style: .sketch,
            emoji: "🌃"
        ),
        StylePreset(
            name: "바다 속",
            prompt: "산호초와 열대어가 있는 아름다운 수중 세계",
            style: .illustration,
            emoji: "🐠"
        ),
        StylePreset(
            name: "캠핑",
            prompt: "별이 쏟아지는 밤 캠프파이어 앞에서 기타 치는 사람",
            style: .sketch,
            emoji: "⛺"
        )
    ]
}

// MARK: - StyleCategory
// 스타일 카테고리 (UI 그룹핑용)

/// 스타일 카테고리
enum StyleCategory: String, CaseIterable {
    case nature = "자연"
    case fantasy = "판타지"
    case urban = "도시"
    case character = "캐릭터"
    case abstract = "추상"
    
    var icon: String {
        switch self {
        case .nature: return "leaf.fill"
        case .fantasy: return "sparkles"
        case .urban: return "building.2.fill"
        case .character: return "person.fill"
        case .abstract: return "scribble"
        }
    }
    
    /// 해당 카테고리의 추천 프롬프트 키워드
    var keywords: [String] {
        switch self {
        case .nature:
            return ["숲", "바다", "산", "꽃", "하늘", "호수", "폭포"]
        case .fantasy:
            return ["마법", "용", "요정", "유니콘", "신비", "성", "마법사"]
        case .urban:
            return ["도시", "거리", "카페", "빌딩", "네온", "야경", "골목"]
        case .character:
            return ["고양이", "강아지", "토끼", "로봇", "사람", "캐릭터"]
        case .abstract:
            return ["패턴", "기하학", "색채", "추상", "현대", "아트"]
        }
    }
}
