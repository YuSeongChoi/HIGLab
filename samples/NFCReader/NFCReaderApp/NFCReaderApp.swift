import SwiftUI

// MARK: - NFCReader 앱 진입점

/// NFC 태그 리더 앱
/// Core NFC 프레임워크를 사용하여 NDEF 태그를 읽고 쓰는 기능을 제공합니다
@main
struct NFCReaderApp: App {
    /// NFC 매니저 (앱 전역에서 사용)
    @StateObject private var nfcManager = NFCManager()
    
    /// 스캔 히스토리 매니저
    @StateObject private var historyManager = ScanHistoryManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(nfcManager)
                .environmentObject(historyManager)
        }
    }
}

// MARK: - 앱 상수

/// 앱 전역 상수
enum AppConstants {
    /// 앱 이름
    static let appName = "NFC Reader"
    
    /// 앱 버전
    static let appVersion = "1.0.0"
    
    /// 스캔 세션 타임아웃 (초)
    static let scanTimeout: TimeInterval = 60
    
    /// 스캔 세션 메시지
    enum Messages {
        static let scanReady = "iPhone 상단을 NFC 태그에 가까이 대세요"
        static let scanning = "태그 스캔 중..."
        static let writeReady = "쓰기 준비됨. 태그에 가까이 대세요"
        static let writing = "태그에 쓰는 중..."
        static let success = "완료!"
        static let error = "오류가 발생했습니다"
    }
    
    /// UI 관련 상수
    enum UI {
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 16
        static let iconSize: CGFloat = 60
        static let animationDuration: Double = 0.3
    }
}

// MARK: - 앱 색상 테마

extension Color {
    /// 앱 주요 색상
    static let nfcPrimary = Color.blue
    
    /// 앱 보조 색상
    static let nfcSecondary = Color.orange
    
    /// 성공 색상
    static let nfcSuccess = Color.green
    
    /// 오류 색상
    static let nfcError = Color.red
    
    /// 배경 색상
    static let nfcBackground = Color(UIColor.systemGroupedBackground)
    
    /// 카드 배경 색상
    static let nfcCardBackground = Color(UIColor.secondarySystemGroupedBackground)
}

// MARK: - 뷰 수정자

/// 카드 스타일 수정자
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppConstants.UI.padding)
            .background(Color.nfcCardBackground)
            .cornerRadius(AppConstants.UI.cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

/// 주요 버튼 스타일
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                    .fill(isEnabled ? Color.nfcPrimary : Color.gray)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// 보조 버튼 스타일
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.nfcPrimary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                    .stroke(Color.nfcPrimary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - View Extension

extension View {
    /// 카드 스타일 적용
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    /// 주요 버튼 스타일 적용
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
    }
    
    /// 보조 버튼 스타일 적용
    func secondaryButtonStyle() -> some View {
        buttonStyle(SecondaryButtonStyle())
    }
}
