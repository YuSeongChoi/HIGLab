import WidgetKit
import SwiftUI

// MARK: - 날씨 Timeline Entry
// HIG: TimelineEntry는 위젯이 표시할 데이터의 스냅샷

/// 현재 날씨 위젯용 Entry
struct CurrentWeatherEntry: TimelineEntry {
    let date: Date
    let weather: WeatherData
    let configuration: SelectCityIntent
    
    /// 위젯에서 사용할 딥링크 URL
    var widgetURL: URL {
        configuration.city.deepLinkURL
    }
    
    /// 표시할 온도 (단위 변환 적용)
    var displayTemperature: Int {
        configuration.temperatureUnit.convert(celsius: weather.temperature)
    }
    
    /// 표시할 최고 온도
    var displayHighTemperature: Int {
        configuration.temperatureUnit.convert(celsius: weather.highTemperature)
    }
    
    /// 표시할 최저 온도
    var displayLowTemperature: Int {
        configuration.temperatureUnit.convert(celsius: weather.lowTemperature)
    }
    
    /// 온도 단위 기호
    var temperatureSymbol: String {
        configuration.temperatureUnit.symbol
    }
}

// MARK: - 현재 날씨 Timeline Provider

/// 현재 날씨 위젯의 타임라인 제공자
/// HIG: AppIntentTimelineProvider로 사용자 설정 지원
struct CurrentWeatherProvider: AppIntentTimelineProvider {
    
    typealias Entry = CurrentWeatherEntry
    typealias Intent = SelectCityIntent
    
    // MARK: - Placeholder
    
    /// 위젯 갤러리 미리보기용 플레이스홀더
    /// HIG: 로딩 스피너 대신 실제 형태의 플레이스홀더 데이터 표시
    func placeholder(in context: Context) -> CurrentWeatherEntry {
        CurrentWeatherEntry(
            date: .now,
            weather: .preview,
            configuration: SelectCityIntent()
        )
    }
    
    // MARK: - Snapshot
    
    /// 위젯 추가 시 보여줄 스냅샷
    /// HIG: 빠르게 의미 있는 데이터를 보여줘야 함
    func snapshot(for configuration: SelectCityIntent, in context: Context) async -> CurrentWeatherEntry {
        // 실제 데이터 가져오기 시도
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        
        return CurrentWeatherEntry(
            date: .now,
            weather: weather,
            configuration: configuration
        )
    }
    
    // MARK: - Timeline
    
    /// 실제 타임라인 생성
    /// HIG: 날씨 데이터는 15-30분 간격 갱신이 적절
    func timeline(for configuration: SelectCityIntent, in context: Context) async -> Timeline<CurrentWeatherEntry> {
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        
        // 현재 엔트리
        let currentEntry = CurrentWeatherEntry(
            date: .now,
            weather: weather,
            configuration: configuration
        )
        
        // 위젯 크기에 따른 갱신 주기 설정
        let refreshInterval: Int
        switch context.family {
        case .systemSmall:
            refreshInterval = 30  // Small은 30분마다
        case .systemMedium, .systemLarge:
            refreshInterval = 15  // Medium/Large는 15분마다
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            refreshInterval = 30  // 잠금화면은 30분마다
        @unknown default:
            refreshInterval = 15
        }
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: refreshInterval, to: .now)!
        
        return Timeline(entries: [currentEntry], policy: .after(nextUpdate))
    }
}

// MARK: - 시간별 예보 Entry

/// 시간별 예보 위젯용 Entry
struct HourlyForecastEntry: TimelineEntry {
    let date: Date
    let weather: WeatherData
    let configuration: HourlyForecastConfigIntent
    
    /// 표시할 시간별 예보 (설정된 시간만큼)
    var displayHourlyForecast: [HourlyWeather] {
        Array(weather.hourlyForecast.prefix(configuration.forecastHours.rawValue))
    }
    
    /// 온도 변환 적용
    func displayTemperature(for hourly: HourlyWeather) -> Int {
        configuration.temperatureUnit.convert(celsius: hourly.temperature)
    }
}

// MARK: - 시간별 예보 Timeline Provider

/// 시간별 예보 위젯의 타임라인 제공자
struct HourlyForecastProvider: AppIntentTimelineProvider {
    
    typealias Entry = HourlyForecastEntry
    typealias Intent = HourlyForecastConfigIntent
    
    func placeholder(in context: Context) -> HourlyForecastEntry {
        HourlyForecastEntry(
            date: .now,
            weather: .preview,
            configuration: HourlyForecastConfigIntent()
        )
    }
    
