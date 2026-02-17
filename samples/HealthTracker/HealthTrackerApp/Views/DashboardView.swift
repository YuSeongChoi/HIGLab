import SwiftUI

// MARK: - 대시보드 뷰
/// 건강 데이터 요약을 보여주는 메인 대시보드
struct DashboardView: View {
    @EnvironmentObject var viewModel: HealthViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 오늘의 요약 카드
                    todaySummarySection
                    
                    // 목표 진행 상황
                    goalsSection
                    
                    // 주간 활동 차트
                    weeklyActivitySection
                    
                    // 최근 운동
                    recentWorkoutsSection
                }
                .padding()
            }
            .navigationTitle("건강 대시보드")
            .refreshable {
                await viewModel.loadAllData()
            }
        }
    }
    
    // MARK: - 오늘의 요약 섹션
    private var todaySummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("오늘의 건강")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                // 걸음 수 카드
                SummaryCard(
                    icon: "figure.walk",
                    title: "걸음 수",
                    value: viewModel.formattedTodaySteps,
                    color: .blue
                )
                
                // 칼로리 카드
                SummaryCard(
                    icon: "flame.fill",
                    title: "소모 칼로리",
                    value: viewModel.formattedTodayCalories,
                    color: .orange
                )
                
                // 이동 거리 카드
                SummaryCard(
                    icon: "map.fill",
                    title: "이동 거리",
                    value: viewModel.formattedTodayDistance,
                    color: .green
                )
                
                // 심박수 카드
                SummaryCard(
                    icon: "heart.fill",
                    title: "심박수",
                    value: viewModel.latestHeartRate.map { "\(Int($0.bpm)) BPM" } ?? "-- BPM",
                    color: .pink
                )
            }
        }
    }
    
    // MARK: - 목표 진행 섹션
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("오늘의 목표")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                NavigationLink {
                    GoalsView()
                } label: {
                    Text("편집")
                        .font(.subheadline)
                        .foregroundStyle(.pink)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.goals.filter { $0.isEnabled }) { goal in
                    GoalProgressRow(goal: goal)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 주간 활동 섹션
    private var weeklyActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("주간 걸음 수")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            if viewModel.isLoadingSteps {
                ProgressView()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else if viewModel.weeklySteps.isEmpty {
                Text("데이터가 없습니다")
                    .foregroundStyle(.secondary)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else {
                WeeklyStepsChart(data: viewModel.weeklySteps)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 최근 운동 섹션
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("최근 운동")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                NavigationLink {
                    WorkoutView()
                } label: {
                    Text("전체 보기")
                        .font(.subheadline)
                        .foregroundStyle(.pink)
                }
            }
            
            if viewModel.workouts.isEmpty {
                Text("최근 운동 기록이 없습니다")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.workouts.prefix(3)) { workout in
                        WorkoutRow(workout: workout)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 요약 카드
/// 건강 데이터를 요약하여 보여주는 카드 컴포넌트
struct SummaryCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 목표 진행 행
/// 개별 목표의 진행 상황을 보여주는 행
struct GoalProgressRow: View {
    let goal: HealthGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: goal.type.icon)
                    .foregroundStyle(.pink)
                
                Text(goal.type.rawValue)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(goal.formattedCurrentValue) / \(goal.formattedTargetValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // 진행 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.pink.opacity(0.2))
                        .frame(height: 8)
                    
                    Rectangle()
                        .fill(goal.isCompleted ? Color.green : Color.pink)
                        .frame(width: geometry.size.width * goal.progress, height: 8)
                }
                .clipShape(Capsule())
            }
            .frame(height: 8)
        }
    }
}

// MARK: - 주간 걸음 수 차트
/// 주간 걸음 수를 막대 그래프로 표시
struct WeeklyStepsChart: View {
    let data: [StepData]
    
    private var maxSteps: Int {
        data.map { $0.count }.max() ?? 10000
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(data) { step in
                VStack(spacing: 4) {
                    // 막대
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue.gradient)
                        .frame(height: CGFloat(step.count) / CGFloat(maxSteps) * 120)
                    
                    // 요일
                    Text(step.weekday)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 150)
    }
}

// MARK: - 운동 행
/// 운동 기록을 표시하는 행
struct WorkoutRow: View {
    let workout: WorkoutData
    
    var body: some View {
        HStack(spacing: 12) {
            // 운동 아이콘
            Image(systemName: workout.type.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.orange.gradient)
                .clipShape(Circle())
            
            // 운동 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(workout.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 통계
            VStack(alignment: .trailing, spacing: 4) {
                Text(workout.formattedDuration)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(Int(workout.calories)) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 프리뷰
#Preview {
    DashboardView()
        .environmentObject(HealthViewModel())
}
