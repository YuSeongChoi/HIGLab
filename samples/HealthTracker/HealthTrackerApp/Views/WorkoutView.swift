import SwiftUI

// MARK: - 운동 뷰
/// 운동 기록을 관리하고 표시하는 뷰
struct WorkoutView: View {
    @EnvironmentObject var viewModel: HealthViewModel
    @State private var showAddWorkout = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 이번 주 요약
                    weekSummarySection
                    
                    // 운동 유형별 통계
                    workoutTypesSection
                    
                    // 운동 기록 리스트
                    workoutListSection
                }
                .padding()
            }
            .navigationTitle("운동")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddWorkout = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddWorkout) {
                AddWorkoutView()
            }
            .refreshable {
                await viewModel.loadWorkouts()
            }
        }
    }
    
    // MARK: - 이번 주 요약 섹션
    private var weekSummarySection: some View {
        VStack(spacing: 16) {
            Text("이번 주")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let weekWorkouts = thisWeekWorkouts
            
            HStack(spacing: 20) {
                // 운동 횟수
                SummaryStatCard(
                    icon: "figure.run",
                    value: "\(weekWorkouts.count)",
                    unit: "회",
                    label: "운동 횟수",
                    color: .orange
                )
                
                // 총 시간
                SummaryStatCard(
                    icon: "clock.fill",
                    value: "\(totalMinutes(weekWorkouts))",
                    unit: "분",
                    label: "운동 시간",
                    color: .blue
                )
                
                // 총 칼로리
                SummaryStatCard(
                    icon: "flame.fill",
                    value: "\(Int(totalCalories(weekWorkouts)))",
                    unit: "kcal",
                    label: "소모 칼로리",
                    color: .red
                )
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.orange.opacity(0.1), .red.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 운동 유형별 섹션
    private var workoutTypesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("운동 유형")
                .font(.headline)
            
            let typeCounts = workoutCountByType
            
            if typeCounts.isEmpty {
                Text("아직 운동 기록이 없습니다")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(typeCounts.sorted(by: { $0.value > $1.value }), id: \.key) { type, count in
                        WorkoutTypeCard(type: type, count: count)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 운동 기록 리스트 섹션
    private var workoutListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("최근 운동")
                .font(.headline)
            
            if viewModel.isLoadingWorkouts {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if viewModel.workouts.isEmpty {
                EmptyWorkoutView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.workouts) { workout in
                        WorkoutDetailRow(workout: workout)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 계산 속성
    
    /// 이번 주 운동 목록
    private var thisWeekWorkouts: [WorkoutData] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return viewModel.workouts.filter { $0.startDate >= weekAgo }
    }
    
    /// 운동 유형별 횟수
    private var workoutCountByType: [WorkoutType: Int] {
        var counts: [WorkoutType: Int] = [:]
        for workout in viewModel.workouts {
            counts[workout.type, default: 0] += 1
        }
        return counts
    }
    
    /// 총 운동 시간 (분)
    private func totalMinutes(_ workouts: [WorkoutData]) -> Int {
        workouts.reduce(0) { $0 + $1.durationMinutes }
    }
    
    /// 총 소모 칼로리
    private func totalCalories(_ workouts: [WorkoutData]) -> Double {
        workouts.reduce(0) { $0 + $1.calories }
    }
}

// MARK: - 요약 통계 카드
/// 운동 요약 통계를 표시하는 카드
struct SummaryStatCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 운동 유형 카드
/// 운동 유형별 통계를 표시하는 카드
struct WorkoutTypeCard: View {
    let type: WorkoutType
    let count: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.orange.gradient)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(count)회")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 운동 상세 행
/// 개별 운동 기록을 상세히 표시하는 행
struct WorkoutDetailRow: View {
    let workout: WorkoutData
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // 운동 아이콘
                Image(systemName: workout.type.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.orange.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 운동 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.type.rawValue)
                        .font(.headline)
                    
                    Text(workout.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 운동 시간
                VStack(alignment: .trailing, spacing: 4) {
                    Text(workout.formattedDuration)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("\(Int(workout.calories)) kcal")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            
            // 추가 정보 (거리가 있는 경우)
            if let distance = workout.formattedDistance {
                HStack {
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "map.fill")
                            .font(.caption)
                        Text(distance)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 빈 운동 뷰
/// 운동 기록이 없을 때 표시하는 뷰
struct EmptyWorkoutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("운동 기록이 없습니다")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("+ 버튼을 눌러 운동을 기록하거나\nApple Watch로 운동을 시작하세요")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - 운동 추가 뷰
/// 새 운동을 추가하는 시트 뷰
struct AddWorkoutView: View {
    @EnvironmentObject var viewModel: HealthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: WorkoutType = .running
    @State private var duration: Int = 30
    @State private var calories: Double = 200
    @State private var distance: String = ""
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                // 운동 유형 선택
                Section("운동 유형") {
                    Picker("유형", selection: $selectedType) {
                        ForEach(WorkoutType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                // 운동 시간
                Section("운동 시간") {
                    Stepper(value: $duration, in: 1...300, step: 5) {
                        HStack {
                            Text("시간")
                            Spacer()
                            Text("\(duration)분")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // 빠른 선택 버튼
                    HStack(spacing: 12) {
                        ForEach([15, 30, 45, 60], id: \.self) { minutes in
                            Button {
                                duration = minutes
                            } label: {
                                Text("\(minutes)분")
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(duration == minutes ? Color.orange : Color(.systemGray5))
                                    .foregroundStyle(duration == minutes ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // 소모 칼로리
                Section("소모 칼로리") {
                    HStack {
                        TextField("칼로리", value: $calories, format: .number)
                            .keyboardType(.decimalPad)
                        Text("kcal")
                            .foregroundStyle(.secondary)
                    }
                    
                    // 예상 칼로리 안내
                    Text("💡 \(selectedType.rawValue) \(duration)분 기준 약 \(estimatedCalories)kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // 거리 (선택)
                Section("거리 (선택)") {
                    HStack {
                        TextField("거리", text: $distance)
                            .keyboardType(.decimalPad)
                        Text("km")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("운동 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveWorkout()
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("저장")
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
    
    /// 예상 칼로리 계산
    private var estimatedCalories: Int {
        let caloriesPerMinute: Double
        switch selectedType {
        case .running: caloriesPerMinute = 11
        case .walking: caloriesPerMinute = 5
        case .cycling: caloriesPerMinute = 8
        case .swimming: caloriesPerMinute = 10
        case .hiking: caloriesPerMinute = 7
        case .yoga: caloriesPerMinute = 4
        case .strength: caloriesPerMinute = 6
        case .other: caloriesPerMinute = 5
        }
        return Int(caloriesPerMinute * Double(duration))
    }
    
    /// 운동 저장
    private func saveWorkout() {
        isSaving = true
        
        let distanceKm = Double(distance)
        
        Task {
            await viewModel.saveWorkout(
                type: selectedType,
                duration: duration,
                calories: calories,
                distance: distanceKm
            )
            
            dismiss()
        }
    }
}

// MARK: - 프리뷰
#Preview {
    WorkoutView()
        .environmentObject(HealthViewModel())
}

#Preview("운동 추가") {
    AddWorkoutView()
        .environmentObject(HealthViewModel())
}
