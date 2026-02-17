import WidgetKit
import SwiftUI

struct CurrentWeatherProvider: TimelineProvider {
    
    // MARK: - Placeholder
    // 위젯 갤러리에서 미리보기로 표시됩니다.
    // HIG: 로딩 스피너 대신 실제 형태의 샘플 데이터를 보여주세요.
    func placeholder(in context: Context) -> CurrentWeatherEntry {
        CurrentWeatherEntry(
            date: .now,
            weather: .preview
        )
    }
    
    // MARK: - Snapshot
    // 위젯 추가 시 보여지는 스냅샷입니다.
    // context.isPreview가 true면 빠르게 미리보기 데이터를 반환하세요.
    func getSnapshot(in context: Context, completion: @escaping (CurrentWeatherEntry) -> Void) {
        if context.isPreview {
            // 미리보기에서는 샘플 데이터 사용
            completion(CurrentWeatherEntry(date: .now, weather: .preview))
        } else {
            // 실제 위젯에서는 최신 데이터 가져오기
            Task {
                let weather = await WeatherService.shared.fetchWeather()
                completion(CurrentWeatherEntry(date: .now, weather: weather))
            }
        }
    }
    
    // MARK: - Timeline
    func getTimeline(in context: Context, completion: @escaping (Timeline<CurrentWeatherEntry>) -> Void) {
        // 다음 단계에서 구현합니다
    }
}
