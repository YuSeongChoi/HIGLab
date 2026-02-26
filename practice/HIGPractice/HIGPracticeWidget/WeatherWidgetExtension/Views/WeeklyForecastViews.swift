import SwiftUI
import WidgetKit

// MARK: - 주간 예보 위젯 뷰
// HIG: 주간 예보는 계획 수립에 중요한 정보

// MARK: - Medium Weekly Forecast View

/// 중간 크기 주간 예보 위젯
struct MediumWeeklyForecastView: View {
    let entry: WeeklyForecastEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 헤더
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text("주간 예보")
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(entry.configuration.city.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
            .widgetAccentable()
            
            Divider()
            
            // 예보 행들
            ForEach(entry.displayDailyForecast.prefix(4)) { daily in
                WeeklyForecastRow(
                    daily: daily,
                    displayHigh: entry.displayHigh(for: daily),
                    displayLow: entry.displayLow(for: daily),
                    overallLow: entry.overallLowTemperature,
                    overallHigh: entry.overallHighTemperature
                )
            }
        }
        .widgetURL(entry.configuration.city.deepLinkURL)
    }
}

/// 주간 예보 행
struct WeeklyForecastRow: View {
    let daily: DailyWeather
    let displayHigh: Int
    let displayLow: Int
    let overallLow: Int
    let overallHigh: Int
    
    var body: some View {
        HStack {
            // 요일
            Text(daily.dayOfWeek)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 36, alignment: .leading)
            
            // 날씨 아이콘
            Image(systemName: daily.condition.symbol())
                .symbolRenderingMode(.multicolor)
                .font(.caption)
                .frame(width: 20)
            
            // 강수 확률
            if daily.precipitationChance > 0 {
                Text("\(daily.precipitationChance)%")
                    .font(.system(size: 9))
                    .foregroundStyle(.cyan)
                    .frame(width: 28, alignment: .leading)
            } else {
                Spacer()
                    .frame(width: 28)
            }
            
            // 최저 온도
            Text("\(displayLow)°")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 26, alignment: .trailing)
            
            // 온도 바
            WeeklyTemperatureBar(
                low: daily.low,
                high: daily.high,
                overallLow: overallLow,
                overallHigh: overallHigh
            )
            
            // 최고 온도
            Text("\(displayHigh)°")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 26, alignment: .trailing)
        }
    }
}

/// 주간 온도 바
struct WeeklyTemperatureBar: View {
    let low: Int
    let high: Int
    let overallLow: Int
    let overallHigh: Int
    
    var body: some View {
        GeometryReader { geo in
            let totalRange = CGFloat(overallHigh - overallLow)
            let barStart = totalRange > 0 ? CGFloat(low - overallLow) / totalRange : 0
            let barEnd = totalRange > 0 ? CGFloat(high - overallLow) / totalRange : 1
            let barWidth = (barEnd - barStart) * geo.size.width
            
            ZStack(alignment: .leading) {
                // 배경 트랙
                Capsule()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 5)
                
                // 온도 바
                Capsule()
                    .fill(TemperatureColor.gradient(low: low, high: high))
                    .frame(width: max(barWidth, 4), height: 5)
                    .offset(x: barStart * geo.size.width)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: 16)
    }
}

// MARK: - Large Weekly Forecast View

/// 큰 크기 주간 예보 위젯
struct LargeWeeklyForecastView: View {
    let entry: WeeklyForecastEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 헤더
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("주간 예보")
                            .fontWeight(.semibold)
                    }
                    .font(.headline)
                    
                    Text(entry.configuration.city.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .widgetAccentable()
                
                Spacer()
                
                // 오늘 날씨 요약
                if let today = entry.displayDailyForecast.first {
                    VStack(alignment: .trailing, spacing: 2) {
                        Image(systemName: today.condition.symbol())
                            .symbolRenderingMode(.multicolor)
                            .font(.title2)
                        
                        Text("\(entry.displayHigh(for: today))° / \(entry.displayLow(for: today))°")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Divider()
            
            // 주간 예보 리스트
            VStack(spacing: 6) {
                ForEach(entry.displayDailyForecast) { daily in
                    DetailedWeeklyRow(
                        daily: daily,
                        displayHigh: entry.displayHigh(for: daily),
                        displayLow: entry.displayLow(for: daily),
                        overallLow: entry.overallLowTemperature,
                        overallHigh: entry.overallHighTemperature
                    )
                    
                    if daily.id != entry.displayDailyForecast.last?.id {
                        Divider()
                            .padding(.leading, 40)
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            // 하단 새로고침
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
        .widgetURL(entry.configuration.city.deepLinkURL)
    }
}

/// 상세 주간 예보 행
struct DetailedWeeklyRow: View {
    let daily: DailyWeather
    let displayHigh: Int
    let displayLow: Int
    let overallLow: Int
    let overallHigh: Int
    
    var body: some View {
        HStack(spacing: 8) {
            // 요일 + 날짜
            VStack(alignment: .leading, spacing: 0) {
                Text(daily.dayOfWeek)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(daily.shortDate)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 44, alignment: .leading)
            
            // 날씨 아이콘
            Image(systemName: daily.condition.symbol())
                .symbolRenderingMode(.multicolor)
                .font(.title3)
                .frame(width: 28)
            
            // 강수 확률
            VStack(alignment: .leading, spacing: 0) {
                if daily.precipitationChance > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 8))
                        Text("\(daily.precipitationChance)%")
                    }
                    .font(.caption2)
                    .foregroundStyle(.cyan)
                }
            }
            .frame(width: 36, alignment: .leading)
            
            // 최저 온도
            Text("\(displayLow)°")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .trailing)
            
            // 온도 바
            WeeklyTemperatureBar(
                low: daily.low,
                high: daily.high,
                overallLow: overallLow,
                overallHigh: overallHigh
            )
            
            // 최고 온도
            Text("\(displayHigh)°")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 28, alignment: .trailing)
        }
    }
}

// MARK: - Weekly Forecast Entry View Router

/// 주간 예보 위젯 크기별 뷰 라우터
struct WeeklyForecastEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WeeklyForecastEntry
    
    var body: some View {
        switch family {
        case .systemMedium:
            MediumWeeklyForecastView(entry: entry)
        case .systemLarge:
            LargeWeeklyForecastView(entry: entry)
        default:
            MediumWeeklyForecastView(entry: entry)
        }
    }
}

// MARK: - Previews

#Preview("Medium Weekly", as: .systemMedium) {
    WeeklyForecastWidget()
} timeline: {
    WeeklyForecastEntry(date: .now, weather: .preview, configuration: WeeklyForecastConfigIntent())
}

#Preview("Large Weekly", as: .systemLarge) {
    WeeklyForecastWidget()
} timeline: {
    WeeklyForecastEntry(date: .now, weather: .preview, configuration: WeeklyForecastConfigIntent())
}
