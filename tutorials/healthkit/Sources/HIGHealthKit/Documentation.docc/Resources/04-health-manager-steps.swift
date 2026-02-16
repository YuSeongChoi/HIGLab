import HealthKit
import SwiftUI

// MARK: - 걸음 수 조회가 통합된 HealthManager

@MainActor
class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var todaySteps: Int = 0
    @Published var isLoading = false
    
    /// 오늘의 걸음 수 조회
    func fetchTodaySteps() async {
        isLoading = true
        defer { isLoading = false }
        
        let stepType = HKQuantityType(.stepCount)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let now = Date()
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        do {
            let steps = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int, Error>) in
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
                
                self.healthStore.execute(query)
            }
            
            self.todaySteps = steps
            
        } catch {
            print("걸음 수 조회 실패: \(error)")
            self.todaySteps = 0
        }
    }
}
