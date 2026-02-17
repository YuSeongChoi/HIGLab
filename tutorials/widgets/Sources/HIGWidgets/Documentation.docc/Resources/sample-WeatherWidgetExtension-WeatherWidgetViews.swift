import SwiftUI
import WidgetKit

// MARK: - Small Widget View
// HIG: 정보 4개 이내, 콘텐츠가 주인공

struct SmallWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: weather.condition.symbol)
                .font(.title2)
                .symbolRenderingMode(.multicolor)
            
            Spacer()
            
            // HIG: 한눈에 파악 — 큰 기온 숫자
            Text("\(weather.temperature)°")
                .font(.system(size: 36, weight: .light, design: .rounded))
                .contentTransition(.numericText())
            
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

// MARK: - Medium Widget View
// HIG: 복수 딥링크 가능, 시간별 예보 추가

struct MediumWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        HStack(spacing: 16) {
            // 왼쪽: 현재 날씨
            VStack(alignment: .leading, spacing: 4) {
                Text(weather.cityName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(weather.temperature)°")
                    .font(.system(size: 44, weight: .light, design: .rounded))
                    .contentTransition(.numericText())
                
                Text(weather.condition.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("최고 \(weather.highTemperature)° 최저 \(weather.lowTemperature)°")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 100)
            
            Divider()
            
            // 오른쪽: 시간별 예보
            HStack(spacing: 12) {
                ForEach(weather.hourlyForecast.prefix(5)) { hourly in
                    VStack(spacing: 6) {
                        Text(hourly.hour)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: hourly.condition.symbol)
                            .symbolRenderingMode(.multicolor)
                            .font(.body)
                        
                        Text("\(hourly.temperature)°")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
}

// MARK: - Large Widget View
// HIG: 풍부한 정보, 인터랙티브 요소 가능

struct LargeWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단: 현재 날씨
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(weather.cityName)
                        .font(.headline)
                    
                    Text("\(weather.temperature)°")
                        .font(.system(size: 52, weight: .light, design: .rounded))
                        .contentTransition(.numericText())
                    
                    Text(weather.condition.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: weather.condition.symbol)
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 48))
            }
            
            // 중단: 상세 정보
            HStack(spacing: 20) {
                DetailItem(label: "체감", value: "\(weather.temperature - 2)°")
                DetailItem(label: "습도", value: "\(weather.humidity)%")
                DetailItem(label: "풍속", value: String(format: "%.1fm/s", weather.windSpeed))
                DetailItem(label: "최고/최저", value: "\(weather.highTemperature)°/\(weather.lowTemperature)°")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            
            Divider()
            
            // 하단: 시간별 예보
            Text("시간별 예보")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 0) {
                ForEach(weather.hourlyForecast) { hourly in
                    VStack(spacing: 6) {
                        Text(hourly.hour)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: hourly.condition.symbol)
                            .symbolRenderingMode(.multicolor)
                            .font(.callout)
                        
                        Text("\(hourly.temperature)°")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // 주간 예보
            Divider()
            
            ForEach(weather.dailyForecast.prefix(3)) { daily in
                HStack {
                    Text(daily.dayOfWeek)
                        .font(.caption)
                        .frame(width: 30, alignment: .leading)
                    
                    Image(systemName: daily.condition.symbol)
                        .symbolRenderingMode(.multicolor)
                        .font(.caption)
                        .frame(width: 24)
                    
                    Text("\(daily.low)°")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 28, alignment: .trailing)
                    
                    // 온도 바
                    GeometryReader { geo in
                        let range = CGFloat(daily.high - daily.low)
                        let maxRange: CGFloat = 15
                        let width = min(geo.size.width * (range / maxRange), geo.size.width)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(daily.condition.gradient)
                            .frame(width: width, height: 4)
                            .frame(maxHeight: .infinity, alignment: .center)
                    }
                    .frame(height: 16)
                    
                    Text("\(daily.high)°")
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: 28, alignment: .trailing)
                }
            }
        }
    }
}

struct DetailItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Lock Screen Widgets
// HIG: 극도로 간결, 시스템이 색상 제어

struct CircularWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        Gauge(value: Double(weather.temperature), in: -10...40) {
            Image(systemName: weather.condition.symbol)
        } currentValueLabel: {
            Text("\(weather.temperature)°")
                .font(.system(.body, design: .rounded, weight: .medium))
        }
        .gaugeStyle(.accessoryCircular)
    }
}

struct RectangularWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(weather.cityName)
                .font(.headline)
                .widgetAccentable()
            
            HStack(spacing: 4) {
                Image(systemName: weather.condition.symbol)
                Text("\(weather.temperature)°")
                    .font(.title2)
                    .fontWeight(.medium)
                Text(weather.condition.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text("최고 \(weather.highTemperature)° 최저 \(weather.lowTemperature)°")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Entry View (크기별 분기)

struct WeatherWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: CurrentWeatherEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWeatherView(weather: entry.weather)
        case .systemMedium:
            MediumWeatherView(weather: entry.weather)
        case .systemLarge:
            LargeWeatherView(weather: entry.weather)
        case .accessoryCircular:
            CircularWeatherView(weather: entry.weather)
        case .accessoryRectangular:
            RectangularWeatherView(weather: entry.weather)
        case .accessoryInline:
            Text("\(entry.weather.condition.rawValue) \(entry.weather.temperature)°")
        default:
            SmallWeatherView(weather: entry.weather)
        }
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    WeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview)
    CurrentWeatherEntry(date: .now, weather: .rainyPreview)
}

#Preview("Medium", as: .systemMedium) {
    WeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview)
}

#Preview("Large", as: .systemLarge) {
    WeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview)
}

#Preview("Circular", as: .accessoryCircular) {
    WeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview)
}
