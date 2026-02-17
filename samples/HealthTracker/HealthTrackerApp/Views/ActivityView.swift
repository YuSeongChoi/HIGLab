import SwiftUI

// MARK: - 활동 뷰
/// 걸음 수, 심박수 등 활동 데이터를 상세히 보여주는 뷰
struct ActivityView: View {
    @EnvironmentObject var viewModel: HealthViewModel
    @State private var selectedTab: ActivityTab = .steps
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 탭 선택기
                Picker("활동 유형", selection: $selectedTab) {
                    ForEach(ActivityTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 선택된 탭에 따른 콘텐츠
                TabView(selection: $selectedTab) {
                    StepsDetailView()
                        .tag(ActivityTab.steps)
                    
                    HeartRateDetailView()
                        .tag(ActivityTab.heartRate)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("활동")
            .refreshable {
                await viewModel.loadTodayData()
                await viewModel.loadWeeklySteps()
                await viewModel.loadHeartRateData()
            }
        }
    }
}

// MARK: - 활동 탭 열거형
enum ActivityTab: String, CaseIterable, Identifiable {
    case steps = "걸음 수"
    case heartRate = "심박수"
    
    var id: String { rawValue }
}

// MARK: - 걸음 수 상세 뷰
/// 걸음 수 데이터를 상세히 보여주는 뷰
struct StepsDetailView: View {
    @EnvironmentObject var viewModel: HealthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 오늘의 걸음 수 하이라이트
                todayStepsCard
                
                // 주간 차트
                weeklyChartSection
                
