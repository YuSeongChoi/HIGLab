import Foundation
import HealthKit

// MARK: - 걸음 수 데이터 모델
/// 일별 걸음 수를 저장하는 구조체
struct StepData: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let count: Int
    
    /// 포맷된 날짜 문자열 반환
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
    
    /// 요일 반환
    var weekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// MARK: - 심박수 데이터 모델
/// 심박수 측정 데이터를 저장하는 구조체
struct HeartRateData: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let bpm: Double
    
    /// 심박수 상태 분류
    var status: HeartRateStatus {
        switch bpm {
        case ..<60: return .low
        case 60..<100: return .normal
        case 100..<120: return .elevated
        default: return .high
        }
    }
    
    /// 포맷된 시간 문자열
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

/// 심박수 상태 열거형
enum HeartRateStatus: String {
    case low = "느림"
    case normal = "정상"
    case elevated = "약간 높음"
    case high = "높음"
    
    var color: String {
        switch self {
        case .low: return "blue"
        case .normal: return "green"
        case .elevated: return "orange"
        case .high: return "red"
        }
    }
}

// MARK: - 수면 데이터 모델
/// 수면 분석 데이터를 저장하는 구조체
struct SleepData: Identifiable, Equatable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    let category: SleepCategory
    
    /// 수면 시간 (분 단위)
    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }
    
    /// 수면 시간 (시:분 형식)
    var formattedDuration: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        return "\(hours)시간 \(minutes)분"
    }
    
    /// 수면 시작 시간
    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startDate)
    }
}

/// 수면 카테고리 열거형
enum SleepCategory: String, CaseIterable {
    case inBed = "침대에 있음"
    case asleepUnspecified = "수면 중"
    case awake = "깨어 있음"
    case asleepCore = "코어 수면"
    case asleepDeep = "깊은 수면"
    case asleepREM = "REM 수면"
    
    /// HealthKit 수면 분석 값으로 초기화
    init(from value: HKCategoryValueSleepAnalysis) {
        switch value {
        case .inBed: self = .inBed
        case .asleepUnspecified: self = .asleepUnspecified
        case .awake: self = .awake
        case .asleepCore: self = .asleepCore
        case .asleepDeep: self = .asleepDeep
        case .asleepREM: self = .asleepREM
        @unknown default: self = .asleepUnspecified
        }
    }
    
    var color: String {
        switch self {
        case .inBed: return "gray"
        case .asleepUnspecified: return "blue"
        case .awake: return "yellow"
        case .asleepCore: return "indigo"
        case .asleepDeep: return "purple"
        case .asleepREM: return "cyan"
        }
    }
}

// MARK: - 운동 데이터 모델
/// 운동 기록을 저장하는 구조체
struct WorkoutData: Identifiable, Equatable {
    let id = UUID()
    let type: WorkoutType
    let startDate: Date
    let endDate: Date
    let calories: Double
    let distance: Double? // 미터 단위
    
    /// 운동 시간 (분 단위)
    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }
    
    /// 포맷된 운동 시간
    var formattedDuration: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        }
        return "\(minutes)분"
    }
    
    /// 포맷된 날짜
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: startDate)
    }
    
    /// 포맷된 거리 (km)
    var formattedDistance: String? {
        guard let distance = distance else { return nil }
        return String(format: "%.2f km", distance / 1000)
    }
}

/// 운동 유형 열거형
enum WorkoutType: String, CaseIterable, Identifiable {
    case running = "달리기"
    case walking = "걷기"
    case cycling = "사이클링"
    case swimming = "수영"
    case hiking = "등산"
    case yoga = "요가"
    case strength = "근력 운동"
    case other = "기타"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .hiking: return "figure.hiking"
        case .yoga: return "figure.yoga"
        case .strength: return "dumbbell.fill"
        case .other: return "sportscourt.fill"
        }
    }
    
    /// HealthKit 운동 유형으로 변환
    var hkWorkoutType: HKWorkoutActivityType {
        switch self {
        case .running: return .running
        case .walking: return .walking
        case .cycling: return .cycling
        case .swimming: return .swimming
        case .hiking: return .hiking
        case .yoga: return .yoga
        case .strength: return .traditionalStrengthTraining
        case .other: return .other
        }
    }
    
    /// HealthKit 운동 유형에서 초기화
    init(from hkType: HKWorkoutActivityType) {
        switch hkType {
        case .running: self = .running
        case .walking: self = .walking
        case .cycling: self = .cycling
        case .swimming: self = .swimming
        case .hiking: self = .hiking
        case .yoga: self = .yoga
        case .traditionalStrengthTraining, .functionalStrengthTraining: self = .strength
        default: self = .other
        }
    }
}

