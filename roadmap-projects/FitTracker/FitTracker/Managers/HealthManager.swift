import Foundation
import HealthKit
import Observation

@Observable
final class HealthManager {
    private let healthStore = HKHealthStore()
    
    private(set) var isAuthorized = false
    private(set) var todaySteps: Int = 0
    private(set) var todayDistance: Double = 0 // meters
    private(set) var todayCalories: Double = 0
    private(set) var todayActiveMinutes: Int = 0
    private(set) var heartRate: Int = 0
    
    // 읽기 권한 요청 타입
    private let readTypes: Set<HKSampleType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.distanceWalkingRunning),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.appleExerciseTime),
        HKQuantityType(.heartRate)
    ]
    
    // 쓰기 권한 요청 타입
    private let writeTypes: Set<HKSampleType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.distanceWalkingRunning),
        HKQuantityType(.activeEnergyBurned)
    ]
    
    init() {
        Task {
            await requestAuthorization()
        }
    }
    
    // MARK: - Authorization
    @MainActor
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
            isAuthorized = true
            await fetchTodayStats()
        } catch {
            print("HealthKit 권한 요청 실패: \(error)")
        }
    }
    
    // MARK: - Fetch Today's Stats
    @MainActor
    func fetchTodayStats() async {
        guard isAuthorized else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)
        
        async let steps = fetchSum(type: .stepCount, unit: .count(), predicate: predicate)
        async let distance = fetchSum(type: .distanceWalkingRunning, unit: .meter(), predicate: predicate)
        async let calories = fetchSum(type: .activeEnergyBurned, unit: .kilocalorie(), predicate: predicate)
        async let exerciseTime = fetchSum(type: .appleExerciseTime, unit: .minute(), predicate: predicate)
        
        todaySteps = Int(await steps)
        todayDistance = await distance
        todayCalories = await calories
        todayActiveMinutes = Int(await exerciseTime)
        
        await fetchLatestHeartRate()
    }
    
    // MARK: - Fetch Sum
    private func fetchSum(type: HKQuantityTypeIdentifier, unit: HKUnit, predicate: NSPredicate) async -> Double {
        await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: HKQuantityType(type),
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, _ in
                let value = statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }
    
    // MARK: - Fetch Latest Heart Rate
    @MainActor
    private func fetchLatestHeartRate() async {
        let type = HKQuantityType(.heartRate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { [weak self] _, samples, _ in
                if let sample = samples?.first as? HKQuantitySample {
                    let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    Task { @MainActor in
                        self?.heartRate = Int(bpm)
                    }
                }
                continuation.resume()
            }
            healthStore.execute(query)
        }
    }
    
    // MARK: - Save Workout
    func saveWorkout(
        type: HKWorkoutActivityType,
        start: Date,
        end: Date,
        calories: Double,
        distance: Double
    ) async throws {
        let workout = HKWorkout(
            activityType: type,
            start: start,
            end: end,
            duration: end.timeIntervalSince(start),
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
            totalDistance: HKQuantity(unit: .meter(), doubleValue: distance),
            metadata: nil
        )
        
        try await healthStore.save(workout)
    }
    
    // MARK: - Computed Properties
    var formattedDistance: String {
        if todayDistance >= 1000 {
            return String(format: "%.2f km", todayDistance / 1000)
        } else {
            return String(format: "%.0f m", todayDistance)
        }
    }
    
    var formattedCalories: String {
        String(format: "%.0f kcal", todayCalories)
    }
    
    var stepsProgress: Double {
        min(Double(todaySteps) / 10000.0, 1.0)
    }
}
