import SwiftUI
import WidgetKit

// MARK: - 자외선 지수 위젯 뷰
// HIG: UV 지수는 야외 활동 계획에 중요한 정보

// MARK: - Small UV Index View

/// 작은 크기 UV 지수 위젯
struct SmallUVIndexView: View {
    let entry: UVIndexEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 헤더
            HStack {
                Image(systemName: entry.uvIndex.level.symbol)
                    .font(.caption)
                    .foregroundStyle(entry.uvIndex.level.color)
                
                Text("자외선")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .widgetAccentable()
            
            Spacer()
            
            // UV 지수
            Text("\(entry.uvIndex.currentIndex)")
                .font(.system(size: 52, weight: .medium, design: .rounded))
                .foregroundStyle(entry.uvIndex.level.color)
                .contentTransition(.numericText())
                .invalidatableContent()
            
            // 등급
            Text(entry.uvIndex.level.rawValue)
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

// MARK: - Medium UV Index View

/// 중간 크기 UV 지수 위젯
struct MediumUVIndexView: View {
    let entry: UVIndexEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // 왼쪽: 메인 정보
            VStack(alignment: .leading, spacing: 4) {
                // 헤더
                HStack {
                    Image(systemName: entry.uvIndex.level.symbol)
                        .foregroundStyle(entry.uvIndex.level.color)
                    Text("자외선 지수")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .widgetAccentable()
                
                // UV 지수
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(entry.uvIndex.currentIndex)")
                        .font(.system(size: 44, weight: .medium, design: .rounded))
                        .foregroundStyle(entry.uvIndex.level.color)
                        .contentTransition(.numericText())
                    
                    Text(entry.uvIndex.level.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // 도시
                Text(entry.configuration.city.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                // 보호 권고
                Text(entry.uvIndex.level.protectionAdvice)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(minWidth: 120)
            
            Divider()
            
            // 오른쪽: 시간별 UV 예보
            if entry.configuration.showHourlyForecast {
                VStack(alignment: .leading, spacing: 8) {
                    Text("시간별 자외선")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 0) {
                        ForEach(entry.displayHourlyForecast) { hourly in
                            HourlyUVCell(hourly: hourly)
                        }
                    }
                    
                    Spacer()
                    
                    // 오늘 최대
                    HStack {
                        Image(systemName: "sun.max.trianglebadge.exclamationmark.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        
                        Text("오늘 최대 \(entry.uvIndex.maxIndex)")
                            .font(.caption2)
                        
                        Text(entry.uvIndex.maxTime.formatted(.dateTime.hour()))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                // 간단 버전
                VStack(alignment: .center, spacing: 12) {
                    // UV 게이지
                    UVGaugeView(uvIndex: entry.uvIndex.currentIndex, level: entry.uvIndex.level)
                        .frame(width: 100, height: 60)
                    
                    // SPF 권장
                    Label("SPF \(entry.uvIndex.level.recommendedSPF)+", systemImage: "sun.max.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .widgetURL(entry.widgetURL)
    }
}

/// 시간별 UV 셀
struct HourlyUVCell: View {
    let hourly: HourlyUVIndex
    
    var body: some View {
        VStack(spacing: 4) {
            Text(hourly.formattedHour)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            
            // UV 바
            RoundedRectangle(cornerRadius: 2)
                .fill(hourly.level.color)
                .frame(width: 12, height: CGFloat(hourly.uvIndex) * 4 + 4)
            
            Text("\(hourly.uvIndex)")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}

/// UV 게이지 뷰
struct UVGaugeView: View {
    let uvIndex: Int
    let level: UVLevel
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // 배경 반원
                HalfCircle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 8)
                
                // 진행 반원
                HalfCircle()
                    .trim(from: 0, to: CGFloat(min(uvIndex, 11)) / 11)
                    .stroke(
                        AngularGradient(
                            colors: [.green, .yellow, .orange, .red, .purple],
                            center: .center,
                            startAngle: .degrees(180),
                            endAngle: .degrees(0)
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(180))
                
                // 중앙 값
                VStack(spacing: 0) {
                    Text("\(uvIndex)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(level.color)
                }
                .offset(y: -10)
            }
        }
    }
}

/// 반원 Shape
struct HalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY),
            radius: min(rect.width, rect.height * 2) / 2 - 4,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        return path
    }
}

// MARK: - Large UV Index View

/// 큰 크기 UV 지수 위젯
struct LargeUVIndexView: View {
    let entry: UVIndexEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: entry.uvIndex.level.symbol)
                            .foregroundStyle(entry.uvIndex.level.color)
                        Text("자외선 지수")
                            .fontWeight(.semibold)
                    }
                    .font(.headline)
                    
                    Text(entry.configuration.city.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 큰 UV 게이지
                LargeUVGaugeView(uvIndex: entry.uvIndex.currentIndex, level: entry.uvIndex.level)
                    .frame(width: 90, height: 90)
            }
            
            // 보호 권고 카드
            ProtectionAdviceCard(level: entry.uvIndex.level)
            
            Divider()
            
            // 시간별 UV 그래프
            VStack(alignment: .leading, spacing: 8) {
                Text("시간별 자외선 지수")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                UVGraphView(hourlyData: entry.uvIndex.hourlyForecast)
                    .frame(height: 80)
            }
            
            Divider()
            
            // 하단 정보
            HStack {
                // 최대 UV 시간
                VStack(alignment: .leading, spacing: 2) {
                    Text("오늘 최대")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 4) {
                        Text("\(entry.uvIndex.maxIndex)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(UVLevel(index: entry.uvIndex.maxIndex).color)
                        
                        Text(entry.uvIndex.maxTime.formatted(.dateTime.hour().minute()))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // 안전 노출 시간
                VStack(alignment: .trailing, spacing: 2) {
                    Text("안전 노출 시간")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.caption)
                        Text("\(entry.uvIndex.level.safeExposureMinutes)분")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                // 새로고침
                Button(intent: RefreshWeatherIntent(city: entry.configuration.city)) {
                    Label("갱신", systemImage: "arrow.clockwise")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .widgetURL(entry.widgetURL)
    }
}

/// 큰 UV 게이지 뷰
struct LargeUVGaugeView: View {
    let uvIndex: Int
    let level: UVLevel
    
    var body: some View {
        ZStack {
            // 배경 원
            Circle()
                .stroke(level.color.opacity(0.2), lineWidth: 10)
            
            // 진행 원
            Circle()
                .trim(from: 0, to: CGFloat(min(uvIndex, 11)) / 11)
                .stroke(
                    AngularGradient(
                        colors: [.green, .yellow, .orange, .red, .purple],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // 중앙 값
            VStack(spacing: 0) {
                Text("\(uvIndex)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(level.color)
                
                Text(level.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// 보호 권고 카드
struct ProtectionAdviceCard: View {
    let level: UVLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(level.protectionAdvice)
                .font(.subheadline)
            
            HStack(spacing: 16) {
                ProtectionItem(symbol: "eyeglasses", text: "선글라스", needed: level != .low)
                ProtectionItem(symbol: "tshirt.fill", text: "긴소매", needed: level == .high || level == .veryHigh || level == .extreme)
                ProtectionItem(symbol: "sun.max.fill", text: "SPF \(level.recommendedSPF)+", needed: true)
                ProtectionItem(symbol: "umbrella.fill", text: "양산", needed: level == .veryHigh || level == .extreme)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(level.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
    }
}

/// 보호 항목
struct ProtectionItem: View {
    let symbol: String
    let text: String
    let needed: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.body)
                .foregroundStyle(needed ? .primary : .tertiary)
            
            Text(text)
                .font(.system(size: 9))
                .foregroundStyle(needed ? .primary : .tertiary)
        }
    }
}

/// UV 그래프 뷰
struct UVGraphView: View {
    let hourlyData: [HourlyUVIndex]
    
    var body: some View {
        GeometryReader { geo in
            let maxUV = max(hourlyData.map { $0.uvIndex }.max() ?? 11, 11)
            let barWidth = (geo.size.width - CGFloat(hourlyData.count - 1) * 4) / CGFloat(hourlyData.count)
            
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(hourlyData) { hourly in
                    VStack(spacing: 2) {
                        // UV 바
                        RoundedRectangle(cornerRadius: 3)
                            .fill(hourly.level.gradient)
                            .frame(
                                width: barWidth,
                                height: max(CGFloat(hourly.uvIndex) / CGFloat(maxUV) * (geo.size.height - 20), 4)
                            )
                        
                        // 시간
                        Text(hourly.formattedHour)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - UV Index Entry View Router

/// UV 지수 위젯 크기별 뷰 라우터
struct UVIndexEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: UVIndexEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallUVIndexView(entry: entry)
        case .systemMedium:
            MediumUVIndexView(entry: entry)
        case .systemLarge:
            LargeUVIndexView(entry: entry)
        case .accessoryRectangular:
            RectangularUVIndexView(entry: entry)
        case .accessoryInline:
            InlineUVIndexView(entry: entry)
        case .accessoryCircular:
            CircularUVIndexView(entry: entry)
        default:
            SmallUVIndexView(entry: entry)
        }
    }
}

/// 원형 UV 지수 뷰 (잠금화면)
struct CircularUVIndexView: View {
    let entry: UVIndexEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            Gauge(value: Double(entry.uvIndex.currentIndex), in: 0...11) {
                Image(systemName: "sun.max.fill")
            } currentValueLabel: {
                Text("\(entry.uvIndex.currentIndex)")
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
            .gaugeStyle(.accessoryCircular)
            .tint(entry.uvIndex.level.color)
        }
    }
}

// MARK: - Previews

#Preview("Small UV", as: .systemSmall) {
    UVIndexWidget()
} timeline: {
    UVIndexEntry(date: .now, uvIndex: .preview, weather: .preview, configuration: UVIndexConfigIntent())
}

#Preview("Medium UV", as: .systemMedium) {
    UVIndexWidget()
} timeline: {
    UVIndexEntry(date: .now, uvIndex: .preview, weather: .preview, configuration: UVIndexConfigIntent())
}

#Preview("Large UV", as: .systemLarge) {
    UVIndexWidget()
} timeline: {
    UVIndexEntry(date: .now, uvIndex: .preview, weather: .preview, configuration: UVIndexConfigIntent())
}
