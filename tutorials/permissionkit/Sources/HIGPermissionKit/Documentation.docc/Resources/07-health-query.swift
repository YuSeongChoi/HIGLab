#if canImport(PermissionKit)
import PermissionKit
import HealthKit
import SwiftUI

// 건강 데이터 쿼리
final class HealthDataQuery {
    private let healthStore = HKHealthStore()
    
    /// 오늘의 걸음 수 가져오기
    func fetchTodaySteps() async throws -> Double {
        let stepsType = HKQuantityType(.stepCount)
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: steps)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// 오늘의 심박수 평균 가져오기
    func fetchTodayAverageHeartRate() async throws -> Double {
        let heartRateType = HKQuantityType(.heartRate)
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let unit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = result?.averageQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: heartRate)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// 최근 7일 걸음 수 가져오기
    func fetchWeeklySteps() async throws -> [(date: Date, steps: Double)] {
        let stepsType = HKQuantityType(.stepCount)
        
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        
        var interval = DateComponents()
        interval.day = 1
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: stepsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: Calendar.current.startOfDay(for: startDate),
                intervalComponents: interval
            )
            
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                var dailySteps: [(date: Date, steps: Double)] = []
                
                results?.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                    let steps = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    dailySteps.append((date: statistics.startDate, steps: steps))
                }
                
                continuation.resume(returning: dailySteps)
            }
            
            healthStore.execute(query)
        }
    }
}

// 건강 데이터 대시보드 뷰
struct HealthDashboardView: View {
    @State private var todaySteps: Double = 0
    @State private var averageHeartRate: Double = 0
    @State private var isLoading = true
    
    private let query = HealthDataQuery()
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("건강 데이터 로딩 중...")
            } else {
                HStack(spacing: 16) {
                    HealthMetricCard(
                        icon: "figure.walk",
                        title: "걸음 수",
                        value: "\(Int(todaySteps))",
                        color: .green
                    )
                    
                    HealthMetricCard(
                        icon: "heart.fill",
                        title: "평균 심박수",
                        value: "\(Int(averageHeartRate)) BPM",
                        color: .pink
                    )
                }
            }
        }
        .padding()
        .task {
            await loadHealthData()
        }
    }
    
    private func loadHealthData() async {
        do {
            todaySteps = try await query.fetchTodaySteps()
            averageHeartRate = try await query.fetchTodayAverageHeartRate()
        } catch {
            print("건강 데이터 로드 실패: \(error)")
        }
        isLoading = false
    }
}

struct HealthMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
