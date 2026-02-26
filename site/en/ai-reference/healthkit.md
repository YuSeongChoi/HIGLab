# HealthKit AI Reference

> 건강 데이터 읽기/쓰기 가이드. 이 문서를 읽고 HealthKit 코드를 생성할 수 있습니다.

## 개요

HealthKit은 건강 및 피트니스 데이터를 읽고 쓰는 프레임워크입니다.
걸음 수, 심박수, 수면, 운동 기록 등 다양한 건강 데이터를 관리합니다.

## 필수 Import

```swift
import HealthKit
```

## 프로젝트 설정

1. **Capabilities**: HealthKit 추가
2. **Info.plist**:
   - `NSHealthShareUsageDescription`: 읽기 권한 설명
   - `NSHealthUpdateUsageDescription`: 쓰기 권한 설명

## 핵심 구성요소

### 1. HKHealthStore (진입점)

```swift
class HealthKitManager {
    let healthStore = HKHealthStore()
    
    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async throws {
        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKCategoryType(.sleepAnalysis)
        ]
        
        let writeTypes: Set<HKSampleType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned)
        ]
        
        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
    }
}
```

### 2. 데이터 타입

```swift
// 수량형 (Quantity)
let stepCount = HKQuantityType(.stepCount)
let heartRate = HKQuantityType(.heartRate)
let calories = HKQuantityType(.activeEnergyBurned)
let distance = HKQuantityType(.distanceWalkingRunning)

// 카테고리형 (Category)
let sleep = HKCategoryType(.sleepAnalysis)
let mindfulness = HKCategoryType(.mindfulSession)

// 운동 (Workout)
let workout = HKWorkoutType.workoutType()

// 특성 (Characteristic) - 읽기 전용
let bloodType = HKCharacteristicType(.bloodType)
let biologicalSex = HKCharacteristicType(.biologicalSex)
```

### 3. 데이터 읽기

```swift
// 오늘 걸음 수
func fetchTodaySteps() async throws -> Double {
    let stepType = HKQuantityType(.stepCount)
    let predicate = HKQuery.predicateForSamples(
        withStart: Calendar.current.startOfDay(for: Date()),
        end: Date()
    )
    
    let descriptor = HKStatisticsQueryDescriptor(
        predicate: HKSamplePredicate.quantitySample(type: stepType, predicate: predicate),
        options: .cumulativeSum
    )
    
    let result = try await descriptor.result(for: healthStore)
    return result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
}

// 최근 심박수
func fetchRecentHeartRate() async throws -> [HKQuantitySample] {
    let heartRateType = HKQuantityType(.heartRate)
    let sortDescriptor = SortDescriptor(\HKQuantitySample.startDate, order: .reverse)
    
    let descriptor = HKSampleQueryDescriptor(
        predicates: [.quantitySample(type: heartRateType)],
        sortDescriptors: [sortDescriptor],
        limit: 10
    )
    
    return try await descriptor.result(for: healthStore)
}
```

## 전체 작동 예제

