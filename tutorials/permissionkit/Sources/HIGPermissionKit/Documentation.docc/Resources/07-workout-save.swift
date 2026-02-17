import PermissionKit
import HealthKit
import SwiftUI

// 운동 데이터 저장
final class WorkoutSaver {
    private let healthStore: HKHealthStore
    
    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    
    /// 운동 기록 저장
    func saveWorkout(
        type: HKWorkoutActivityType,
        start: Date,
        end: Date,
        energyBurned: Double,
        distance: Double?
    ) async throws {
        // 운동 빌더 생성
        let builder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: HKWorkoutConfiguration(),
            device: .local()
        )
        
        // 운동 시작
        try await builder.beginCollection(at: start)
        
        // 칼로리 샘플 추가
        let energyType = HKQuantityType(.activeEnergyBurned)
        let energyQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: energyBurned)
        let energySample = HKQuantitySample(
            type: energyType,
            quantity: energyQuantity,
            start: start,
            end: end
        )
        try await builder.addSamples([energySample])
        
        // 거리 샘플 추가 (있는 경우)
        if let distance = distance {
            let distanceType = HKQuantityType(.distanceWalkingRunning)
            let distanceQuantity = HKQuantity(unit: .meter(), doubleValue: distance)
            let distanceSample = HKQuantitySample(
                type: distanceType,
                quantity: distanceQuantity,
                start: start,
                end: end
            )
            try await builder.addSamples([distanceSample])
        }
        
        // 운동 종료 및 저장
        try await builder.endCollection(at: end)
        try await builder.finishWorkout()
    }
}

// 운동 기록 뷰
struct WorkoutRecorderView: View {
    @State private var manager = HealthFullPermissionManager()
    @State private var workoutType: WorkoutType = .running
    @State private var duration: TimeInterval = 30 * 60 // 30분
    @State private var calories: Double = 200
    @State private var distance: Double = 3000 // 3km
    @State private var isSaving = false
    @State private var showSuccess = false
    
    enum WorkoutType: String, CaseIterable {
        case running = "달리기"
        case walking = "걷기"
        case cycling = "자전거"
        
        var hkType: HKWorkoutActivityType {
            switch self {
            case .running: return .running
            case .walking: return .walking
            case .cycling: return .cycling
            }
        }
        
        var icon: String {
            switch self {
            case .running: return "figure.run"
            case .walking: return "figure.walk"
            case .cycling: return "figure.outdoor.cycle"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("운동 종류") {
                    Picker("종류", selection: $workoutType) {
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }
                
                Section("운동 정보") {
                    HStack {
                        Text("시간")
                        Spacer()
                        Text("\(Int(duration / 60))분")
                    }
                    
                    HStack {
                        Text("칼로리")
                        Spacer()
                        Text("\(Int(calories)) kcal")
                    }
                    
                    HStack {
                        Text("거리")
                        Spacer()
                        Text(String(format: "%.1f km", distance / 1000))
                    }
                }
                
                Section {
                    Button {
                        Task {
                            await saveWorkout()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                            } else {
                                Text("운동 기록 저장")
                            }
                            Spacer()
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle("운동 기록")
            .alert("저장 완료", isPresented: $showSuccess) {
                Button("확인") { }
            } message: {
                Text("운동 기록이 건강 앱에 저장되었습니다.")
            }
        }
    }
    
    private func saveWorkout() async {
        isSaving = true
        
        let saver = WorkoutSaver(healthStore: manager.healthStore_)
        let end = Date()
        let start = end.addingTimeInterval(-duration)
        
        do {
            try await saver.saveWorkout(
                type: workoutType.hkType,
                start: start,
                end: end,
                energyBurned: calories,
                distance: distance
            )
            showSuccess = true
        } catch {
            print("운동 저장 실패: \(error)")
        }
        
        isSaving = false
    }
}

// iOS 26 PermissionKit - HIG Lab
