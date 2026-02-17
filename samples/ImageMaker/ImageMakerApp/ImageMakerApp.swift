import SwiftUI

// MARK: - ImageMakerApp
// Image Playground를 활용한 AI 이미지 생성 앱
// iOS 26의 새로운 Image Playground API를 사용하여 텍스트에서 이미지를 생성

/// 앱 진입점
/// iOS 26 Image Playground API를 활용한 이미지 생성 데모
@main
struct ImageMakerApp: App {
    
    // MARK: - State Objects
    
    /// 이미지 저장소 관리자
    @StateObject private var storageManager = ImageStorageManager.shared
    
    /// 뷰모델
    @StateObject private var viewModel = ImageMakerViewModel()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storageManager)
                .environmentObject(viewModel)
        }
    }
}

// MARK: - App Constants
// 앱 전역 상수 정의

/// 앱 상수
enum AppConstants {
    /// 앱 이름
    static let appName = "ImageMaker"
    
    /// 앱 설명
    static let appDescription = "AI로 상상을 그림으로"
    
    /// 최대 프롬프트 길이
    static let maxPromptLength = 500
    
    /// 히스토리 표시 최대 개수 (기본)
    static let defaultHistoryLimit = 50
    
    /// 그리드 컬럼 수
    static let gridColumns = 2
    
    /// 썸네일 크기
    static let thumbnailSize: CGFloat = 150
    
    /// 미리보기 애니메이션 시간
    static let animationDuration: Double = 0.3
}

// MARK: - App Theme
// 앱 테마 및 스타일 정의

/// 앱 테마 색상
enum AppTheme {
    /// 기본 그라데이션 색상
    static let primaryGradient = LinearGradient(
        colors: [.blue, .purple, .pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 배경 그라데이션
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(.systemBackground),
            Color(.secondarySystemBackground)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// 카드 배경색
    static let cardBackground = Color(.secondarySystemBackground)
    
    /// 강조 색상
    static let accentColor = Color.blue
    
    /// 섹션 헤더 색상
    static let sectionHeaderColor = Color.secondary
}

// MARK: - View Modifiers
// 재사용 가능한 뷰 모디파이어

/// 카드 스타일 모디파이어
struct CardStyle: ViewModifier {
    var cornerRadius: CGFloat = 16
    var shadowRadius: CGFloat = 4
    
    func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: shadowRadius, y: 2)
    }
}

/// 버튼 스타일 모디파이어
struct PrimaryButtonStyle: ViewModifier {
    var isEnabled: Bool = true
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                isEnabled ? AppTheme.primaryGradient : LinearGradient(
                    colors: [.gray],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
    }
}

extension View {
    /// 카드 스타일 적용
    func cardStyle(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 4) -> some View {
        modifier(CardStyle(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
    
    /// 기본 버튼 스타일 적용
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        modifier(PrimaryButtonStyle(isEnabled: isEnabled))
    }
}

// MARK: - Haptic Feedback
// 햅틱 피드백 헬퍼

/// 햅틱 피드백 매니저
enum HapticFeedback {
    /// 가벼운 탭 피드백
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// 중간 탭 피드백
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// 무거운 탭 피드백
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// 성공 피드백
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// 에러 피드백
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// 선택 피드백
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
