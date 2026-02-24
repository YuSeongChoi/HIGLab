# HealthKit AI Reference

> Health data read/write guide. Read this document to generate HealthKit code.

## Overview

HealthKit is a framework for reading and writing health and fitness data.
It manages various health data including step count, heart rate, sleep, workout records, and more.

## Required Import

```swift
import HealthKit
```

## Project Setup

1. **Capabilities**: Add HealthKit
2. **Info.plist**:
   - `NSHealthShareUsageDescription`: Read permission description
   - `NSHealthUpdateUsageDescription`: Write permission description

## Core Components

### 1. HKHealthStore (Entry Point)

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

### 2. Data Types

```swift
// Quantity types
let stepCount = HKQuantityType(.stepCount)
let heartRate = HKQuantityType(.heartRate)
let calories = HKQuantityType(.activeEnergyBurned)
let distance = HKQuantityType(.distanceWalkingRunning)

// Category types
let sleep = HKCategoryType(.sleepAnalysis)
let mindfulness = HKCategoryType(.mindfulSession)

// Workout
let workout = HKWorkoutType.workoutType()

// Characteristics (read-only)
let bloodType = HKCharacteristicType(.bloodType)
let biologicalSex = HKCharacteristicType(.biologicalSex)
```

### 3. Reading Data

```swift
// Today's step count
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

// Recent heart rate
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

## Complete Working Example

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
            print("Failed to fetch steps: \(error)")
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
            print("Failed to fetch heart rate: \(error)")
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
            print("Failed to fetch calories: \(error)")
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
            print("Failed to fetch sleep: \(error)")
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
                    HealthCard(title: "Steps", value: "\(Int(viewModel.steps))", unit: "steps", icon: "figure.walk", color: .green)
                    HealthCard(title: "Heart Rate", value: "\(Int(viewModel.heartRate))", unit: "BPM", icon: "heart.fill", color: .red)
                    HealthCard(title: "Calories", value: "\(Int(viewModel.calories))", unit: "kcal", icon: "flame.fill", color: .orange)
                    HealthCard(title: "Sleep", value: String(format: "%.1f", viewModel.sleepHours), unit: "hours", icon: "moon.fill", color: .indigo)
                }
                .padding()
            }
            .navigationTitle("Health")
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

## Advanced Patterns

### 1. Writing Data

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

### 2. Background Updates

```swift
func enableBackgroundDelivery() async throws {
    let stepType = HKQuantityType(.stepCount)
    
    try await healthStore.enableBackgroundDelivery(for: stepType, frequency: .hourly)
    
    // Detect changes with Observer Query
    let query = HKObserverQuery(sampleType: stepType, predicate: nil) { query, completionHandler, error in
        // Data changed → refresh
        Task {
            await self.fetchSteps()
        }
        completionHandler()
    }
    
    healthStore.execute(query)
}
```

### 3. Statistics Collection (For Charts)

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

## Important Notes

1. **Permission Checking**
   - Exact permission status cannot be determined (privacy)
   - Only limited states like `.notDetermined`, `.sharingDenied` can be checked

2. **Unit Conversion**
   ```swift
   // Distance: meters or miles
   let meters = quantity.doubleValue(for: .meter())
   let miles = quantity.doubleValue(for: .mile())
   
   // Energy: calories or joules
   let kcal = quantity.doubleValue(for: .kilocalorie())
   
   // Heart rate: count/min
   let bpm = quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
   ```

3. **Background Limitations**
   - `enableBackgroundDelivery` required
   - Frequency: `.immediate`, `.hourly`, `.daily`
   - Consider battery impact

4. **Simulator Limitations**
   - HealthKit cannot be used in the simulator
   - Testing only possible on a real device
