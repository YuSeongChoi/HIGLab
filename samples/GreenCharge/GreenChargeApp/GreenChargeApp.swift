// GreenChargeApp.swift
// GreenCharge - 청정 에너지 충전 앱
// iOS 26 EnergyKit 활용

import SwiftUI
import EnergyKit

// MARK: - 앱 진입점

/// GreenCharge 앱 메인 진입점
@main
struct GreenChargeApp: App {
    
    // MARK: - 상태 객체
    
    /// 에너지 서비스 (전력망 예보 조회)
    @State private var energyService = EnergyService()
    
    /// 위치 서비스 (현재 위치 기반 예보)
    @State private var locationService = LocationService()
    
    /// 알림 서비스 (청정 에너지 알림)
    @State private var notificationService = NotificationService()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(energyService)
                .environment(locationService)
                .environment(notificationService)
                .task {
                    await setupServices()
                }
        }
    }
    
    // MARK: - 초기화
    
    /// 서비스 초기 설정
    private func setupServices() async {
        // 위치 권한 요청
        await locationService.requestAuthorization()
        
        // 알림 권한 요청
        await notificationService.requestAuthorization()
        
        // 초기 예보 데이터 로드
        if let location = locationService.currentLocation {
            await energyService.fetchForecast(for: location)
        }
    }
}

// MARK: - 앱 상수

/// 앱 전역 상수
enum AppConstants {
    /// 앱 이름
    static let appName = "GreenCharge"
    
    /// 앱 버전
    static let appVersion = "1.0.0"
    
    /// 기본 예보 기간 (시간)
    static let defaultForecastHours = 48
    
    /// 최적 충전 기준 청정도 (%)
    static let optimalChargingThreshold = 0.7
    
    /// 기본 전력망 탄소 집약도 (gCO2/kWh)
    static let baselineCarbonIntensity = 500.0
    
    /// 알림 기본 리드 타임 (분)
    static let notificationLeadTime = 30
}

// MARK: - 탭 열거형

/// 메인 탭 종류
enum MainTab: String, CaseIterable, Identifiable {
    case forecast = "예보"
    case schedule = "충전"
    case stats = "통계"
    case settings = "설정"
    
    var id: String { rawValue }
    
    /// 탭 아이콘
    var iconName: String {
        switch self {
        case .forecast: return "bolt.fill"
        case .schedule: return "calendar"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
    
    /// 선택되지 않은 상태 아이콘
    var iconNameOutline: String {
        switch self {
        case .forecast: return "bolt"
        case .schedule: return "calendar"
        case .stats: return "chart.bar"
        case .settings: return "gearshape"
        }
    }
}

// MARK: - 색상 테마

/// 앱 색상 테마
extension Color {
    /// 청정 에너지 (녹색)
    static let cleanEnergy = Color.green
    
    /// 화석 연료 (회색)
    static let fossilFuel = Color.gray
    
    /// 경고 (주황)
    static let warning = Color.orange
    
    /// 위험 (빨강)
    static let danger = Color.red
    
    /// 최적 충전 시간 (민트)
    static let optimalCharging = Color.mint
}

// MARK: - 날짜 포맷터

/// 앱 전역 날짜 포맷터
extension DateFormatter {
    /// 한국어 날짜 포맷터
    static let korean: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    /// 시간 포맷터 (예: "오후 2시")
    static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter.korean
        formatter.dateFormat = "a h시"
        return formatter
    }()
    
    /// 날짜 포맷터 (예: "2월 17일")
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter.korean
        formatter.dateFormat = "M월 d일"
        return formatter
    }()
    
    /// 요일 포맷터 (예: "월요일")
    static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter.korean
        formatter.dateFormat = "EEEE"
        return formatter
    }()
}
