import WidgetKit

// MARK: - Timeline Entry
// TimelineEntry 프로토콜은 반드시 date 프로퍼티가 필요합니다.
// 시스템은 이 date를 기준으로 적절한 시점에 위젯을 렌더링합니다.

struct CurrentWeatherEntry: TimelineEntry {
    /// 이 엔트리가 표시되어야 하는 시점
    let date: Date
    
    /// 위젯에 표시할 날씨 데이터
    let weather: WeatherData
    
    /// 위젯 설정에서 선택한 도시 (Configuration용)
    let configuration: SelectCityIntent?
    
    init(date: Date, weather: WeatherData, configuration: SelectCityIntent? = nil) {
        self.date = date
        self.weather = weather
        self.configuration = configuration
    }
}
