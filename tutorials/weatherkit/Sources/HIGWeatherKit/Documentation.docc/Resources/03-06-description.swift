import WeatherKit
import SwiftUI

// description과 accessibilityDescription 활용

struct WeatherDescriptionView: View {
    let condition: WeatherCondition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 일반 설명 (로컬라이징됨)
            Text(condition.description)
                .font(.headline)
            
            // 접근성 설명 (더 자세함)
            Text(condition.accessibilityDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// VoiceOver를 위한 날씨 정보
func weatherAccessibilityLabel(_ current: CurrentWeather) -> String {
    let condition = current.condition.accessibilityDescription
    let temperature = current.temperature.formatted()
    
    return "현재 날씨: \(condition), 온도: \(temperature)"
}
