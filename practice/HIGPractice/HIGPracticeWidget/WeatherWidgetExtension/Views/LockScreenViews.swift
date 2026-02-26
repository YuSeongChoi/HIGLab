import SwiftUI
import WidgetKit

// MARK: - 잠금화면 위젯 뷰
// HIG: 잠금화면 위젯은 극도로 간결하게, 시스템이 색상을 제어
// 세 가지 크기: Circular, Rectangular, Inline

// MARK: - Accessory Circular View

/// 원형 잠금화면 위젯
/// HIG: 게이지나 간단한 정보 표시에 적합
struct CircularWeatherView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        ZStack {
            // 배경
            AccessoryWidgetBackground()
            
            // 온도 게이지
            Gauge(value: normalizedTemperature, in: 0...1) {
                // 게이지 라벨 (화면에 표시 안됨)
                Image(systemName: entry.weather.condition.symbol(isDaytime: entry.weather.isDaytime))
            } currentValueLabel: {
                // 현재 온도
                Text("\(entry.displayTemperature)°")
                    .font(.system(.body, design: .rounded, weight: .medium))
            } minimumValueLabel: {
                // 최저 온도
                Text("\(entry.displayLowTemperature)°")
                    .font(.system(.caption2))
            } maximumValueLabel: {
                // 최고 온도
                Text("\(entry.displayHighTemperature)°")
                    .font(.system(.caption2))
            }
            .gaugeStyle(.accessoryCircular)
            .widgetAccentable()
        }
    }
    
    /// 온도를 0-1 범위로 정규화
    private var normalizedTemperature: Double {
        let temp = Double(entry.weather.temperature)
        let low = Double(entry.weather.lowTemperature)
        let high = Double(entry.weather.highTemperature)
        
        guard high > low else { return 0.5 }
        return (temp - low) / (high - low)
    }
}

/// 원형 위젯 - 날씨 아이콘 버전
struct CircularWeatherIconView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            VStack(spacing: 2) {
                Image(systemName: entry.weather.condition.symbol(isDaytime: entry.weather.isDaytime))
                    .font(.title2)
                    .widgetAccentable()
                
                Text("\(entry.displayTemperature)°")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
            }
        }
    }
}

/// 원형 위젯 - 강수 확률 버전
struct CircularPrecipitationView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            // 다음 1시간 내 강수 확률
            let nextHourPrecip = entry.weather.hourlyForecast.first?.precipitationChance ?? 0
            
            Gauge(value: Double(nextHourPrecip), in: 0...100) {
                Image(systemName: "drop.fill")
            } currentValueLabel: {
                Text("\(nextHourPrecip)%")
                    .font(.system(.caption, design: .rounded, weight: .medium))
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(.cyan)
        }
    }
}

// MARK: - Accessory Rectangular View

