import SwiftUI
import WidgetKit

// MARK: - Large Widget with Interactive Button
// HIG: 인터랙티브 요소는 명확한 목적이 있을 때만 추가하세요.
// Small 위젯에는 넣지 마세요 — 공간이 작아 탭 정확도가 떨어집니다.

struct LargeWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: 헤더 - 현재 날씨 + 새로고침 버튼
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(weather.cityName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("\(weather.temperature)°")
                        .font(.system(size: 54, weight: .thin, design: .rounded))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Image(systemName: weather.condition.symbol)
                        .font(.largeTitle)
                        .symbolRenderingMode(.multicolor)
                    
                    Text(weather.condition.rawValue)
                        .font(.callout)
                    
                    // MARK: 새로고침 버튼
                    // Button(intent:)로 앱을 열지 않고 바로 실행
                    Button(intent: RefreshWeatherIntent()) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("새로고침")
                        }
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
            
            // MARK: 시간별 예보 (탭 가능한 영역)
            HStack(spacing: 0) {
                ForEach(Array(weather.hourlyForecast.prefix(6).enumerated()), id: \.element.id) { index, hourly in
                    // 각 시간을 탭하면 해당 시간대 상세로 이동
                    Link(destination: URL(string: "weatherapp://hour/\(index)")!) {
                        VStack(spacing: 8) {
                            Text(index == 0 ? "지금" : hourly.hour)
                                .font(.caption2)
                                .foregroundStyle(index == 0 ? .primary : .secondary)
                            
                            Image(systemName: hourly.condition.symbol)
                                .symbolRenderingMode(.multicolor)
                                .font(.title3)
                            
                            Text("\(hourly.temperature)°")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            
            Divider()
            
            // MARK: 주간 예보
            VStack(spacing: 8) {
                ForEach(WeatherData.previewDaily.prefix(4)) { daily in
                    HStack {
                        Text(daily.day)
                            .font(.subheadline)
                            .frame(width: 40, alignment: .leading)
                        
                        Image(systemName: daily.condition.symbol)
                            .symbolRenderingMode(.multicolor)
                            .font(.body)
                        
                        Spacer()
                        
                        Text("\(daily.lowTemperature)°")
                            .foregroundStyle(.secondary)
                        Text("\(daily.highTemperature)°")
                    }
                    .font(.caption)
                }
            }
        }
    }
}

// MARK: - Medium Widget with Toggle
struct MediumWeatherWithFavorite: View {
    let weather: WeatherData
    let isFavorite: Bool
    
    var body: some View {
        HStack {
            // 날씨 정보
            VStack(alignment: .leading) {
                Text(weather.cityName)
                    .font(.headline)
                Text("\(weather.temperature)°")
                    .font(.largeTitle)
            }
            
            Spacer()
            
            // 즐겨찾기 토글
            Toggle(isOn: isFavorite, intent: ToggleFavoriteIntent(city: .seoul)) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundStyle(isFavorite ? .yellow : .gray)
            }
            .toggleStyle(.button)
            .buttonStyle(.plain)
        }
    }
}
