//
//  WeatherProvider.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 2/24/26.
//

import WidgetKit
import SwiftUI

/*
 WidgetKit의 핵심은 `TimelineProvider`입니다.
 시스템은 미리 타임라인을 받아 적절한 시점에 뷰를 렌더링합니다.
 
 3가지 필수 메서드를 구현해야합니다.
 - placeholder: 위젯 갤러리 미리보기
 - getSnapshot: 위젯 추가 시 스냅샷
 - getTimeline: 실제 타임라인 생성
 */

// MARK - Timeline Entry
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

struct CurrentWeatherProvider: TimelineProvider {
    // MARK: - Placeholder
    // 위젯 갤러리에서 미리보기로 표시됩니다.
    // HIG: 로딩 스피너 대신 실제 형태의 샘플 데이터를 보여주세요.
    func placeholder(in context: Context) -> CurrentWeatherEntry {
        CurrentWeatherEntry(date: .now, weather: .preview)
    }
    
    // MARK: - Snapshot
    // 위젯 추가 시 보여지는 스냅샷입니다.
    // context.isPreview가 true면 빠르게 미리보기 데이터를 반환하세요.
    func getSnapshot(in context: Context, completion: @escaping (CurrentWeatherEntry) -> Void) {
        completion(CurrentWeatherEntry(date: .now, weather: .preview))
    }
    
    // MARK: - Timeline 생성
    // 시스템에 타임라인을 제공하면, 시스템이 적절한 시점에 위젯을 업데이트합니다.
    func getTimeline(in context: Context, completion: @escaping (Timeline<CurrentWeatherEntry>) -> Void) {
        Task {
            // 1. 날씨 데이터 가져오기
            let weather = await WeatherService.shared.fetchWeather()
            
            // 2. 현재 시점의 엔트리 생성
            let entry = CurrentWeatherEntry(date: .now, weather: weather)
            
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
