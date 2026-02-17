import Foundation
import HealthKit

// MARK: - HealthKit 서비스
/// HealthKit과의 모든 상호작용을 담당하는 서비스 클래스
@MainActor
final class HealthKitService: ObservableObject {
    
    // MARK: - 싱글톤 인스턴스
    static let shared = HealthKitService()
    
    // MARK: - 속성
    private let healthStore = HKHealthStore()
    
    /// HealthKit 사용 가능 여부
    @Published private(set) var isAvailable: Bool = false
    
    /// 권한 승인 상태
    @Published private(set) var isAuthorized: Bool = false
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    // MARK: - 초기화
    private init() {
        isAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - 권한 요청
    /// HealthKit 읽기/쓰기 권한 요청
    func requestAuthorization() async throws {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }
        
        // 읽기 권한이 필요한 타입들
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.workoutType()
        ]
        
        // 쓰기 권한이 필요한 타입들
        let writeTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.workoutType()
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
            isAuthorized = true
        } catch {
            isAuthorized = false
            throw HealthKitError.authorizationFailed(error)
        }
    }
    
    // MARK: - 걸음 수 조회
    /// 지정된 기간의 일별 걸음 수 조회
    /// - Parameter days: 조회할 일수
    /// - Returns: 일별 걸음 수 배열
    func fetchSteps(for days: Int) async throws -> [StepData] {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.typeNotAvailable
        }
        
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            throw HealthKitError.invalidDateRange
        }
        
        // 일별로 그룹화
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: calendar.startOfDay(for: startDate),
            intervalComponents: interval
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                
                var stepDataArray: [StepData] = []
                
                results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                    let count = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    let data = StepData(date: statistics.startDate, count: Int(count))
                    stepDataArray.append(data)
                }
                
                continuation.resume(returning: stepDataArray)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// 오늘의 걸음 수 조회
    func fetchTodaySteps() async throws -> Int {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.typeNotAvailable
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                
                let count = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(count))
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - 심박수 조회
    /// 지정된 기간의 심박수 데이터 조회
    /// - Parameter hours: 조회할 시간 (기본 24시간)
    /// - Returns: 심박수 데이터 배열
    func fetchHeartRate(for hours: Int = 24) async throws -> [HeartRateData] {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw HealthKitError.typeNotAvailable
        }
        
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .hour, value: -hours, to: endDate) else {
            throw HealthKitError.invalidDateRange
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                
                let heartRateData = samples?.compactMap { sample -> HeartRateData? in
                    guard let quantitySample = sample as? HKQuantitySample else { return nil }
                    let bpm = quantitySample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    return HeartRateData(date: quantitySample.startDate, bpm: bpm)
                } ?? []
                
                continuation.resume(returning: heartRateData)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// 최신 심박수 조회
    func fetchLatestHeartRate() async throws -> HeartRateData? {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw HealthKitError.typeNotAvailable
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                let data = HeartRateData(date: sample.startDate, bpm: bpm)
                continuation.resume(returning: data)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - 수면 데이터 조회
    /// 지정된 기간의 수면 데이터 조회
    /// - Parameter days: 조회할 일수
    /// - Returns: 수면 데이터 배열
    func fetchSleepData(for days: Int) async throws -> [SleepData] {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.typeNotAvailable
        }
        
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) else {
            throw HealthKitError.invalidDateRange
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                
                let sleepData = samples?.compactMap { sample -> SleepData? in
                    guard let categorySample = sample as? HKCategorySample else { return nil }
                    let category = SleepCategory(from: HKCategoryValueSleepAnalysis(rawValue: categorySample.value) ?? .asleepUnspecified)
                    return SleepData(
                        startDate: categorySample.startDate,
                        endDate: categorySample.endDate,
                        category: category
                    )
                } ?? []
                
                continuation.resume(returning: sleepData)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// 지난 밤 수면 요약
    func fetchLastNightSleep() async throws -> (totalMinutes: Int, quality: String) {
        let sleepData = try await fetchSleepData(for: 1)
        
        // 실제 수면 시간만 계산 (침대에 있음, 깨어있음 제외)
        let actualSleep = sleepData.filter { $0.category != .inBed && $0.category != .awake }
        let totalMinutes = actualSleep.reduce(0) { $0 + $1.durationMinutes }
        
        // 깊은 수면 비율로 품질 판단
        let deepSleep = sleepData.filter { $0.category == .asleepDeep }
        let deepMinutes = deepSleep.reduce(0) { $0 + $1.durationMinutes }
        let deepRatio = totalMinutes > 0 ? Double(deepMinutes) / Double(totalMinutes) : 0
        
        let quality: String
        if deepRatio > 0.2 {
            quality = "좋음"
        } else if deepRatio > 0.1 {
            quality = "보통"
        } else {
            quality = "개선 필요"
        }
        
        return (totalMinutes, quality)
    }
    
    // MARK: - 운동 데이터 조회
    /// 지정된 기간의 운동 데이터 조회
    /// - Parameter days: 조회할 일수
    /// - Returns: 운동 데이터 배열
    func fetchWorkouts(for days: Int) async throws -> [WorkoutData] {
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) else {
            throw HealthKitError.invalidDateRange
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                
                let workouts = samples?.compactMap { sample -> WorkoutData? in
                    guard let workout = sample as? HKWorkout else { return nil }
                    
                    let calories = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
                    let distance = workout.totalDistance?.doubleValue(for: .meter())
                    
                    return WorkoutData(
                        type: WorkoutType(from: workout.workoutActivityType),
                        startDate: workout.startDate,
                        endDate: workout.endDate,
                        calories: calories,
                        distance: distance
                    )
                } ?? []
                
                continuation.resume(returning: workouts)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - 운동 저장
    /// 새 운동 기록 저장
    /// - Parameters:
    ///   - type: 운동 유형
    ///   - startDate: 시작 시간
    ///   - endDate: 종료 시간
    ///   - calories: 소모 칼로리
    ///   - distance: 이동 거리 (미터, 선택)
    func saveWorkout(
        type: WorkoutType,
        startDate: Date,
        endDate: Date,
        calories: Double,
        distance: Double? = nil
    ) async throws {
        var samples: [HKSample] = []
        
        // 칼로리 샘플 생성
        if let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            let calorieQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
            let calorieSample = HKQuantitySample(
                type: calorieType,
                quantity: calorieQuantity,
                start: startDate,
                end: endDate
            )
            samples.append(calorieSample)
        }
        
        // 거리 샘플 생성 (해당하는 경우)
        if let distance = distance,
           let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            let distanceQuantity = HKQuantity(unit: .meter(), doubleValue: distance)
            let distanceSample = HKQuantitySample(
                type: distanceType,
                quantity: distanceQuantity,
                start: startDate,
                end: endDate
            )
            samples.append(distanceSample)
        }
        
        // 운동 빌더로 운동 생성
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = type.hkWorkoutType
        
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: nil)
        
        try await builder.beginCollection(at: startDate)
        
        if !samples.isEmpty {
            try await builder.addSamples(samples)
        }
        
        try await builder.endCollection(at: endDate)
        try await builder.finishWorkout()
    }
    
    // MARK: - 활동 칼로리 조회
    /// 오늘의 활동 칼로리 조회
    func fetchTodayCalories() async throws -> Double {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw HealthKitError.typeNotAvailable
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: calorieType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                
                let calories = statistics?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: calories)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// 오늘의 이동 거리 조회 (km)
    func fetchTodayDistance() async throws -> Double {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            throw HealthKitError.typeNotAvailable
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }
                
                let meters = statistics?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                continuation.resume(returning: meters / 1000) // km로 변환
            }
            
            healthStore.execute(query)
        }
    }
}

// MARK: - HealthKit 에러 정의
/// HealthKit 관련 에러 열거형
enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationFailed(Error)
    case typeNotAvailable
    case invalidDateRange
    case queryFailed(Error)
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "이 기기에서는 HealthKit을 사용할 수 없습니다."
        case .authorizationFailed(let error):
            return "HealthKit 권한 요청 실패: \(error.localizedDescription)"
        case .typeNotAvailable:
            return "요청한 건강 데이터 유형을 사용할 수 없습니다."
        case .invalidDateRange:
            return "유효하지 않은 날짜 범위입니다."
        case .queryFailed(let error):
            return "데이터 조회 실패: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "데이터 저장 실패: \(error.localizedDescription)"
        }
    }
}