    func snapshot(for configuration: HourlyForecastConfigIntent, in context: Context) async -> HourlyForecastEntry {
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        
        return HourlyForecastEntry(
            date: .now,
            weather: weather,
            configuration: configuration
        )
    }
    
    func timeline(for configuration: HourlyForecastConfigIntent, in context: Context) async -> Timeline<HourlyForecastEntry> {
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        
        var entries: [HourlyForecastEntry] = []
        
        // 매 시간마다 엔트리 생성 (최대 12시간)
        for hourOffset in stride(from: 0, to: 12, by: 1) {
            guard let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: .now) else { continue }
            
            entries.append(HourlyForecastEntry(
                date: entryDate,
                weather: weather,
                configuration: configuration
            ))
        }
        
        // 다음 갱신: 1시간 후
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
}

// MARK: - 주간 예보 Entry

/// 주간 예보 위젯용 Entry
struct WeeklyForecastEntry: TimelineEntry {
    let date: Date
    let weather: WeatherData
    let configuration: WeeklyForecastConfigIntent
    
    /// 표시할 일별 예보 (설정된 일수만큼)
    var displayDailyForecast: [DailyWeather] {
        Array(weather.dailyForecast.prefix(configuration.forecastDays.rawValue))
    }
    
    /// 온도 변환 적용
    func displayHigh(for daily: DailyWeather) -> Int {
        configuration.temperatureUnit.convert(celsius: daily.high)
    }
    
    func displayLow(for daily: DailyWeather) -> Int {
        configuration.temperatureUnit.convert(celsius: daily.low)
    }
    
    /// 전체 예보 중 최고/최저 온도 (온도 바 계산용)
    var overallHighTemperature: Int {
        displayDailyForecast.map { $0.high }.max() ?? 30
    }
    
    var overallLowTemperature: Int {
        displayDailyForecast.map { $0.low }.min() ?? 10
    }
}

// MARK: - 주간 예보 Timeline Provider

/// 주간 예보 위젯의 타임라인 제공자
struct WeeklyForecastProvider: AppIntentTimelineProvider {
    
    typealias Entry = WeeklyForecastEntry
    typealias Intent = WeeklyForecastConfigIntent
    
    func placeholder(in context: Context) -> WeeklyForecastEntry {
        WeeklyForecastEntry(
            date: .now,
            weather: .preview,
            configuration: WeeklyForecastConfigIntent()
        )
    }
    
    func snapshot(for configuration: WeeklyForecastConfigIntent, in context: Context) async -> WeeklyForecastEntry {
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        
        return WeeklyForecastEntry(
            date: .now,
            weather: weather,
            configuration: configuration
        )
    }
    
    func timeline(for configuration: WeeklyForecastConfigIntent, in context: Context) async -> Timeline<WeeklyForecastEntry> {
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        
        let entry = WeeklyForecastEntry(
            date: .now,
            weather: weather,
            configuration: configuration
        )
        
        // 주간 예보는 하루에 1-2번 갱신
        // 다음 갱신: 6시간 후
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: .now)!
        
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

// MARK: - 대기질 Entry

/// 대기질 위젯용 Entry
struct AirQualityEntry: TimelineEntry {
    let date: Date
    let airQuality: AirQualityData
    let weather: WeatherData
    let configuration: AirQualityConfigIntent
    
    /// 딥링크 URL
    var widgetURL: URL {
        URL(string: "weatherwidget://airquality/\(configuration.city.rawValue)")!
    }
}

// MARK: - 대기질 Timeline Provider

/// 대기질 위젯의 타임라인 제공자
struct AirQualityProvider: AppIntentTimelineProvider {
    
    typealias Entry = AirQualityEntry
    typealias Intent = AirQualityConfigIntent
    
    func placeholder(in context: Context) -> AirQualityEntry {
        AirQualityEntry(
            date: .now,
            airQuality: .preview,
            weather: .preview,
            configuration: AirQualityConfigIntent()
        )
    }
    
    func snapshot(for configuration: AirQualityConfigIntent, in context: Context) async -> AirQualityEntry {
        async let airQuality = WeatherService.shared.fetchAirQuality(for: configuration.city)
        async let weather = WeatherService.shared.fetchWeather(for: configuration.city)
        
        return AirQualityEntry(
            date: .now,
            airQuality: await airQuality,
            weather: await weather,
            configuration: configuration
        )
    }
    