/// 직사각형 잠금화면 위젯
/// HIG: 더 많은 정보 표시 가능, 계층 구조 유지
struct RectangularWeatherView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 도시명 (강조)
            Text(entry.weather.cityName)
                .font(.headline)
                .widgetAccentable()
            
            // 현재 날씨
            HStack(spacing: 6) {
                Image(systemName: entry.weather.condition.symbol(isDaytime: entry.weather.isDaytime))
                    .font(.body)
                
                Text("\(entry.displayTemperature)°")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text(entry.weather.condition.shortDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // 최고/최저 + 강수 확률
            HStack {
                Text("H:\(entry.displayHighTemperature)° L:\(entry.displayLowTemperature)°")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                if let nextPrecip = entry.weather.hourlyForecast.first?.precipitationChance,
                   nextPrecip > 20 {
                    Spacer()
                    Label("\(nextPrecip)%", systemImage: "drop.fill")
                        .font(.caption2)
                        .foregroundStyle(.cyan)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 직사각형 위젯 - 시간별 예보 버전
struct RectangularHourlyView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 도시명
            Text(entry.weather.cityName)
                .font(.caption)
                .fontWeight(.semibold)
                .widgetAccentable()
            
            // 시간별 예보 (4시간)
            HStack(spacing: 0) {
                ForEach(entry.weather.hourlyForecast.prefix(4)) { hourly in
                    VStack(spacing: 2) {
                        Text(hourly.formattedHour)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: hourly.condition.symbol(isDaytime: hourly.isDaytime))
                            .font(.caption2)
                        
                        Text("\(entry.configuration.temperatureUnit.convert(celsius: hourly.temperature))°")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

/// 직사각형 위젯 - 대기질 버전
struct RectangularAirQualityView: View {
    let entry: AirQualityEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 제목
            HStack {
                Text("대기질")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(entry.configuration.city.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .widgetAccentable()
            
            // AQI 값과 등급
            HStack(spacing: 8) {
                Text("\(entry.airQuality.aqi)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(entry.airQuality.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(entry.airQuality.category.emoji)
                        .font(.caption)
                }
            }
            
            // 주요 오염물질
            Text("주요: \(entry.airQuality.dominantPollutant.description)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 직사각형 위젯 - UV 지수 버전
struct RectangularUVIndexView: View {
    let entry: UVIndexEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 제목
            HStack {
                Text("자외선 지수")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .widgetAccentable()
                
                Spacer()
                
                Text(entry.configuration.city.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            // UV 지수
            HStack(spacing: 8) {
                Text("\(entry.uvIndex.currentIndex)")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(entry.uvIndex.level.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text("SPF \(entry.uvIndex.level.recommendedSPF)+ 권장")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 최대 시간
            Text("오늘 최대 \(entry.uvIndex.maxIndex) (\(entry.uvIndex.maxTime.formatted(.dateTime.hour())))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Accessory Inline View

/// 인라인 잠금화면 위젯
/// HIG: 한 줄에 핵심 정보만, 시계 아래 표시
struct InlineWeatherView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        // HIG: 인라인은 텍스트와 SF Symbol만 지원
        Label {
            Text("\(entry.weather.condition.shortDescription) \(entry.displayTemperature)°")
        } icon: {
            Image(systemName: entry.weather.condition.symbol(isDaytime: entry.weather.isDaytime))
        }
    }
}

/// 인라인 위젯 - 강수 정보 버전
struct InlinePrecipitationView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        let nextPrecip = entry.weather.hourlyForecast.first?.precipitationChance ?? 0
        
        if nextPrecip > 20 {
            Label {
                Text("강수 \(nextPrecip)% • \(entry.displayTemperature)°")
            } icon: {
                Image(systemName: "umbrella.fill")
            }
        } else {
            Label {
                Text("\(entry.weather.cityName) \(entry.displayTemperature)°")
            } icon: {
                Image(systemName: entry.weather.condition.symbol(isDaytime: entry.weather.isDaytime))
            }
        }
    }
}

/// 인라인 위젯 - 대기질 버전
struct InlineAirQualityView: View {
    let entry: AirQualityEntry
    
    var body: some View {
        Label {
            Text("대기질 \(entry.airQuality.aqi) \(entry.airQuality.category.rawValue)")
        } icon: {
            Image(systemName: entry.airQuality.category.symbol)
        }
    }
}

/// 인라인 위젯 - UV 지수 버전
struct InlineUVIndexView: View {
    let entry: UVIndexEntry
    
    var body: some View {
        Label {
            Text("UV \(entry.uvIndex.currentIndex) \(entry.uvIndex.level.rawValue)")
        } icon: {
            Image(systemName: entry.uvIndex.level.symbol)
        }
    }
}

// MARK: - StandBy Mode Views (iOS 17+)

/// StandBy 모드용 대형 원형 뷰
struct StandByCircularView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        ZStack {
            // 날씨에 따른 배경
            Circle()
                .fill(entry.weather.condition.lockScreenColor.opacity(0.3))
            
            VStack(spacing: 4) {
                Image(systemName: entry.weather.condition.symbol(isDaytime: entry.weather.isDaytime))
                    .font(.system(size: 48))
                    .symbolRenderingMode(.multicolor)
                
                Text("\(entry.displayTemperature)°")
                    .font(.system(size: 36, weight: .medium, design: .rounded))
                
                Text(entry.weather.cityName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Lock Screen Widget Previews

#Preview("Circular", as: .accessoryCircular) {
    CurrentWeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview, configuration: SelectCityIntent())
}

#Preview("Rectangular", as: .accessoryRectangular) {
    CurrentWeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview, configuration: SelectCityIntent())
}

#Preview("Inline", as: .accessoryInline) {
    CurrentWeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview, configuration: SelectCityIntent())
}

// MARK: - Lock Screen Entry View Router

/// 잠금화면 위젯 크기별 뷰 라우터
struct LockScreenEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: CurrentWeatherEntry
    var variant: LockScreenVariant = .default
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            switch variant {
            case .default:
                CircularWeatherView(entry: entry)
            case .icon:
                CircularWeatherIconView(entry: entry)
            case .precipitation:
                CircularPrecipitationView(entry: entry)
            }
            
        case .accessoryRectangular:
            switch variant {
            case .default:
                RectangularWeatherView(entry: entry)
            case .hourly:
                RectangularHourlyView(entry: entry)
            default:
                RectangularWeatherView(entry: entry)
            }
            
        case .accessoryInline:
            switch variant {
            case .default:
                InlineWeatherView(entry: entry)
            case .precipitation:
                InlinePrecipitationView(entry: entry)
            default:
                InlineWeatherView(entry: entry)
            }
            
        default:
            CircularWeatherView(entry: entry)
        }
    }
}

/// 잠금화면 위젯 변형 타입
enum LockScreenVariant {
    case `default`
    case icon
    case precipitation
    case hourly
}
