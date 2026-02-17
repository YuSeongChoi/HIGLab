// ChargingRecommendation.swift
// GreenCharge - 충전 최적 시간 추천 모델
// iOS 26 EnergyKit 활용

import Foundation

// MARK: - 충전 추천 모델

/// 충전 시간 추천 정보
struct ChargingRecommendation: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let estimatedCleanPercentage: Double
    let estimatedCarbonSaved: Double  // kg CO2
    let priority: ChargingPriority
    let reason: String
    
    /// 추천 시간대 길이 (분)
    var durationMinutes: Int {
        Int(endTime.timeIntervalSince(startTime) / 60)
    }
    
    /// 추천 시간 문자열 (예: "오후 2시 30분 ~ 오후 4시")
    var timeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h시 mm분"
        
        let start = formatter.string(from: startTime)
        let end = formatter.string(from: endTime)
        return "\(start) ~ \(end)"
    }
    
    /// 짧은 시간 문자열 (예: "14:30 - 16:00")
    var shortTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}

// MARK: - 충전 우선순위

/// 충전 추천 우선순위
enum ChargingPriority: Int, CaseIterable, Comparable {
    case high = 3
    case medium = 2
    case low = 1
    
    static func < (lhs: ChargingPriority, rhs: ChargingPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    /// 우선순위 표시 문자열
    var displayName: String {
        switch self {
        case .high: return "강력 추천"
        case .medium: return "추천"
        case .low: return "고려"
        }
    }
    
    /// 우선순위 아이콘
    var iconName: String {
        switch self {
        case .high: return "star.fill"
        case .medium: return "star.leadinghalf.filled"
        case .low: return "star"
        }
    }
    
    /// 우선순위 색상
    var colorName: String {
        switch self {
        case .high: return "green"
        case .medium: return "yellow"
        case .low: return "gray"
        }
    }
}

// MARK: - 충전 일정

/// 사용자 충전 일정
struct ChargingSchedule: Identifiable, Codable {
    let id: UUID
    var deviceName: String
    var targetChargeLevel: Int  // 0 ~ 100
    var estimatedDuration: TimeInterval  // 예상 충전 시간 (초)
    var preferredStartTime: Date?
    var preferredEndTime: Date?
    var isEnabled: Bool
    var useOptimalTiming: Bool  // 최적 시간 자동 선택
    
    init(
        id: UUID = UUID(),
        deviceName: String,
        targetChargeLevel: Int = 80,
        estimatedDuration: TimeInterval = 3600,
        preferredStartTime: Date? = nil,
        preferredEndTime: Date? = nil,
        isEnabled: Bool = true,
        useOptimalTiming: Bool = true
    ) {
        self.id = id
        self.deviceName = deviceName
        self.targetChargeLevel = targetChargeLevel
        self.estimatedDuration = estimatedDuration
        self.preferredStartTime = preferredStartTime
        self.preferredEndTime = preferredEndTime
        self.isEnabled = isEnabled
        self.useOptimalTiming = useOptimalTiming
    }
    
    /// 예상 충전 시간 문자열 (예: "1시간 30분")
    var durationString: String {
        let hours = Int(estimatedDuration) / 3600
        let minutes = (Int(estimatedDuration) % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)시간 \(minutes)분"
        } else if hours > 0 {
            return "\(hours)시간"
        } else {
            return "\(minutes)분"
        }
    }
}

// MARK: - 충전 기록

/// 충전 완료 기록
struct ChargingRecord: Identifiable, Codable {
    let id: UUID
    let deviceName: String
    let startTime: Date
    let endTime: Date
    let energyUsed: Double  // kWh
    let cleanEnergyPercentage: Double
    let carbonEmitted: Double  // kg CO2
    let carbonSaved: Double  // kg CO2 (일반 전력 대비 절감량)
    