// MARK: - 건강 목표 모델
/// 건강 목표를 저장하는 구조체
struct HealthGoal: Identifiable, Codable, Equatable {
    let id: UUID
    var type: GoalType
    var targetValue: Double
    var currentValue: Double
    var isEnabled: Bool
    
    init(id: UUID = UUID(), type: GoalType, targetValue: Double, currentValue: Double = 0, isEnabled: Bool = true) {
        self.id = id
        self.type = type
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.isEnabled = isEnabled
    }
    
    /// 목표 달성률 (0.0 ~ 1.0)
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }
    
    /// 목표 달성 여부
    var isCompleted: Bool {
        currentValue >= targetValue
    }
    
    /// 포맷된 현재 값
    var formattedCurrentValue: String {
        type.format(value: currentValue)
    }
    
    /// 포맷된 목표 값
    var formattedTargetValue: String {
        type.format(value: targetValue)
    }
}

/// 목표 유형 열거형
enum GoalType: String, Codable, CaseIterable, Identifiable {
    case steps = "걸음 수"
    case calories = "소모 칼로리"
    case exerciseMinutes = "운동 시간"
    case sleepHours = "수면 시간"
    case distance = "이동 거리"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .calories: return "flame.fill"
        case .exerciseMinutes: return "clock.fill"
        case .sleepHours: return "moon.fill"
        case .distance: return "map.fill"
        }
    }
    
    var unit: String {
        switch self {
        case .steps: return "걸음"
        case .calories: return "kcal"
        case .exerciseMinutes: return "분"
        case .sleepHours: return "시간"
        case .distance: return "km"
        }
    }
    
    var defaultTarget: Double {
        switch self {
        case .steps: return 10000
        case .calories: return 500
        case .exerciseMinutes: return 30
        case .sleepHours: return 8
        case .distance: return 5
        }
    }
    
    /// 값을 단위와 함께 포맷
    func format(value: Double) -> String {
        switch self {
        case .steps:
            return "\(Int(value)) \(unit)"
        case .calories:
            return "\(Int(value)) \(unit)"
        case .exerciseMinutes:
            return "\(Int(value)) \(unit)"
        case .sleepHours:
            return String(format: "%.1f \(unit)", value)
        case .distance:
            return String(format: "%.1f \(unit)", value)
        }
    }
}

// MARK: - 통계 데이터 모델
/// 기간별 통계 데이터를 저장하는 구조체
struct StatisticsData {
    let period: StatisticsPeriod
    let steps: [StepData]
    let heartRates: [HeartRateData]
    let sleepData: [SleepData]
    let workouts: [WorkoutData]
    
    /// 총 걸음 수
    var totalSteps: Int {
        steps.reduce(0) { $0 + $1.count }
    }
    
    /// 평균 걸음 수
    var averageSteps: Int {
        guard !steps.isEmpty else { return 0 }
        return totalSteps / steps.count
    }
    
    /// 평균 심박수
    var averageHeartRate: Double {
        guard !heartRates.isEmpty else { return 0 }
        return heartRates.reduce(0) { $0 + $1.bpm } / Double(heartRates.count)
    }
    
    /// 총 수면 시간 (분)
    var totalSleepMinutes: Int {
        sleepData
            .filter { $0.category != .awake && $0.category != .inBed }
            .reduce(0) { $0 + $1.durationMinutes }
    }
    
    /// 총 운동 칼로리
    var totalWorkoutCalories: Double {
        workouts.reduce(0) { $0 + $1.calories }
    }
    
    /// 총 운동 시간 (분)
    var totalWorkoutMinutes: Int {
        workouts.reduce(0) { $0 + $1.durationMinutes }
    }
}

/// 통계 기간 열거형
enum StatisticsPeriod: String, CaseIterable, Identifiable {
    case week = "주간"
    case month = "월간"
    case year = "연간"
    
    var id: String { rawValue }
    
    /// 기간에 해당하는 일수
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
    
    /// 시작 날짜 계산
    var startDate: Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
}
