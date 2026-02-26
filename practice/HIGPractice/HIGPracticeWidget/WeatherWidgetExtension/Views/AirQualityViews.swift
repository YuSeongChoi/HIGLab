import SwiftUI
import WidgetKit

// MARK: - 대기질 위젯 뷰
// HIG: 대기질 정보는 건강과 직결되므로 명확하게 전달

// MARK: - Small Air Quality View

/// 작은 크기 대기질 위젯
struct SmallAirQualityView: View {
    let entry: AirQualityEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 헤더
            HStack {
                Image(systemName: entry.airQuality.category.symbol)
                    .font(.caption)
                    .foregroundStyle(entry.airQuality.category.color)
                
                Text("대기질")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .widgetAccentable()
            
            Spacer()
            
            // AQI 값
            Text("\(entry.airQuality.aqi)")
                .font(.system(size: 48, weight: .medium, design: .rounded))
                .foregroundStyle(entry.airQuality.category.color)
                .contentTransition(.numericText())
                .invalidatableContent()
            
            // 등급
            Text(entry.airQuality.category.rawValue)
                .font(.caption)
                .fontWeight(.medium)
            
            // 도시
            Text(entry.configuration.city.displayName)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(entry.widgetURL)
    }
}

// MARK: - Medium Air Quality View

