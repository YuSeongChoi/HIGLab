import SwiftUI
import WidgetKit

// MARK: - 현재 날씨 위젯 뷰
// HIG: 위젯은 한눈에 정보를 파악할 수 있어야 함
// 각 크기별로 적절한 정보 밀도 유지

// MARK: - Small Widget View

/// 작은 크기 위젯 뷰 (2x2)
/// HIG: 정보 4개 이내, 콘텐츠가 주인공
struct SmallWeatherView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 날씨 아이콘
            Image(systemName: entry.weather.condition.symbol(isDaytime: entry.weather.isDaytime))
                .font(.title2)
                .symbolRenderingMode(.multicolor)
                .widgetAccentable()
            
            Spacer()
            
            // 메인 온도 표시
            // HIG: 한눈에 파악 — 큰 기온 숫자
            Text("\(entry.displayTemperature)\(entry.temperatureSymbol)")
                .font(.system(size: 42, weight: .light, design: .rounded))
                .contentTransition(.numericText())
                .invalidatableContent()
            
            VStack(alignment: .leading, spacing: 2) {
                // 도시명
                Text(entry.weather.cityName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                // 최고/최저 온도
                Text("H:\(entry.displayHighTemperature)° L:\(entry.displayLowTemperature)°")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(entry.widgetURL)
    }
}

// MARK: - Medium Widget View

/// 중간 크기 위젯 뷰 (4x2)
/// HIG: 시간별 예보와 현재 날씨를 함께 표시
struct MediumWeatherView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        HStack(spacing: 0) {
            // 왼쪽: 현재 날씨 요약
            VStack(alignment: .leading, spacing: 4) {
                // 도시명
                Text(entry.weather.cityName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                // 메인 온도
                Text("\(entry.displayTemperature)°")
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .contentTransition(.numericText())
                    .invalidatableContent()
                
                // 날씨 상태
                Text(entry.weather.condition.shortDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // 최고/최저
                Text("H:\(entry.displayHighTemperature)° L:\(entry.displayLowTemperature)°")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 110)
            .widgetURL(entry.widgetURL)
            
            Divider()
                .padding(.horizontal, 8)
            
            // 오른쪽: 시간별 예보
            HStack(spacing: 0) {
                ForEach(entry.weather.hourlyForecast.prefix(5)) { hourly in
                    HourlyForecastCell(
                        hourly: hourly,
                        temperatureUnit: entry.configuration.temperatureUnit,
                        showPrecipitation: entry.configuration.showPrecipitation
                    )
                }
            }
        }
    }
}

/// 시간별 예보 셀
struct HourlyForecastCell: View {
    let hourly: HourlyWeather
    let temperatureUnit: TemperatureUnitOption
    var showPrecipitation: Bool = true
    
