import SwiftUI
import WidgetKit

// MARK: - Small Widget View
// HIG 핵심: 한눈에 파악 (Glanceable)
// 정보 4개 이내: 날씨 아이콘, 기온, 도시명, 최고/최저

struct SmallWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 날씨 아이콘 — SF Symbols multicolor로 생동감 있게
            Image(systemName: weather.condition.symbol)
                .font(.title2)
                .symbolRenderingMode(.multicolor)
            
            Spacer()
            
            // 현재 기온 — 가장 중요한 정보, 크게 표시
            // HIG: 콘텐츠가 주인공, 앱 아이콘/이름 반복 금지
            Text("\(weather.temperature)°")
                .font(.system(size: 36, weight: .light, design: .rounded))
            
            // 도시명 + 최고/최저
            VStack(alignment: .leading, spacing: 0) {
                Text(weather.cityName)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text("최고 \(weather.highTemperature)° 최저 \(weather.lowTemperature)°")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

#Preview("Small Widget", as: .systemSmall) {
    WeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview)
    CurrentWeatherEntry(date: .now, weather: .rainyPreview)
}
