// CarbonEmission.swift
// GreenCharge - 탄소 배출량 모델
// iOS 26 EnergyKit 활용

import Foundation

// MARK: - 탄소 배출량 데이터

/// 시간대별 탄소 배출량 데이터 (차트용)
struct CarbonEmissionData: Identifiable {
    let id = UUID()
    let timestamp: Date
    let emissionIntensity: Double  // gCO2/kWh
    let cleanEnergyRatio: Double  // 0.0 ~ 1.0
    
    /// 시간 표시 (예: "14시")
    var hourString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "H시"
        return formatter.string(from: timestamp)
    }
    
    /// 배출량 등급
    var intensityLevel: EmissionLevel {
        switch emissionIntensity {
        case 0..<100: return .veryLow
        case 100..<200: return .low
        case 200..<350: return .medium
        case 350..<500: return .high
        default: return .veryHigh
        }
    }
}

// MARK: - 배출량 수준

/// 탄소 배출 수준
enum EmissionLevel: String, CaseIterable {
    case veryLow = "매우 낮음"
    case low = "낮음"
    case medium = "보통"
    case high = "높음"
    case veryHigh = "매우 높음"
    
    /// 수준 색상
    var colorName: String {
        switch self {
        case .veryLow: return "green"
        case .low: return "mint"
        case .medium: return "yellow"
        case .high: return "orange"
        case .veryHigh: return "red"
        }
    }
    
    /// 아이콘 이름
    var iconName: String {
        switch self {
        case .veryLow: return "leaf.fill"
        case .low: return "leaf"
        case .medium: return "cloud"
        case .high: return "smoke"
        case .veryHigh: return "smoke.fill"
        }
    }
}

// MARK: - 주간 탄소 통계

/// 주간 탄소 배출 통계
struct WeeklyCarbonStats: Identifiable {
    let id = UUID()
    let weekStartDate: Date
    let dailyStats: [DailyCarbonStat]
    
    /// 주간 총 절감량 (kg CO2)
    var totalCarbonSaved: Double {
        dailyStats.map(\.carbonSaved).reduce(0, +)
    }
    
    /// 주간 평균 청정 에너지 비율
    var averageCleanRatio: Double {
        guard !dailyStats.isEmpty else { return 0 }
        return dailyStats.map(\.averageCleanRatio).reduce(0, +) / Double(dailyStats.count)
    }
    
    /// 주간 총 충전량 (kWh)
    var totalEnergyCharged: Double {
        dailyStats.map(\.totalEnergyUsed).reduce(0, +)
    }
    
    /// 주간 문자열 (예: "2월 10일 ~ 2월 16일")
    var weekRangeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate)!
        return "\(formatter.string(from: weekStartDate)) ~ \(formatter.string(from: endDate))"
    }
    
    /// 나무 심기 환산 (1그루 = 연간 약 22kg CO2 흡수)
    var treesEquivalent: Double {
        totalCarbonSaved / 22.0 * 52  // 주간 -> 연간 환산
    }
}

/// 일간 탄소 통계
struct DailyCarbonStat: Identifiable {
    let id = UUID()
    let date: Date
    let totalEnergyUsed: Double  // kWh
    let carbonEmitted: Double  // kg CO2
    let carbonSaved: Double  // kg CO2
    let averageCleanRatio: Double
    let chargingSessions: Int
    
    /// 요일 문자열 (예: "월")
    var dayOfWeekString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    /// 짧은 날짜 문자열 (예: "2/14")
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

// MARK: - 환경 영향 지표

/// 환경 영향 지표
struct EnvironmentalImpact {
    let carbonSaved: Double  // kg CO2
    
    /// 자동차 주행 거리 환산 (1km = 약 0.12kg CO2)
    var carKilometersEquivalent: Double {
        carbonSaved / 0.12
    }
    
    /// 나무 심기 환산 (1그루 연간 22kg CO2 흡수)
    var treesPlantedEquivalent: Double {
        carbonSaved / 22.0
    }
    
