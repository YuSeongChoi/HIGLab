import SwiftUI
import WidgetKit

// MARK: - Accessory Circular Widget
// 잠금 화면 원형 위젯입니다.
// HIG: 색상이 아닌 명암으로 정보 전달. 시스템이 색상을 제어합니다.

struct CircularWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        // Gauge를 사용한 원형 디스플레이
        Gauge(value: Double(weather.temperature), in: -10...40) {
            // 레이블 (화면에 표시되지 않음, 접근성용)
            Text("기온")
        } currentValueLabel: {
            // 중앙에 현재 기온
            Text("\(weather.temperature)°")
                .font(.system(.title3, design: .rounded, weight: .medium))
        } minimumValueLabel: {
            // 왼쪽 하단
            Text("")
        } maximumValueLabel: {
            // 오른쪽 하단
            Text("")
        }
        .gaugeStyle(.accessoryCircular)
    }
}

// MARK: - Alternative: Icon + Temperature
struct CircularWeatherIconView: View {
    let weather: WeatherData
    
    var body: some View {
        ZStack {
            // 배경 게이지 (온도 범위 시각화)
            AccessoryWidgetBackground()
            
            VStack(spacing: 2) {
                // 날씨 아이콘
                Image(systemName: weather.condition.symbol)
                    .font(.title3)
                    // 잠금 화면에서는 hierarchical 렌더링 권장
                    .symbolRenderingMode(.hierarchical)
                
                // 기온
                Text("\(weather.temperature)°")
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
        }
    }
}

// MARK: - Gauge with Progress
struct CircularWeatherProgressView: View {
    let weather: WeatherData
    
    var body: some View {
        // ProgressView를 사용한 원형 게이지
        ProgressView(value: temperatureProgress) {
            VStack(spacing: 0) {
                Image(systemName: weather.condition.symbol)
                    .font(.caption)
                Text("\(weather.temperature)°")
                    .font(.system(.caption, design: .rounded, weight: .bold))
            }
        }
        .progressViewStyle(.circular)
    }
    
    // 온도를 0~1 범위로 정규화 (-10°~40° 기준)
    var temperatureProgress: Double {
        let normalized = (Double(weather.temperature) + 10) / 50
        return max(0, min(1, normalized))
    }
}

#Preview("Circular", as: .accessoryCircular) {
    WeatherWidget()
} timeline: {
    WeatherEntry(date: .now, weather: .preview)
}
