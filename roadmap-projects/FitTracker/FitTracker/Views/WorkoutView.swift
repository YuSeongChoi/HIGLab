import SwiftUI
import MapKit

struct WorkoutView: View {
    @Environment(HealthManager.self) private var healthManager
    @State private var locationManager = LocationManager()
    @State private var activityManager = ActivityManager()
    
    @State private var isWorkoutActive = false
    @State private var workoutType: WorkoutType = .running
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showWorkoutSummary = false
    
    enum WorkoutType: String, CaseIterable {
        case running = "달리기"
        case walking = "걷기"
        case cycling = "자전거"
        
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
            VStack(spacing: 0) {
                if isWorkoutActive {
                    // 운동 중 화면
                    activeWorkoutView
                } else {
                    // 운동 선택 화면
                    workoutSelectionView
                }
            }
            .navigationTitle(isWorkoutActive ? workoutType.rawValue : "운동")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showWorkoutSummary) {
                WorkoutSummaryView(
                    workoutType: workoutType,
                    duration: elapsedTime,
                    distance: locationManager.totalDistance,
                    calories: calculateCalories()
                )
            }
        }
    }
    
    // MARK: - Workout Selection
    private var workoutSelectionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("운동을 선택하세요")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                
                ForEach(WorkoutType.allCases, id: \.self) { type in
                    WorkoutTypeCard(
                        type: type,
                        isSelected: workoutType == type
                    ) {
                        workoutType = type
                    }
                }
                
                Button {
                    startWorkout()
                } label: {
                    Label("운동 시작", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.top)
            }
            .padding()
        }
    }
    
    // MARK: - Active Workout
    private var activeWorkoutView: some View {
        VStack(spacing: 0) {
            // 지도
            Map {
                // 현재 위치
                if let location = locationManager.currentLocation {
                    Annotation("", coordinate: location.coordinate) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 16, height: 16)
                            .overlay {
                                Circle()
                                    .stroke(.white, lineWidth: 3)
                            }
                    }
                }
                
                // 경로
                MapPolyline(locationManager.routePolyline)
                    .stroke(.blue, lineWidth: 4)
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(height: 300)
            
            // 통계
            VStack(spacing: 20) {
                // 시간
                Text(elapsedTime.formatted)
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                
                // 거리 & 칼로리
                HStack(spacing: 40) {
                    VStack {
                        Text(locationManager.formattedDistance)
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("거리")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack {
                        Text(String(format: "%.0f", calculateCalories()))
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("칼로리")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack {
                        Text(calculatePace())
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("페이스")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // 정지 버튼
                Button {
                    stopWorkout()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
    }
    
    // MARK: - Actions
    private func startWorkout() {
        isWorkoutActive = true
        elapsedTime = 0
        
        locationManager.startTracking()
        activityManager.startActivity(workoutType: workoutType.rawValue)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
            
            // Live Activity 업데이트
            Task {
                await activityManager.updateActivity(
                    elapsedTime: elapsedTime,
                    distance: locationManager.totalDistance,
                    calories: calculateCalories(),
                    heartRate: healthManager.heartRate,
                    pace: calculatePace()
                )
            }
        }
    }
    
    private func stopWorkout() {
        timer?.invalidate()
        timer = nil
        
        locationManager.stopTracking()
        
        Task {
            await activityManager.endActivity(
                finalDistance: locationManager.totalDistance,
                finalCalories: calculateCalories(),
                finalTime: elapsedTime
            )
            
            // HealthKit에 저장
            try? await healthManager.saveWorkout(
                type: .running, // 실제 앱에서는 workoutType에 따라 변환
                start: Date().addingTimeInterval(-elapsedTime),
                end: Date(),
                calories: calculateCalories(),
                distance: locationManager.totalDistance
            )
        }
        
        isWorkoutActive = false
        showWorkoutSummary = true
    }
    
    private func calculateCalories() -> Double {
        // 간단한 칼로리 계산 (거리 기반)
        return locationManager.totalDistance * 0.05
    }
    
    private func calculatePace() -> String {
        guard locationManager.totalDistance > 0 else { return "--:--" }
        let paceSeconds = elapsedTime / (locationManager.totalDistance / 1000)
        let minutes = Int(paceSeconds) / 60
        let seconds = Int(paceSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Workout Type Card
struct WorkoutTypeCard: View {
    let type: WorkoutView.WorkoutType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.title)
                    .frame(width: 50)
                
                Text(type.rawValue)
                    .font(.headline)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            .padding()
            .background(isSelected ? Color.green.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Workout Summary
struct WorkoutSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    let workoutType: WorkoutView.WorkoutType
    let duration: TimeInterval
    let distance: Double
    let calories: Double
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                
                Text("운동 완료!")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 20) {
                    SummaryRow(title: "운동 종류", value: workoutType.rawValue)
                    SummaryRow(title: "시간", value: duration.formatted)
                    SummaryRow(title: "거리", value: String(format: "%.2f km", distance / 1000))
                    SummaryRow(title: "칼로리", value: String(format: "%.0f kcal", calories))
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer()
            }
            .padding()
            .navigationTitle("운동 요약")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { dismiss() }
                }
            }
        }
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    WorkoutView()
        .environment(HealthManager())
}