                // 일별 상세 리스트
                dailyListSection
            }
            .padding()
        }
    }
    
    // MARK: - 오늘의 걸음 수 카드
    private var todayStepsCard: some View {
        VStack(spacing: 16) {
            // 큰 숫자
            Text(viewModel.formattedTodaySteps)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)
            
            Text("오늘 걸음")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            // 목표 대비 진행률
            if let stepsGoal = viewModel.goals.first(where: { $0.type == .steps && $0.isEnabled }) {
                VStack(spacing: 8) {
                    ProgressView(value: stepsGoal.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    
                    Text("목표: \(stepsGoal.formattedTargetValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 40)
            }
            
            // 추가 정보
            HStack(spacing: 30) {
                VStack {
                    Image(systemName: "map.fill")
                        .foregroundStyle(.green)
                    Text(viewModel.formattedTodayDistance)
                        .font(.headline)
                    Text("거리")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                    .frame(height: 50)
                
                VStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text(viewModel.formattedTodayCalories)
                        .font(.headline)
                    Text("칼로리")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 주간 차트 섹션
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("주간 추이")
                .font(.headline)
            
            if viewModel.isLoadingSteps {
                ProgressView()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else {
                StepsBarChart(data: viewModel.weeklySteps)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 일별 리스트 섹션
    private var dailyListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("일별 기록")
                .font(.headline)
            
            ForEach(viewModel.weeklySteps.reversed()) { step in
                HStack {
                    VStack(alignment: .leading) {
                        Text(step.formattedDate)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(step.weekday)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(step.count.formatted()) 걸음")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 8)
                
                if step.id != viewModel.weeklySteps.first?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - 걸음 수 막대 차트
/// 걸음 수를 막대 그래프로 시각화
struct StepsBarChart: View {
    let data: [StepData]
    
    private var maxSteps: Int {
        max(data.map { $0.count }.max() ?? 10000, 1)
    }
    
    private var averageSteps: Int {
        guard !data.isEmpty else { return 0 }
        return data.reduce(0) { $0 + $1.count } / data.count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 평균 라인
            HStack {
                Text("평균")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(averageSteps.formatted()) 걸음")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            // 차트
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(data) { step in
                    VStack(spacing: 8) {
                        // 숫자 (천 단위)
                        Text("\(step.count / 1000)k")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        // 막대
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: CGFloat(step.count) / CGFloat(maxSteps) * 150)
                        
                        // 요일
                        Text(step.weekday)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 200)
        }
    }
}

// MARK: - 심박수 상세 뷰
/// 심박수 데이터를 상세히 보여주는 뷰
struct HeartRateDetailView: View {
    @EnvironmentObject var viewModel: HealthViewModel
    
    private var heartRateStats: (min: Double, max: Double, avg: Double) {
        guard !viewModel.heartRateData.isEmpty else { return (0, 0, 0) }
        let bpms = viewModel.heartRateData.map { $0.bpm }
        let min = bpms.min() ?? 0
        let max = bpms.max() ?? 0
        let avg = bpms.reduce(0, +) / Double(bpms.count)
        return (min, max, avg)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 현재 심박수
                currentHeartRateCard
                
                // 통계
                heartRateStatsCard
                
                // 24시간 그래프
                heartRateChartSection
                
                // 최근 기록 리스트
                recentHeartRateList
            }
            .padding()
        }
    }
    
    // MARK: - 현재 심박수 카드
    private var currentHeartRateCard: some View {
        VStack(spacing: 16) {
            // 애니메이션 하트 아이콘
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundStyle(.pink)
                .symbolEffect(.pulse)
            
            if let latest = viewModel.latestHeartRate {
                Text("\(Int(latest.bpm))")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.pink)
                
                Text("BPM")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text(latest.status.rawValue)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(colorForStatus(latest.status).opacity(0.2))
                        .foregroundStyle(colorForStatus(latest.status))
                        .clipShape(Capsule())
                    
                    Text("• \(latest.formattedTime)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("-- BPM")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.secondary)
                
                Text("측정된 데이터 없음")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 심박수 통계 카드
    private var heartRateStatsCard: some View {
        HStack(spacing: 0) {
            StatBox(title: "최저", value: "\(Int(heartRateStats.min))", unit: "BPM", color: .blue)
            Divider().frame(height: 50)
            StatBox(title: "평균", value: "\(Int(heartRateStats.avg))", unit: "BPM", color: .green)
            Divider().frame(height: 50)
            StatBox(title: "최고", value: "\(Int(heartRateStats.max))", unit: "BPM", color: .red)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 심박수 차트 섹션
    private var heartRateChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("24시간 추이")
                .font(.headline)
            
            if viewModel.isLoadingHeartRate {
                ProgressView()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else if viewModel.heartRateData.isEmpty {
                Text("데이터가 없습니다")
                    .foregroundStyle(.secondary)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else {
                HeartRateLineChart(data: viewModel.heartRateData)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 최근 심박수 리스트
    private var recentHeartRateList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("최근 기록")
                .font(.headline)
            
            ForEach(viewModel.heartRateData.suffix(10).reversed()) { data in
                HStack {
                    Circle()
                        .fill(colorForStatus(data.status))
                        .frame(width: 8, height: 8)
                    
                    Text(data.formattedTime)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(Int(data.bpm)) BPM")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.pink)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    /// 상태에 따른 색상 반환
    private func colorForStatus(_ status: HeartRateStatus) -> Color {
        switch status {
        case .low: return .blue
        case .normal: return .green
        case .elevated: return .orange
        case .high: return .red
        }
    }
}

// MARK: - 통계 박스
/// 통계 값을 표시하는 작은 박스
struct StatBox: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 심박수 라인 차트
/// 심박수 데이터를 라인 차트로 시각화
struct HeartRateLineChart: View {
    let data: [HeartRateData]
    
    private var minBPM: Double {
        (data.map { $0.bpm }.min() ?? 40) - 10
    }
    
    private var maxBPM: Double {
        (data.map { $0.bpm }.max() ?? 180) + 10
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let stepX = width / CGFloat(max(data.count - 1, 1))
            
            Path { path in
                for (index, heartRate) in data.enumerated() {
                    let x = CGFloat(index) * stepX
                    let normalizedBPM = (heartRate.bpm - minBPM) / (maxBPM - minBPM)
                    let y = height - (CGFloat(normalizedBPM) * height)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                LinearGradient(
                    colors: [.pink, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
        }
        .frame(height: 150)
    }
}

// MARK: - 프리뷰
#Preview {
    ActivityView()
        .environmentObject(HealthViewModel())
}