/// 중간 크기 대기질 위젯
struct MediumAirQualityView: View {
    let entry: AirQualityEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // 왼쪽: 메인 정보
            VStack(alignment: .leading, spacing: 4) {
                // 헤더
                HStack {
                    Image(systemName: entry.airQuality.category.symbol)
                        .foregroundStyle(entry.airQuality.category.color)
                    Text("대기질")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .widgetAccentable()
                
                // AQI
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(entry.airQuality.aqi)")
                        .font(.system(size: 44, weight: .medium, design: .rounded))
                        .foregroundStyle(entry.airQuality.category.color)
                        .contentTransition(.numericText())
                    
                    Text("AQI")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // 등급 + 이모지
                HStack {
                    Text(entry.airQuality.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(entry.airQuality.category.emoji)
                }
                
                // 도시
                Text(entry.configuration.city.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 100)
            
            Divider()
            
            // 오른쪽: 상세 정보
            if entry.configuration.showDetails {
                VStack(alignment: .leading, spacing: 8) {
                    // PM2.5
                    PollutantRow(
                        name: "PM2.5",
                        value: String(format: "%.0f", entry.airQuality.pm25),
                        unit: "μg/m³",
                        level: pm25Level(entry.airQuality.pm25)
                    )
                    
                    // PM10
                    PollutantRow(
                        name: "PM10",
                        value: String(format: "%.0f", entry.airQuality.pm10),
                        unit: "μg/m³",
                        level: pm10Level(entry.airQuality.pm10)
                    )
                    
                    // 오존
                    PollutantRow(
                        name: "O₃",
                        value: String(format: "%.0f", entry.airQuality.o3),
                        unit: "ppb",
                        level: .moderate
                    )
                    
                    Spacer()
                    
                    // 권고사항
                    Text(entry.airQuality.healthAdvice)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            } else {
                // 간단 버전
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 16) {
                        SimplePollutantView(name: "PM2.5", value: entry.airQuality.pm25)
                        SimplePollutantView(name: "PM10", value: entry.airQuality.pm10)
                    }
                    
                    Spacer()
                    
                    // 마스크 권고
                    if entry.airQuality.shouldWearMask {
                        Label("마스크 착용 권장", systemImage: "facemask")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .widgetURL(entry.widgetURL)
    }
    
    // PM2.5 레벨 판정
    private func pm25Level(_ value: Double) -> AirQualityLevel {
        switch value {
        case 0...15: return .good
        case 16...35: return .moderate
        case 36...75: return .unhealthyForSensitive
        case 76...150: return .unhealthy
        default: return .veryUnhealthy
        }
    }
    
    // PM10 레벨 판정
    private func pm10Level(_ value: Double) -> AirQualityLevel {
        switch value {
        case 0...30: return .good
        case 31...80: return .moderate
        case 81...150: return .unhealthyForSensitive
        case 151...300: return .unhealthy
        default: return .veryUnhealthy
        }
    }
}

/// 오염물질 행
struct PollutantRow: View {
    let name: String
    let value: String
    let unit: String
    let level: AirQualityLevel
    
    var body: some View {
        HStack {
            Text(name)
                .font(.caption)
                .frame(width: 40, alignment: .leading)
            
            // 레벨 바
            RoundedRectangle(cornerRadius: 2)
                .fill(level.color)
                .frame(width: 8, height: 8)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(unit)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
    }
}

/// 간단한 오염물질 뷰
struct SimplePollutantView: View {
    let name: String
    let value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text(String(format: "%.0f", value))
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Large Air Quality View

/// 큰 크기 대기질 위젯
struct LargeAirQualityView: View {
    let entry: AirQualityEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: entry.airQuality.category.symbol)
                            .foregroundStyle(entry.airQuality.category.color)
                        Text("대기질")
                            .fontWeight(.semibold)
                    }
                    .font(.headline)
                    
                    Text(entry.configuration.city.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // AQI 원형 게이지
                AQIGaugeView(aqi: entry.airQuality.aqi, level: entry.airQuality.category)
                    .frame(width: 80, height: 80)
            }
            
            // 등급 설명
            Text(entry.airQuality.category.healthAdvice)
                .font(.subheadline)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(entry.airQuality.category.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
            
            Divider()
            
            // 상세 오염물질 그리드
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    DetailedPollutantCard(
                        name: "초미세먼지",
                        symbol: "PM2.5",
                        value: entry.airQuality.pm25,
                        unit: "μg/m³",
                        color: pm25Color(entry.airQuality.pm25)
                    )
                    
                    DetailedPollutantCard(
                        name: "미세먼지",
                        symbol: "PM10",
                        value: entry.airQuality.pm10,
                        unit: "μg/m³",
                        color: pm10Color(entry.airQuality.pm10)
                    )
                }
                
                HStack(spacing: 12) {
                    DetailedPollutantCard(
                        name: "오존",
                        symbol: "O₃",
                        value: entry.airQuality.o3,
                        unit: "ppb",
                        color: .blue
                    )
                    
                    DetailedPollutantCard(
                        name: "이산화질소",
                        symbol: "NO₂",
                        value: entry.airQuality.no2,
                        unit: "ppb",
                        color: .orange
                    )
                }
            }
            
            Spacer()
            
            // 하단: 주요 오염물질 + 갱신 시간
            HStack {
                Label("주요: \(entry.airQuality.dominantPollutant.description)", systemImage: "exclamationmark.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(intent: RefreshWeatherIntent(city: entry.configuration.city)) {
                    Label("새로고침", systemImage: "arrow.clockwise")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .widgetURL(entry.widgetURL)
    }
    
    private func pm25Color(_ value: Double) -> Color {
        switch value {
        case 0...15: return .green
        case 16...35: return .yellow
        case 36...75: return .orange
        default: return .red
        }
    }
    
    private func pm10Color(_ value: Double) -> Color {
        switch value {
        case 0...30: return .green
        case 31...80: return .yellow
        case 81...150: return .orange
        default: return .red
        }
    }
}

/// AQI 원형 게이지 뷰
struct AQIGaugeView: View {
    let aqi: Int
    let level: AirQualityLevel
    
    var body: some View {
        ZStack {
            // 배경 원
            Circle()
                .stroke(level.color.opacity(0.2), lineWidth: 8)
            
            // 진행 원
            Circle()
                .trim(from: 0, to: CGFloat(min(aqi, 300)) / 300)
                .stroke(level.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            // 값
            VStack(spacing: 0) {
                Text("\(aqi)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(level.color)
                
                Text("AQI")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// 상세 오염물질 카드
struct DetailedPollutantCard: View {
    let name: String
    let symbol: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 심볼 + 값
            HStack {
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(color)
                
                Spacer()
                
                Text(String(format: "%.0f", value))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(unit)
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
            
            // 이름
            Text(name)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            // 레벨 바
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.2))
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * min(value / 100, 1))
                }
            }
            .frame(height: 4)
        }
        .padding(10)
        .background(.ultraThinMaterial, in: ContainerRelativeShape())
    }
}

// MARK: - Air Quality Entry View Router

/// 대기질 위젯 크기별 뷰 라우터
struct AirQualityEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: AirQualityEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallAirQualityView(entry: entry)
        case .systemMedium:
            MediumAirQualityView(entry: entry)
        case .systemLarge:
            LargeAirQualityView(entry: entry)
        case .accessoryRectangular:
            RectangularAirQualityView(entry: entry)
        case .accessoryInline:
            InlineAirQualityView(entry: entry)
        case .accessoryCircular:
            CircularAirQualityView(entry: entry)
        default:
            SmallAirQualityView(entry: entry)
        }
    }
}

/// 원형 대기질 뷰 (잠금화면)
struct CircularAirQualityView: View {
    let entry: AirQualityEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            Gauge(value: Double(entry.airQuality.aqi), in: 0...300) {
                Image(systemName: entry.airQuality.category.symbol)
            } currentValueLabel: {
                Text("\(entry.airQuality.aqi)")
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
            .gaugeStyle(.accessoryCircular)
            .tint(entry.airQuality.category.color)
        }
    }
}

// MARK: - Previews

#Preview("Small Air Quality", as: .systemSmall) {
    AirQualityWidget()
} timeline: {
    AirQualityEntry(date: .now, airQuality: .preview, weather: .preview, configuration: AirQualityConfigIntent())
    AirQualityEntry(date: .now, airQuality: .unhealthyPreview, weather: .preview, configuration: AirQualityConfigIntent())
}

#Preview("Medium Air Quality", as: .systemMedium) {
    AirQualityWidget()
} timeline: {
    AirQualityEntry(date: .now, airQuality: .preview, weather: .preview, configuration: AirQualityConfigIntent())
}

#Preview("Large Air Quality", as: .systemLarge) {
    AirQualityWidget()
} timeline: {
    AirQualityEntry(date: .now, airQuality: .preview, weather: .preview, configuration: AirQualityConfigIntent())
}