```swift
import SwiftUI
import HealthKit

// MARK: - ViewModel
@Observable
class HealthViewModel {
    let healthStore = HKHealthStore()
    
    var steps: Double = 0
    var heartRate: Double = 0
    var calories: Double = 0
    var sleepHours: Double = 0
    var isAuthorized = false
    var error: Error?
    
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKCategoryType(.sleepAnalysis)
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            await fetchAllData()
        } catch {
            self.error = error
        }
    }
    
    func fetchAllData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchSteps() }
            group.addTask { await self.fetchHeartRate() }
            group.addTask { await self.fetchCalories() }
            group.addTask { await self.fetchSleep() }
        }
    }
    
    private func fetchSteps() async {
        let stepType = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date()
        )
        
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: HKSamplePredicate.quantitySample(type: stepType, predicate: predicate),
            options: .cumulativeSum
        )
        
        do {
            let result = try await descriptor.result(for: healthStore)
            steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
        } catch {
            print("걸음 수 조회 실패: \(error)")
        }
    }
    
    private func fetchHeartRate() async {
        let heartRateType = HKQuantityType(.heartRate)
        let sortDescriptor = SortDescriptor(\HKQuantitySample.startDate, order: .reverse)
        
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: heartRateType)],
            sortDescriptors: [sortDescriptor],
            limit: 1
        )
        
        do {
            let samples = try await descriptor.result(for: healthStore)
            if let sample = samples.first {
                heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            }
        } catch {
            print("심박수 조회 실패: \(error)")
        }
    }
    
    private func fetchCalories() async {
        let calorieType = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date()
        )
        
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: HKSamplePredicate.quantitySample(type: calorieType, predicate: predicate),
            options: .cumulativeSum
        )
        
        do {
            let result = try await descriptor.result(for: healthStore)
            calories = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
        } catch {
            print("칼로리 조회 실패: \(error)")
        }
    }
    
    private func fetchSleep() async {
        let sleepType = HKCategoryType(.sleepAnalysis)
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!
        
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now)
        let sortDescriptor = SortDescriptor(\HKCategorySample.startDate, order: .forward)
        
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: sleepType, predicate: predicate)],
            sortDescriptors: [sortDescriptor]
        )
        
        do {
            let samples = try await descriptor.result(for: healthStore)
            let asleepSamples = samples.filter { $0.value != HKCategoryValueSleepAnalysis.inBed.rawValue }
            
            sleepHours = asleepSamples.reduce(0) { total, sample in
                total + sample.endDate.timeIntervalSince(sample.startDate)
            } / 3600
        } catch {
            print("수면 조회 실패: \(error)")
        }
    }
}

// MARK: - View
struct HealthDashboardView: View {
    @State private var viewModel = HealthViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    HealthCard(title: "걸음", value: "\(Int(viewModel.steps))", unit: "걸음", icon: "figure.walk", color: .green)
                    HealthCard(title: "심박수", value: "\(Int(viewModel.heartRate))", unit: "BPM", icon: "heart.fill", color: .red)
                    HealthCard(title: "칼로리", value: "\(Int(viewModel.calories))", unit: "kcal", icon: "flame.fill", color: .orange)
                    HealthCard(title: "수면", value: String(format: "%.1f", viewModel.sleepHours), unit: "시간", icon: "moon.fill", color: .indigo)
                }
                .padding()
            }
            .navigationTitle("건강")
            .task {
                await viewModel.requestAuthorization()
            }
            .refreshable {
                await viewModel.fetchAllData()
            }
        }
    }
}

struct HealthCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(color)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

## 고급 패턴

### 1. 데이터 쓰기

```swift
func saveWorkout(type: HKWorkoutActivityType, duration: TimeInterval, calories: Double) async throws {
    let workout = HKWorkout(
        activityType: type,
        start: Date().addingTimeInterval(-duration),
        end: Date(),
        duration: duration,
        totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
        totalDistance: nil,
        metadata: nil
    )
    
    try await healthStore.save(workout)
}

func saveSteps(count: Double, start: Date, end: Date) async throws {
    let stepType = HKQuantityType(.stepCount)
    let quantity = HKQuantity(unit: .count(), doubleValue: count)
    let sample = HKQuantitySample(type: stepType, quantity: quantity, start: start, end: end)
    
    try await healthStore.save(sample)
}
```

### 2. 백그라운드 업데이트

```swift
func enableBackgroundDelivery() async throws {
    let stepType = HKQuantityType(.stepCount)
    
    try await healthStore.enableBackgroundDelivery(for: stepType, frequency: .hourly)
    
    // Observer Query로 변경 감지
    let query = HKObserverQuery(sampleType: stepType, predicate: nil) { query, completionHandler, error in
        // 데이터 변경됨 → 새로고침
        Task {
            await self.fetchSteps()
        }
        completionHandler()
    }
    
    healthStore.execute(query)
}
```

### 3. 통계 컬렉션 (차트용)

```swift
func fetchWeeklySteps() async throws -> [(date: Date, steps: Double)] {
    let stepType = HKQuantityType(.stepCount)
    let calendar = Calendar.current
    let now = Date()
    let startOfWeek = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: now))!
    
    let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: now)
    
    let descriptor = HKStatisticsCollectionQueryDescriptor(
        predicate: HKSamplePredicate.quantitySample(type: stepType, predicate: predicate),
        options: .cumulativeSum,
        anchorDate: startOfWeek,
        intervalComponents: DateComponents(day: 1)
    )
    
    let collection = try await descriptor.result(for: healthStore)
    
    var results: [(Date, Double)] = []
    collection.enumerateStatistics(from: startOfWeek, to: now) { statistics, _ in
        let steps = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
        results.append((statistics.startDate, steps))
    }
    
    return results
}
```

## 주의사항

1. **권한 확인**
   - 권한 상태는 정확히 알 수 없음 (프라이버시)
   - `.notDetermined`, `.sharingDenied` 등 제한적 상태만 확인 가능

2. **단위 변환**
   ```swift
   // 거리: 미터 또는 마일
   let meters = quantity.doubleValue(for: .meter())
   let miles = quantity.doubleValue(for: .mile())
   
   // 에너지: 칼로리 또는 줄
   let kcal = quantity.doubleValue(for: .kilocalorie())
   
   // 심박수: count/min
   let bpm = quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
   ```

3. **백그라운드 제한**
   - `enableBackgroundDelivery` 필요
   - 빈도: `.immediate`, `.hourly`, `.daily`
   - 배터리 영향 고려

4. **시뮬레이터 제한**
   - 시뮬레이터에서는 HealthKit 사용 불가
   - 실제 기기에서만 테스트 가능
