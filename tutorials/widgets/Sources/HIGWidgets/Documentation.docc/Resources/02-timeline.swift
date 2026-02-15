import WidgetKit
import SwiftUI

struct WeatherProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: .now, weather: .preview)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        completion(WeatherEntry(date: .now, weather: .preview))
    }
    
    // MARK: - Timeline 생성
    // 시스템에 타임라인을 제공하면, 시스템이 적절한 시점에 위젯을 업데이트합니다.
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        Task {
            // 1. 날씨 데이터 가져오기
            let weather = await WeatherService.shared.fetchWeather()
            
            // 2. 현재 시점의 엔트리 생성
            let entry = WeatherEntry(date: .now, weather: weather)
            
            // 3. 다음 갱신 시점 계산 (15분 후)
            let nextUpdate = Calendar.current.date(
                byAdding: .minute,
                value: 15,
                to: .now
            )!
            
            // 4. 타임라인 생성
            // policy: .after(nextUpdate) — 지정 시점 이후 갱신
            // policy: .atEnd — 마지막 엔트리 후 갱신
            // policy: .never — 앱에서 직접 갱신 요청 전까지 대기
            let timeline = Timeline(
                entries: [entry],
                policy: .after(nextUpdate)
            )
            
            completion(timeline)
        }
    }
}
