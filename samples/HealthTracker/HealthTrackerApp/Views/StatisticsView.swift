import SwiftUI

// MARK: - 통계 뷰
/// 건강 데이터의 주간/월간/연간 통계를 보여주는 뷰
struct StatisticsView: View {
    @EnvironmentObject var viewModel: HealthViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 기간 선택
                    periodSelector
                    
                    // 로딩 또는 콘텐츠
                    if viewModel.isLoadingStatistics {
                        loadingView
                    } else if let stats = viewModel.statisticsData {
                        // 걸음 수 통계
                        stepsStatisticsSection(stats)
                        
                        // 심박수 통계
                        heartRateStatisticsSection(stats)
                        
                        // 수면 통계
                        sleepStatisticsSection(stats)
                        
                        // 운동 통계
                        workoutStatisticsSection(stats)
                    } else {
                        emptyView
                    }
                }
                .padding()
            }
            .navigationTitle("통계")
            .task {
                await viewModel.loadStatistics()
            }
            .onChange(of: viewModel.statisticsPeriod) { _, _ in
                Task {
                    await viewModel.loadStatistics()
                }
            }
        }
    }
    
    // MARK: - 기간 선택기
    private var periodSelector: some View {
        Picker("기간", selection: $viewModel.statisticsPeriod) {
            ForEach(StatisticsPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - 로딩 뷰
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("통계를 불러오는 중...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
    }
    
    // MARK: - 빈 상태 뷰
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("통계 데이터가 없습니다")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("건강 데이터를 수집하면\n여기에 통계가 표시됩니다")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
    }
    
    // MARK: - 걸음 수 통계 섹션
    private func stepsStatisticsSection(_ stats: StatisticsData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            StatisticsSectionHeader(icon: "figure.walk", title: "걸음 수", color: .blue)
            
            // 주요 지표
            HStack(spacing: 0) {
                StatisticsMetric(
                    title: "총 걸음 수",
                    value: "\(stats.totalSteps.formatted())",
                    color: .blue
                )
                
                Divider().frame(height: 50)
                
                StatisticsMetric(
                    title: "일 평균",
                    value: "\(stats.averageSteps.formatted())",
                    color: .cyan
                )
            }
            
            // 걸음 수 차트
            if !stats.steps.isEmpty {
                StepsStatisticsChart(data: stats.steps, period: stats.period)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 심박수 통계 섹션
    private func heartRateStatisticsSection(_ stats: StatisticsData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            StatisticsSectionHeader(icon: "heart.fill", title: "심박수", color: .pink)
            
            let heartRateStats = calculateHeartRateStats(stats.heartRates)
            
            // 주요 지표
            HStack(spacing: 0) {
                StatisticsMetric(
                    title: "최저",
                    value: "\(Int(heartRateStats.min)) BPM",
                    color: .blue
                )
                
                Divider().frame(height: 50)
                
                StatisticsMetric(
                    title: "평균",
                    value: "\(Int(heartRateStats.avg)) BPM",
                    color: .green
                )
                
                Divider().frame(height: 50)
                
                StatisticsMetric(
                    title: "최고",
                    value: "\(Int(heartRateStats.max)) BPM",
                    color: .red
                )
            }
            
            // 심박수 분포
            if !stats.heartRates.isEmpty {
                HeartRateDistributionChart(data: stats.heartRates)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 수면 통계 섹션
    private func sleepStatisticsSection(_ stats: StatisticsData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            StatisticsSectionHeader(icon: "moon.fill", title: "수면", color: .indigo)
            
            let avgSleepHours = Double(stats.totalSleepMinutes) / Double(max(stats.period.days, 1)) / 60.0
            
            // 주요 지표
            HStack(spacing: 0) {
                StatisticsMetric(
                    title: "총 수면",
                    value: formatMinutes(stats.totalSleepMinutes),
                    color: .indigo
                )
                
                Divider().frame(height: 50)
                
                StatisticsMetric(
                    title: "일 평균",
                    value: String(format: "%.1f시간", avgSleepHours),
                    color: .purple
                )
            }
            
            // 수면 구성 분포
            if !stats.sleepData.isEmpty {
                SleepDistributionChart(data: stats.sleepData)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 운동 통계 섹션
    private func workoutStatisticsSection(_ stats: StatisticsData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            StatisticsSectionHeader(icon: "flame.fill", title: "운동", color: .orange)
            
            // 주요 지표
            HStack(spacing: 0) {
                StatisticsMetric(
                    title: "운동 횟수",
                    value: "\(stats.workouts.count)회",
                    color: .orange
                )
                
                Divider().frame(height: 50)
                
                StatisticsMetric(
                    title: "총 시간",
                    value: "\(stats.totalWorkoutMinutes)분",
                    color: .red
                )
                
                Divider().frame(height: 50)
                
                StatisticsMetric(
                    title: "총 칼로리",
                    value: "\(Int(stats.totalWorkoutCalories)) kcal",
                    color: .yellow
                )
            }
            
            // 운동 유형별 분포
            if !stats.workouts.isEmpty {
                WorkoutTypeDistributionChart(workouts: stats.workouts)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 헬퍼 메서드
    
    private func calculateHeartRateStats(_ data: [HeartRateData]) -> (min: Double, max: Double, avg: Double) {
        guard !data.isEmpty else { return (0, 0, 0) }
        let bpms = data.map { $0.bpm }
        return (bpms.min() ?? 0, bpms.max() ?? 0, bpms.reduce(0, +) / Double(bpms.count))
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)시간 \(mins)분"
        }
        return "\(mins)분"
    }
}

// MARK: - 통계 섹션 헤더
struct StatisticsSectionHeader: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
        }
    }
}

// MARK: - 통계 지표
struct StatisticsMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 걸음 수 통계 차트
struct StepsStatisticsChart: View {
    let data: [StepData]
    let period: StatisticsPeriod
    
    private var maxSteps: Int {
        max(data.map { $0.count }.max() ?? 1, 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("일별 걸음 수")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // 간소화된 막대 차트
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(data.prefix(period == .week ? 7 : 30)) { step in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue.gradient)
                        .frame(height: CGFloat(step.count) / CGFloat(maxSteps) * 80)
                }
            }
            .frame(height: 100)
        }
    }
}

// MARK: - 심박수 분포 차트
struct HeartRateDistributionChart: View {
    let data: [HeartRateData]
    
    private var distribution: [HeartRateStatus: Int] {
        var result: [HeartRateStatus: Int] = [:]
        for heartRate in data {
            result[heartRate.status, default: 0] += 1
        }
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("심박수 분포")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                ForEach([HeartRateStatus.low, .normal, .elevated, .high], id: \.self) { status in
                    let count = distribution[status] ?? 0
                    let percentage = data.isEmpty ? 0 : Double(count) / Double(data.count) * 100
                    
                    VStack(spacing: 4) {
                        Text("\(Int(percentage))%")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(colorForStatus(status))
                            .frame(height: percentage)
                        
                        Text(status.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)
        }
    }
    
    private func colorForStatus(_ status: HeartRateStatus) -> Color {
        switch status {
        case .low: return .blue
        case .normal: return .green
        case .elevated: return .orange
        case .high: return .red
        }
    }
}

// MARK: - 수면 분포 차트
struct SleepDistributionChart: View {
    let data: [SleepData]
    
    private var totalMinutes: Int {
        data.reduce(0) { $0 + $1.durationMinutes }
    }
    
    private var distribution: [(category: SleepCategory, minutes: Int, percentage: Double)] {
        var byCategory: [SleepCategory: Int] = [:]
        for sleep in data {
            byCategory[sleep.category, default: 0] += sleep.durationMinutes
        }
        
        return byCategory.map { category, minutes in
            let percentage = Double(minutes) / Double(max(totalMinutes, 1)) * 100
            return (category, minutes, percentage)
        }.sorted { $0.minutes > $1.minutes }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("수면 구성")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ForEach(distribution, id: \.category) { item in
                HStack {
                    Circle()
                        .fill(colorForCategory(item.category))
                        .frame(width: 10, height: 10)
                    
                    Text(item.category.rawValue)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text(String(format: "%.1f%%", item.percentage))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func colorForCategory(_ category: SleepCategory) -> Color {
        switch category {
        case .inBed: return .gray
        case .asleepUnspecified: return .blue
        case .awake: return .yellow
        case .asleepCore: return .indigo
        case .asleepDeep: return .purple
        case .asleepREM: return .cyan
        }
    }
}

// MARK: - 운동 유형 분포 차트
struct WorkoutTypeDistributionChart: View {
    let workouts: [WorkoutData]
    
    private var distribution: [(type: WorkoutType, count: Int)] {
        var byType: [WorkoutType: Int] = [:]
        for workout in workouts {
            byType[workout.type, default: 0] += 1
        }
        return byType.map { ($0.key, $0.value) }.sorted { $0.count > $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("운동 유형별 분포")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ForEach(distribution, id: \.type) { item in
                HStack {
                    Image(systemName: item.type.icon)
                        .foregroundStyle(.orange)
                        .frame(width: 20)
                    
                    Text(item.type.rawValue)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("\(item.count)회")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // 막대
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.orange.gradient)
                        .frame(width: CGFloat(item.count) / CGFloat(max(workouts.count, 1)) * 60, height: 8)
                }
            }
        }
    }
}

// MARK: - 프리뷰
#Preview {
    StatisticsView()
        .environmentObject(HealthViewModel())
}
