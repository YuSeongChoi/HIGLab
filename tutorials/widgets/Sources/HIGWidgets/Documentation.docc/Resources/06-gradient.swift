import SwiftUI

// MARK: - Weather Condition Gradients
// HIG: 위젯 배경으로 날씨 분위기를 전달합니다.
// 맑은 날은 따뜻한 톤, 비 오는 날은 차가운 톤으로.

extension WeatherCondition {
    /// 날씨 조건에 맞는 그래디언트 배경
    var gradient: LinearGradient {
        switch self {
        case .sunny:
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.75, blue: 0.3),   // 따뜻한 오렌지
                    Color(red: 1.0, green: 0.85, blue: 0.4)    // 밝은 옐로우
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        case .cloudy:
            LinearGradient(
                colors: [
                    Color(red: 0.7, green: 0.75, blue: 0.8),   // 부드러운 그레이
                    Color(red: 0.85, green: 0.87, blue: 0.9)   // 밝은 그레이
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        case .rainy:
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.5, blue: 0.6),    // 어두운 그레이
                    Color(red: 0.5, green: 0.6, blue: 0.75)    // 블루 그레이
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        case .snowy:
            LinearGradient(
                colors: [
                    Color(red: 0.9, green: 0.95, blue: 1.0),   // 거의 흰색
                    Color(red: 0.8, green: 0.9, blue: 0.98)    // 아이스 블루
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        case .stormy:
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.25, blue: 0.35),  // 어두운 네이비
                    Color(red: 0.35, green: 0.3, blue: 0.45)   // 폭풍 퍼플
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    /// 텍스트 색상 (배경에 따라 조정)
    var textColor: Color {
        switch self {
        case .sunny, .cloudy, .snowy:
            return .primary
        case .rainy, .stormy:
            return .white
        }
    }
    
    /// 보조 텍스트 색상
    var secondaryTextColor: Color {
        switch self {
        case .sunny, .cloudy, .snowy:
            return .secondary
        case .rainy, .stormy:
            return .white.opacity(0.8)
        }
    }
}