    var body: some View {
        VStack(spacing: 6) {
            // 시간
            Text(hourly.formattedHour)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            // 날씨 아이콘
            Image(systemName: hourly.condition.symbol(isDaytime: hourly.isDaytime))
                .symbolRenderingMode(.multicolor)
                .font(.body)
            
            // 강수 확률 (표시 설정된 경우)
            if showPrecipitation && hourly.precipitationChance > 20 {
                Text("\(hourly.precipitationChance)%")
                    .font(.system(size: 9))
                    .foregroundStyle(.cyan)
            }
            
            // 온도
            Text("\(temperatureUnit.convert(celsius: hourly.temperature))°")
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Large Widget View

/// 큰 크기 위젯 뷰 (4x4)
/// HIG: 풍부한 정보, 인터랙티브 요소 가능
struct LargeWeatherView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 상단: 현재 날씨 요약
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.weather.cityName)
                        .font(.headline)
                    
                    Text("\(entry.displayTemperature)°")
                        .font(.system(size: 56, weight: .light, design: .rounded))
                        .contentTransition(.numericText())
                        .invalidatableContent()
                    
                    Text(entry.weather.condition.detailedDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 날씨 아이콘
                Image(systemName: entry.weather.condition.symbol(isDaytime: entry.weather.isDaytime))
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 54))
            }
            .widgetURL(entry.widgetURL)
            
            // 상세 정보 바
            WeatherDetailsBar(weather: entry.weather, temperatureUnit: entry.configuration.temperatureUnit)
            
            Divider()
            
            // 시간별 예보
            VStack(alignment: .leading, spacing: 6) {
                Text("시간별 예보")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 0) {
                    ForEach(entry.weather.hourlyForecast.prefix(8)) { hourly in
                        HourlyForecastCell(
                            hourly: hourly,
                            temperatureUnit: entry.configuration.temperatureUnit,
                            showPrecipitation: entry.configuration.showPrecipitation
                        )
                    }
                }
            }
            
            Divider()
            
            // 주간 예보 (간략)
            VStack(alignment: .leading, spacing: 4) {
                Text("주간 예보")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                ForEach(entry.weather.dailyForecast.prefix(3)) { daily in
                    CompactDailyRow(
                        daily: daily,
                        temperatureUnit: entry.configuration.temperatureUnit,
                        overallLow: entry.weather.dailyForecast.map { $0.low }.min() ?? 10,
                        overallHigh: entry.weather.dailyForecast.map { $0.high }.max() ?? 30
                    )
                }
            }
            
            Spacer(minLength: 0)
            
            // 인터랙티브 새로고침 버튼 (iOS 17+)
            HStack {
                Spacer()
                
                Button(intent: RefreshWeatherIntent(city: entry.configuration.city)) {
                    Label("새로고침", systemImage: "arrow.clockwise")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// 날씨 상세 정보 바
struct WeatherDetailsBar: View {
    let weather: WeatherData
    let temperatureUnit: TemperatureUnitOption
    
    var body: some View {
        HStack(spacing: 0) {
            WeatherDetailItem(
                label: "체감",
                value: "\(temperatureUnit.convert(celsius: weather.feelsLike))°"
            )
            
            WeatherDetailItem(
                label: "습도",
                value: "\(weather.humidity)%"
            )
            
            WeatherDetailItem(
                label: "풍속",
                value: String(format: "%.1fm/s", weather.windSpeed)
            )
            
            WeatherDetailItem(
                label: "H / L",
                value: "\(temperatureUnit.convert(celsius: weather.highTemperature))° / \(temperatureUnit.convert(celsius: weather.lowTemperature))°"
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(.ultraThinMaterial, in: ContainerRelativeShape())
    }
}

/// 날씨 상세 항목
struct WeatherDetailItem: View {
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

/// 간략한 일별 예보 행
struct CompactDailyRow: View {
    let daily: DailyWeather
    let temperatureUnit: TemperatureUnitOption
    let overallLow: Int
    let overallHigh: Int
    
    var body: some View {
        HStack {
            // 요일
            Text(daily.dayOfWeek)
                .font(.caption)
                .frame(width: 32, alignment: .leading)
            
            // 날씨 아이콘
            Image(systemName: daily.condition.symbol())
                .symbolRenderingMode(.multicolor)
                .font(.caption)
                .frame(width: 20)
            
            // 강수 확률 (있는 경우)
            if daily.precipitationChance > 0 {
                Text("\(daily.precipitationChance)%")
                    .font(.system(size: 9))
                    .foregroundStyle(.cyan)
                    .frame(width: 28)
            } else {
                Spacer()
                    .frame(width: 28)
            }
            
            // 최저 온도
            Text("\(temperatureUnit.convert(celsius: daily.low))°")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .trailing)
            
            // 온도 바
            TemperatureBar(
                low: daily.low,
                high: daily.high,
                overallLow: overallLow,
                overallHigh: overallHigh
            )
            .frame(height: 4)
            
            // 최고 온도
            Text("\(temperatureUnit.convert(celsius: daily.high))°")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 24, alignment: .trailing)
        }
    }
}

/// 온도 범위 바
struct TemperatureBar: View {
    let low: Int
    let high: Int
    let overallLow: Int
    let overallHigh: Int
    
    var body: some View {
        GeometryReader { geo in
            let totalRange = CGFloat(overallHigh - overallLow)
            let barStart = totalRange > 0 ? CGFloat(low - overallLow) / totalRange : 0
            let barWidth = totalRange > 0 ? CGFloat(high - low) / totalRange : 1
            
            ZStack(alignment: .leading) {
                // 배경 트랙
                Capsule()
                    .fill(.quaternary)
                
                // 온도 바
                Capsule()
                    .fill(TemperatureColor.gradient(low: low, high: high))
                    .frame(width: geo.size.width * barWidth)
                    .offset(x: geo.size.width * barStart)
            }
        }
    }
}

// MARK: - Extra Large Widget View (iPad)

/// 아이패드용 Extra Large 위젯
struct ExtraLargeWeatherView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        HStack(spacing: 20) {
            // 왼쪽: 현재 날씨 + 상세
            VStack(alignment: .leading, spacing: 12) {
                // 현재 날씨
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.weather.cityName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("\(entry.displayTemperature)°")
                            .font(.system(size: 72, weight: .thin, design: .rounded))
                            .contentTransition(.numericText())
                        
                        Text(entry.weather.condition.detailedDescription)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: entry.weather.condition.symbol(isDaytime: entry.weather.isDaytime))
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 80))
                }
                
                // 상세 정보
                WeatherDetailsBar(weather: entry.weather, temperatureUnit: entry.configuration.temperatureUnit)
                
                Spacer()
                
                // 일출/일몰
                HStack(spacing: 20) {
                    SunEventView(
                        title: "일출",
                        time: entry.weather.formattedSunrise,
                        symbol: "sunrise.fill"
                    )
                    
                    SunEventView(
                        title: "일몰",
                        time: entry.weather.formattedSunset,
                        symbol: "sunset.fill"
                    )
                }
            }
            .frame(maxWidth: 300)
            
            Divider()
            
            // 오른쪽: 예보
            VStack(alignment: .leading, spacing: 12) {
                // 시간별 예보
                VStack(alignment: .leading, spacing: 8) {
                    Text("시간별 예보")
                        .font(.headline)
                    
                    HStack(spacing: 0) {
                        ForEach(entry.weather.hourlyForecast.prefix(12)) { hourly in
                            HourlyForecastCell(
                                hourly: hourly,
                                temperatureUnit: entry.configuration.temperatureUnit,
                                showPrecipitation: entry.configuration.showPrecipitation
                            )
                        }
                    }
                }
                
                Divider()
                
                // 주간 예보
                VStack(alignment: .leading, spacing: 8) {
                    Text("주간 예보")
                        .font(.headline)
                    
                    ForEach(entry.weather.dailyForecast) { daily in
                        CompactDailyRow(
                            daily: daily,
                            temperatureUnit: entry.configuration.temperatureUnit,
                            overallLow: entry.weather.dailyForecast.map { $0.low }.min() ?? 10,
                            overallHigh: entry.weather.dailyForecast.map { $0.high }.max() ?? 30
                        )
                    }
                }
            }
        }
    }
}

/// 일출/일몰 표시 뷰
struct SunEventView: View {
    let title: String
    let time: String
    let symbol: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .symbolRenderingMode(.multicolor)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(time)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
}

// MARK: - Entry View Router

/// 위젯 크기별 뷰 라우터
struct CurrentWeatherEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: CurrentWeatherEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWeatherView(entry: entry)
        case .systemMedium:
            MediumWeatherView(entry: entry)
        case .systemLarge:
            LargeWeatherView(entry: entry)
        case .systemExtraLarge:
            ExtraLargeWeatherView(entry: entry)
        case .accessoryCircular:
            CircularWeatherView(entry: entry)
        case .accessoryRectangular:
            RectangularWeatherView(entry: entry)
        case .accessoryInline:
            InlineWeatherView(entry: entry)
        @unknown default:
            SmallWeatherView(entry: entry)
        }
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    CurrentWeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview, configuration: SelectCityIntent())
    CurrentWeatherEntry(date: .now, weather: .rainyPreview, configuration: SelectCityIntent(city: .busan))
}

#Preview("Medium", as: .systemMedium) {
    CurrentWeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview, configuration: SelectCityIntent())
}

#Preview("Large", as: .systemLarge) {
    CurrentWeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview, configuration: SelectCityIntent())
}
