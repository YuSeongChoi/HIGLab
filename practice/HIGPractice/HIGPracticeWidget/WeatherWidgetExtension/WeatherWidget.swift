import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entry
// TimelineEntry 프로토콜은 반드시 `date` 프로퍼티가 필요합니다.
// 시스템은 이 date를 기준으로 적절한 시점에 위젯을 렌더링 합니다.

struct WeatherEntry: TimelineEntry {
    let date: Date
    let weather: WeatherData
}

// MARK: - Timeline Provider

struct WeatherProvider: AppIntentTimelineProvider {
    
    // MARK: - Placeholder
    // 위젯 갤리러에서 미리보기로 표시합니다.
    // 위젯 갤러리 미리보기용 (HIG: 로딩 스피너 대신 실제 형태 데이터)
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: .now, weather: .preview)
    }
    
    // MARK: - Snapshot
    // 위젯 추가 시 보여지는 스냅샷입니다.
    func snapshot(for configuration: SelectCityIntent, in context: Context) async -> WeatherEntry {
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        return WeatherEntry(date: .now, weather: weather)
    }
    
    // MARK - Timeline 생성
    // 시스템에 타임라인을 제공하면, 시스템이 적절한 시점에 위젯을 업데이트합니다.
    // 실제 타임라인 생성 — 15분 간격 갱신
    func timeline(for configuration: SelectCityIntent, in context: Context) async -> Timeline<WeatherEntry> {
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        let entry = WeatherEntry(date: .now, weather: weather)
        
        // HIG: 날씨 데이터는 15분 간격 갱신이 적절
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        
        // 타임라인 생성
        // policy: .after(nextUpdate) - 저장 시점 이후 갱신
        // policy: .atEnd - 마지막 엔트리 후 갱신
        // policy: .never - 앱에서 직접 갱신 요청 전까지 대기
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

// MARK: - Widget Definition

struct WeatherWidget: Widget {
    let kind = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectCityIntent.self,
            provider: WeatherProvider()
        ) { entry in
            WeatherWidgetEntryView(entry: entry)
                // HIG: containerBackground로 배경 처리 (iOS 17+)
                .containerBackground(
                    entry.weather.condition.gradient,
                    for: .widget
                )
        }
        .configurationDisplayName("날씨")
        .description("현재 날씨와 시간별 예보를 확인하세요.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Widget Bundle

@main
struct WeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
    }
}
