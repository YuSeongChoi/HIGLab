import WeatherKit
import SwiftUI

// 현재 날씨 View

struct CurrentWeatherView: View {
    let weather: CurrentWeather
    
    var body: some View {
        VStack(spacing: 16) {
            // 날씨 아이콘
            Image(systemName: weather.condition.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 80))
            
            // 현재 온도
            Text(weather.temperature.formatted())
                .font(.system(size: 64, weight: .thin))
            
            // 날씨 상태
            Text(weather.condition.description)
                .font(.title2)
                .foregroundStyle(.secondary)
            
            // 체감 온도
            HStack {
                Text("체감")
                Text(weather.apparentTemperature.formatted())
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
    }
}