    func timeline(for configuration: AirQualityConfigIntent, in context: Context) async -> Timeline<AirQualityEntry> {
        async let airQuality = WeatherService.shared.fetchAirQuality(for: configuration.city)
        async let weather = WeatherService.shared.fetchWeather(for: configuration.city)
        
        let entry = AirQualityEntry(
            date: .now,
            airQuality: await airQuality,
            weather: await weather,
            configuration: configuration
        )
        
        // 대기질은 30분마다 갱신
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

// MARK: - 자외선 지수 Entry

/// 자외선 지수 위젯용 Entry
struct UVIndexEntry: TimelineEntry {
    let date: Date
    let uvIndex: UVIndexData
    let weather: WeatherData
    let configuration: UVIndexConfigIntent
    
    /// 딥링크 URL
    var widgetURL: URL {
        URL(string: "weatherwidget://uvindex/\(configuration.city.rawValue)")!
    }
    
    /// 표시할 시간별 UV 예보
    var displayHourlyForecast: [HourlyUVIndex] {
        if configuration.showHourlyForecast {
            return Array(uvIndex.hourlyForecast.prefix(6))
        }
        return []
    }
}

// MARK: - 자외선 지수 Timeline Provider

/// 자외선 지수 위젯의 타임라인 제공자
struct UVIndexProvider: AppIntentTimelineProvider {
    
    typealias Entry = UVIndexEntry
    typealias Intent = UVIndexConfigIntent
    
    func placeholder(in context: Context) -> UVIndexEntry {
        UVIndexEntry(
            date: .now,
            uvIndex: .preview,
            weather: .preview,
            configuration: UVIndexConfigIntent()
        )
    }
    
    func snapshot(for configuration: UVIndexConfigIntent, in context: Context) async -> UVIndexEntry {
        async let uvIndex = WeatherService.shared.fetchUVIndex(for: configuration.city)
        async let weather = WeatherService.shared.fetchWeather(for: configuration.city)
        
        return UVIndexEntry(
            date: .now,
            uvIndex: await uvIndex,
            weather: await weather,
            configuration: configuration
        )
    }
    
    func timeline(for configuration: UVIndexConfigIntent, in context: Context) async -> Timeline<UVIndexEntry> {
        async let uvIndex = WeatherService.shared.fetchUVIndex(for: configuration.city)
        async let weather = WeatherService.shared.fetchWeather(for: configuration.city)
        
        var entries: [UVIndexEntry] = []
        
        // 낮 시간에는 1시간마다 엔트리 생성
        for hourOffset in stride(from: 0, to: 12, by: 1) {
            guard let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: .now) else { continue }
            
            entries.append(UVIndexEntry(
                date: entryDate,
                uvIndex: await uvIndex,
                weather: await weather,
                configuration: configuration
            ))
        }
        
        // 다음 갱신: 1시간 후
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
}

// MARK: - Relevance 계산 (스마트 스택 우선순위)

extension CurrentWeatherEntry {
    /// 스마트 스택에서의 관련성 점수 계산
    /// HIG: 위젯은 적절한 시점에 스마트 스택 상단에 표시되어야 함
    var relevance: TimelineEntryRelevance? {
        var score: Float = 0.0
        
        // 악천후 시 높은 점수
        if weather.condition.needsUmbrella {
            score += 0.5
        }
        
        // 극단적 온도
        if weather.temperature > 35 || weather.temperature < 0 {
            score += 0.3
        }
        
        // 출퇴근 시간대
        let hour = Calendar.current.component(.hour, from: date)
        if (7...9).contains(hour) || (17...19).contains(hour) {
            score += 0.2
        }
        
        return TimelineEntryRelevance(score: score)
    }
}

extension AirQualityEntry {
    /// 대기질이 나쁠 때 높은 관련성 점수
    var relevance: TimelineEntryRelevance? {
        var score: Float = 0.0
        
        switch airQuality.category {
        case .good:
            score = 0.1
        case .moderate:
            score = 0.2
        case .unhealthyForSensitive:
            score = 0.5
        case .unhealthy:
            score = 0.7
        case .veryUnhealthy:
            score = 0.9
        case .hazardous:
            score = 1.0
        }
        
        return TimelineEntryRelevance(score: score)
    }
}

extension UVIndexEntry {
    /// UV 지수가 높을 때 높은 관련성 점수
    var relevance: TimelineEntryRelevance? {
        var score: Float = 0.0
        
        // UV 지수에 따른 점수
        switch uvIndex.level {
        case .low:
            score = 0.1
        case .moderate:
            score = 0.3
        case .high:
            score = 0.5
        case .veryHigh:
            score = 0.7
        case .extreme:
            score = 1.0
        }
        
        // 낮 시간에 더 높은 점수
        let hour = Calendar.current.component(.hour, from: date)
        if (10...16).contains(hour) {
            score += 0.2
        }
        
        return TimelineEntryRelevance(score: min(score, 1.0))
    }
}
