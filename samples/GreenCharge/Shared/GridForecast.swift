// GridForecast.swift
// GreenCharge - 전력망 청정 에너지 예보 모델
// iOS 26 EnergyKit 활용

import Foundation
import EnergyKit

// MARK: - 전력망 예보 데이터 모델

/// 시간대별 전력망 청정도 정보
struct GridForecastEntry: Identifiable, Hashable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let cleanEnergyPercentage: Double  // 0.0 ~ 1.0
    let carbonIntensity: Double  // gCO2/kWh
    let primarySource: EnergySource
    let isOptimalForCharging: Bool
    
    /// 청정도 등급 (A ~ F)
    var cleanlinessGrade: CleanlinessGrade {
        switch cleanEnergyPercentage {
        case 0.8...1.0: return .excellent
        case 0.6..<0.8: return .good
        case 0.4..<0.6: return .moderate
        case 0.2..<0.4: return .poor
        default: return .veryPoor
        }
    }
    
    /// 시간대 표시 문자열 (예: "오후 2시 - 오후 4시")
    var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h시"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}

// MARK: - 에너지원 종류

/// 전력 생산 에너지원
enum EnergySource: String, CaseIterable, Identifiable {
    case solar = "태양광"
    case wind = "풍력"
    case hydro = "수력"
    case nuclear = "원자력"
    case naturalGas = "천연가스"
    case coal = "석탄"
    case other = "기타"
    
    var id: String { rawValue }
    
    /// 청정 에너지 여부
    var isClean: Bool {
        switch self {
        case .solar, .wind, .hydro, .nuclear:
            return true
        case .naturalGas, .coal, .other:
            return false
        }
    }
    
    /// SF Symbol 아이콘 이름
    var iconName: String {
        switch self {
        case .solar: return "sun.max.fill"
        case .wind: return "wind"
        case .hydro: return "drop.fill"
        case .nuclear: return "atom"
        case .naturalGas: return "flame.fill"
        case .coal: return "smoke.fill"
        case .other: return "bolt.fill"
        }
    }
    
    /// 에너지원 색상
    var color: String {
        switch self {
        case .solar: return "yellow"
        case .wind: return "cyan"
        case .hydro: return "blue"
        case .nuclear: return "purple"
        case .naturalGas: return "orange"
        case .coal: return "gray"
        case .other: return "secondary"
        }
    }
}

// MARK: - 청정도 등급

/// 전력망 청정도 등급
enum CleanlinessGrade: String, CaseIterable {
    case excellent = "A"
    case good = "B"
    case moderate = "C"
    case poor = "D"
    case veryPoor = "F"
    
    /// 등급 설명
    var description: String {
        switch self {
        case .excellent: return "매우 깨끗함"
        case .good: return "깨끗함"
        case .moderate: return "보통"
        case .poor: return "좋지 않음"
        case .veryPoor: return "매우 좋지 않음"
        }
    }
    
    /// 등급 색상
    var colorName: String {
        switch self {
        case .excellent: return "green"
        case .good: return "mint"
        case .moderate: return "yellow"
        case .poor: return "orange"
        case .veryPoor: return "red"
        }
    }
    
    /// 충전 권장 여부
    var isRecommendedForCharging: Bool {
        switch self {
        case .excellent, .good:
            return true
        default:
            return false
        }
    }
}

// MARK: - 일간 예보

/// 하루 단위 전력망 예보
struct DailyGridForecast: Identifiable {
    let id = UUID()
    let date: Date
    let hourlyForecasts: [GridForecastEntry]
    
    /// 오늘 날짜인지 확인
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// 일간 평균 청정도
    var averageCleanPercentage: Double {
        guard !hourlyForecasts.isEmpty else { return 0 }
        return hourlyForecasts.map(\.cleanEnergyPercentage).reduce(0, +) / Double(hourlyForecasts.count)
    }
    
    /// 최적 충전 시간대 (가장 청정한 시간)
    var optimalChargingPeriods: [GridForecastEntry] {
        hourlyForecasts.filter { $0.isOptimalForCharging }
            .sorted { $0.cleanEnergyPercentage > $1.cleanEnergyPercentage }
    }
    
    /// 날짜 표시 문자열
    var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }
}

// MARK: - EnergyKit 변환 확장

extension GridForecastEntry {
    /// EKGridForecast.Window에서 변환
    init(from window: EKGridForecast.Window, location: String) {
        self.startTime = window.startDate
        self.endTime = window.endDate
        self.cleanEnergyPercentage = window.cleanEnergyPercentage
        self.carbonIntensity = window.carbonIntensity
        self.primarySource = EnergySource.from(ekSource: window.primaryEnergySource)
        self.isOptimalForCharging = window.isGreenWindow
    }
}

extension EnergySource {
    /// EKEnergySource에서 변환
    static func from(ekSource: EKEnergySource) -> EnergySource {
        switch ekSource {
        case .solar: return .solar
        case .wind: return .wind
        case .hydro: return .hydro
        case .nuclear: return .nuclear
        case .naturalGas: return .naturalGas
        case .coal: return .coal
        @unknown default: return .other
        }
    }
}
