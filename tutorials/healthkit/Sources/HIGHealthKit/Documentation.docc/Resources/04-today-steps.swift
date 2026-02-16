import HealthKit

// MARK: - 오늘의 걸음 수 쿼리

func fetchTodaySteps(healthStore: HKHealthStore) async throws -> [HKQuantitySample] {
    let stepType = HKQuantityType(.stepCount)
    
    // 오늘 자정 ~ 현재
    let calendar = Calendar.current
    let now = Date()
    let startOfDay = calendar.startOfDay(for: now)
    
    let predicate = HKQuery.predicateForSamples(
        withStart: startOfDay,
        end: now,
        options: .strictStartDate
    )
    
    // 최신 순으로 정렬
    let sortDescriptor = NSSortDescriptor(
        key: HKSampleSortIdentifierEndDate,
        ascending: false
    )
    
    // async/await 래퍼 사용
    return try await withCheckedThrowingContinuation { continuation in
        let query = HKSampleQuery(
            sampleType: stepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,  // 모든 샘플
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            
            let quantitySamples = samples as? [HKQuantitySample] ?? []
            continuation.resume(returning: quantitySamples)
        }
        
        healthStore.execute(query)
    }
}
