import HealthKit

// MARK: - async/await 래퍼

extension HKHealthStore {
    /// 걸음 수 조회 (async/await)
    func fetchStepCount(
        start: Date,
        end: Date
    ) async throws -> Int {
        let stepType = HKQuantityType(.stepCount)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: stepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let total = (samples as? [HKQuantitySample])?
                    .reduce(0.0) { $0 + $1.quantity.doubleValue(for: .count()) }
                    ?? 0
                
                continuation.resume(returning: Int(total))
            }
            
            self.execute(query)
        }
    }
}

// 사용 예시
func example() async throws {
    let healthStore = HKHealthStore()
    let startOfDay = Calendar.current.startOfDay(for: Date())
    
    let steps = try await healthStore.fetchStepCount(
        start: startOfDay,
        end: Date()
    )
    print("오늘 걸음 수: \(steps)")
}