    init(
        id: UUID = UUID(),
        deviceName: String,
        startTime: Date,
        endTime: Date,
        energyUsed: Double,
        cleanEnergyPercentage: Double,
        carbonEmitted: Double,
        carbonSaved: Double
    ) {
        self.id = id
        self.deviceName = deviceName
        self.startTime = startTime
        self.endTime = endTime
        self.energyUsed = energyUsed
        self.cleanEnergyPercentage = cleanEnergyPercentage
        self.carbonEmitted = carbonEmitted
        self.carbonSaved = carbonSaved
    }
    
    /// 충전 날짜 문자열
    var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: startTime)
    }
    
    /// 충전 시간대 문자열
    var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}

// MARK: - 추천 생성기

/// 충전 추천 생성기
struct ChargingRecommendationGenerator {
    
    /// 전력망 예보 기반 충전 추천 생성
    /// - Parameters:
    ///   - forecasts: 시간대별 전력망 예보
    ///   - schedule: 충전 일정
    /// - Returns: 정렬된 충전 추천 목록
    static func generateRecommendations(
        from forecasts: [GridForecastEntry],
        for schedule: ChargingSchedule
    ) -> [ChargingRecommendation] {
        
        // 청정도가 높은 시간대 필터링
        let cleanPeriods = forecasts.filter { $0.cleanEnergyPercentage >= 0.5 }
        
        // 연속된 시간대 그룹화
        let groupedPeriods = groupConsecutivePeriods(cleanPeriods)
        
        // 각 그룹에 대해 추천 생성
        var recommendations: [ChargingRecommendation] = []
        
        for group in groupedPeriods {
            guard let first = group.first, let last = group.last else { continue }
            
            let avgClean = group.map(\.cleanEnergyPercentage).reduce(0, +) / Double(group.count)
            let avgCarbon = group.map(\.carbonIntensity).reduce(0, +) / Double(group.count)
            
            // 일반 전력(500 gCO2/kWh) 대비 절감량 계산
            let energyKwh = schedule.estimatedDuration / 3600 * 0.5  // 0.5kW 평균 소비 가정
            let baselineCarbon = energyKwh * 500 / 1000  // kg
            let actualCarbon = energyKwh * avgCarbon / 1000  // kg
            let carbonSaved = max(0, baselineCarbon - actualCarbon)
            
            let priority: ChargingPriority
            let reason: String
            
            if avgClean >= 0.8 {
                priority = .high
                reason = "매우 높은 청정 에너지 비율 (\(Int(avgClean * 100))%)"
            } else if avgClean >= 0.6 {
                priority = .medium
                reason = "양호한 청정 에너지 비율 (\(Int(avgClean * 100))%)"
            } else {
                priority = .low
                reason = "보통 수준의 청정 에너지 (\(Int(avgClean * 100))%)"
            }
            
            let recommendation = ChargingRecommendation(
                startTime: first.startTime,
                endTime: last.endTime,
                estimatedCleanPercentage: avgClean,
                estimatedCarbonSaved: carbonSaved,
                priority: priority,
                reason: reason
            )
            
            recommendations.append(recommendation)
        }
        
        // 우선순위 및 시간순 정렬
        return recommendations.sorted {
            if $0.priority != $1.priority {
                return $0.priority > $1.priority
            }
            return $0.startTime < $1.startTime
        }
    }
    
    /// 연속된 시간대 그룹화
    private static func groupConsecutivePeriods(
        _ periods: [GridForecastEntry]
    ) -> [[GridForecastEntry]] {
        guard !periods.isEmpty else { return [] }
        
        let sorted = periods.sorted { $0.startTime < $1.startTime }
        var groups: [[GridForecastEntry]] = []
        var currentGroup: [GridForecastEntry] = [sorted[0]]
        
        for i in 1..<sorted.count {
            let prev = sorted[i - 1]
            let curr = sorted[i]
            
            // 이전 시간대 종료와 현재 시간대 시작이 연속인지 확인
            if prev.endTime == curr.startTime {
                currentGroup.append(curr)
            } else {
                groups.append(currentGroup)
                currentGroup = [curr]
            }
        }
        
        groups.append(currentGroup)
        return groups
    }
}
