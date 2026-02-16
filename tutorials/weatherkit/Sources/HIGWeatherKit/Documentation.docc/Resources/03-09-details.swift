import WeatherKit
import SwiftUI

// 날씨 상세 정보 그리드

struct WeatherDetailsGrid: View {
    let weather: CurrentWeather
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            DetailCard(
                icon: "humidity.fill",
                title: "습도",
                value: "\(Int(weather.humidity * 100))%"
            )
            
            DetailCard(
                icon: "wind",
                title: "바람",
                value: weather.wind.speed.formatted()
            )
            
            DetailCard(
                icon: "sun.max.fill",
                title: "UV 지수",
                value: "\(weather.uvIndex.value)"
            )
            
            DetailCard(
                icon: "eye.fill",
                title: "가시거리",
                value: weather.visibility.formatted()
            )
            
            DetailCard(
                icon: "gauge",
                title: "기압",
                value: weather.pressure.formatted()
            )
            
            DetailCard(
                icon: "thermometer.snowflake",
                title: "이슬점",
                value: weather.dewPoint.formatted()
            )
        }
        .padding()
    }
}

struct DetailCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
