import SwiftUI
import WidgetKit

// MARK: - Accessory Inline Widget
// 잠금 화면 한 줄 위젯입니다.
// 시계 위나 날짜 옆에 표시되는 매우 간결한 형태입니다.
// HIG: 텍스트만 표시 가능, SF Symbol은 .font(.body) 크기로 하나만.

struct InlineWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        // 가장 간결한 형태: 조건 + 기온
        // "맑음 23°" 또는 "☀️ 23°" 형태
        HStack(spacing: 4) {
            // SF Symbol (하나만 허용)
            Image(systemName: weather.condition.symbol)
            
            // 텍스트
            Text("\(weather.temperature)° \(weather.condition.rawValue)")
        }
    }
}

// MARK: - Alternative Formats
// 상황에 따라 다른 형식을 사용할 수 있습니다.

struct InlineWeatherWithCityView: View {
    let weather: WeatherData
    
    var body: some View {
        // 도시명 포함: "서울 23° 맑음"
        Text("\(weather.cityName) \(weather.temperature)° \(weather.condition.rawValue)")
    }
}

struct InlineWeatherMinimalView: View {
    let weather: WeatherData
    
    var body: some View {
        // 최소: 아이콘 + 기온만
        HStack(spacing: 4) {
            Image(systemName: weather.condition.symbol)
            Text("\(weather.temperature)°")
        }
    }
}

struct InlineWeatherWithRangeView: View {
    let weather: WeatherData
    
    var body: some View {
        // 범위 포함: "23° (H:27 L:18)"
        Text("\(weather.temperature)° (H:\(weather.highTemperature) L:\(weather.lowTemperature))")
    }
}

// MARK: - ViewBuilder for Conditional Display
struct InlineWeatherAdaptiveView: View {
    let weather: WeatherData
    @Environment(\.widgetRenderingMode) var renderingMode
    
    var body: some View {
        // 렌더링 모드에 따라 다른 표시
        switch renderingMode {
        case .fullColor:
            // 풀 컬러 지원 시 (StandBy 등)
            HStack(spacing: 4) {
                Image(systemName: weather.condition.symbol)
                    .symbolRenderingMode(.multicolor)
                Text("\(weather.temperature)°")
            }
        case .accented:
            // 강조 컬러
            HStack(spacing: 4) {
                Image(systemName: weather.condition.symbol)
                Text("\(weather.temperature)°")
            }
        case .vibrant:
            // 잠금 화면 기본
            HStack(spacing: 4) {
                Image(systemName: weather.condition.symbol)
                Text("\(weather.temperature)° \(weather.condition.rawValue)")
            }
        @unknown default:
            InlineWeatherView(weather: weather)
        }
    }
}

#Preview("Inline", as: .accessoryInline) {
    WeatherWidget()
} timeline: {
    WeatherEntry(date: .now, weather: .preview)
}