    /// 스마트폰 충전 횟수 환산 (1회 = 약 0.008kg CO2)
    var phoneChargesEquivalent: Double {
        carbonSaved / 0.008
    }
    
    /// 형식화된 자동차 주행 거리
    var formattedCarDistance: String {
        if carKilometersEquivalent >= 1000 {
            return String(format: "%.1fkm", carKilometersEquivalent)
        } else {
            return String(format: "%.0fm", carKilometersEquivalent * 1000)
        }
    }
    
    /// 형식화된 나무 그루 수
    var formattedTreesCount: String {
        if treesPlantedEquivalent >= 1 {
            return String(format: "%.1f그루", treesPlantedEquivalent)
        } else {
            return String(format: "%.2f그루", treesPlantedEquivalent)
        }
    }
}

// MARK: - 차트 데이터 포인트

/// 차트 표시용 데이터 포인트
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let category: String
    
    /// 백분율 값 (최대값 대비)
    func percentage(of maxValue: Double) -> Double {
        guard maxValue > 0 else { return 0 }
        return value / maxValue
    }
}

// MARK: - 에너지 믹스

/// 현재 전력망 에너지 믹스
struct EnergyMix: Identifiable {
    let id = UUID()
    let timestamp: Date
    let sources: [EnergySourceShare]
    
    /// 청정 에너지 총 비율
    var cleanEnergyTotal: Double {
        sources.filter { $0.source.isClean }.map(\.percentage).reduce(0, +)
    }
    
    /// 화석 연료 총 비율
    var fossilFuelTotal: Double {
        sources.filter { !$0.source.isClean }.map(\.percentage).reduce(0, +)
    }
}

/// 에너지원별 비율
struct EnergySourceShare: Identifiable {
    let id = UUID()
    let source: EnergySource
    let percentage: Double  // 0.0 ~ 1.0
    
    /// 백분율 표시 문자열
    var percentageString: String {
        String(format: "%.1f%%", percentage * 100)
    }
}

// MARK: - 통계 계산 유틸리티

extension Array where Element == ChargingRecord {
    /// 총 탄소 절감량
    var totalCarbonSaved: Double {
        map(\.carbonSaved).reduce(0, +)
    }
    
    /// 총 에너지 사용량
    var totalEnergyUsed: Double {
        map(\.energyUsed).reduce(0, +)
    }
    
    /// 평균 청정 에너지 비율
    var averageCleanPercentage: Double {
        guard !isEmpty else { return 0 }
        return map(\.cleanEnergyPercentage).reduce(0, +) / Double(count)
    }
    
    /// 날짜별 그룹화
    func groupedByDate() -> [Date: [ChargingRecord]] {
        Dictionary(grouping: self) { record in
            Calendar.current.startOfDay(for: record.startTime)
        }
    }
    
    /// 주간 통계 생성
    func weeklyStats(for weekStart: Date) -> WeeklyCarbonStats {
        let calendar = Calendar.current
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        
        // 해당 주의 기록 필터링
        let weekRecords = filter { record in
            record.startTime >= weekStart && record.startTime < weekEnd
        }
        
        // 일별 통계 생성
        var dailyStats: [DailyCarbonStat] = []
        
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
            let dayStart = calendar.startOfDay(for: day)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let dayRecords = weekRecords.filter { record in
                record.startTime >= dayStart && record.startTime < dayEnd
            }
            
            let stat = DailyCarbonStat(
                date: day,
                totalEnergyUsed: dayRecords.totalEnergyUsed,
                carbonEmitted: dayRecords.map(\.carbonEmitted).reduce(0, +),
                carbonSaved: dayRecords.totalCarbonSaved,
                averageCleanRatio: dayRecords.averageCleanPercentage,
                chargingSessions: dayRecords.count
            )
            
            dailyStats.append(stat)
        }
        
        return WeeklyCarbonStats(
            weekStartDate: weekStart,
            dailyStats: dailyStats
        )
    }
}
