import SwiftUI

// MARK: - 수면 뷰
/// 수면 데이터를 분석하고 표시하는 뷰
struct SleepView: View {
    @EnvironmentObject var viewModel: HealthViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 지난 밤 수면 요약
                    lastNightSummary
                    
                    // 수면 구성
                    sleepCompositionSection
                    
                    // 주간 수면 추이
                    weeklySleepSection
                    
                    // 수면 팁
                    sleepTipsSection
                }
                .padding()
            }
            .navigationTitle("수면")
            .refreshable {
                await viewModel.loadSleepData()
                await viewModel.loadTodayData()
            }
        }
    }
    
    // MARK: - 지난 밤 수면 요약
    private var lastNightSummary: some View {
        VStack(spacing: 20) {
            // 수면 아이콘
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 50))
                .foregroundStyle(.indigo)
            
            // 수면 시간
            Text(viewModel.formattedLastNightSleep)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.indigo)
            
            Text("지난 밤 수면")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            // 수면 품질
            HStack(spacing: 16) {
                QualityBadge(
                    title: "품질",
                    value: viewModel.lastNightSleepQuality,
                    color: qualityColor(viewModel.lastNightSleepQuality)
                )
                
                if let sleepGoal = viewModel.goals.first(where: { $0.type == .sleepHours && $0.isEnabled }) {
                    QualityBadge(
                        title: "목표 달성",
                        value: "\(Int(sleepGoal.progress * 100))%",
                        color: sleepGoal.isCompleted ? .green : .orange
                    )
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.indigo.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 수면 구성 섹션
    private var sleepCompositionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("수면 구성")
                .font(.headline)
            
            if viewModel.isLoadingSleep {
                ProgressView()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else if viewModel.sleepData.isEmpty {
                EmptyStateView(
                    icon: "moon.fill",
                    message: "수면 데이터가 없습니다",
                    description: "Apple Watch를 착용하고 주무시면\n수면 데이터가 자동으로 기록됩니다"
                )
            } else {
                // 수면 단계별 시간
                let sleepByCategory = groupSleepByCategory(viewModel.sleepData)
                
                VStack(spacing: 12) {
                    ForEach(SleepCategory.allCases, id: \.self) { category in
                        let minutes = sleepByCategory[category] ?? 0
                        if minutes > 0 {
                            SleepCategoryRow(category: category, minutes: minutes)
                        }
                    }
                }
                
                // 수면 구성 차트
                SleepCompositionChart(data: sleepByCategory)
                    .frame(height: 24)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 주간 수면 섹션
    private var weeklySleepSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("주간 수면")
                .font(.headline)
            
            if viewModel.sleepData.isEmpty {
                Text("데이터가 없습니다")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                // 일별 수면 시간 계산
                let dailySleep = calculateDailySleep()
                
                WeeklySleepChart(data: dailySleep)
                
                // 평균 수면 시간
                if !dailySleep.isEmpty {
                    let avgMinutes = dailySleep.reduce(0) { $0 + $1.minutes } / dailySleep.count
                    HStack {
                        Text("평균 수면")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(formatMinutes(avgMinutes))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 수면 팁 섹션
    private var sleepTipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("수면 팁")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                SleepTipRow(tip: "매일 같은 시간에 잠자리에 드세요")
                SleepTipRow(tip: "잠들기 1시간 전에는 화면을 보지 마세요")
                SleepTipRow(tip: "카페인은 오후 2시 이전에만 섭취하세요")
                SleepTipRow(tip: "침실 온도는 18-22°C가 적당합니다")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - 헬퍼 메서드
    
    /// 수면 품질에 따른 색상
    private func qualityColor(_ quality: String) -> Color {
        switch quality {
        case "좋음": return .green
        case "보통": return .yellow
        default: return .orange
        }
    }
    
    /// 수면 데이터를 카테고리별로 그룹화
    private func groupSleepByCategory(_ data: [SleepData]) -> [SleepCategory: Int] {
        var result: [SleepCategory: Int] = [:]
        for sleep in data {
            result[sleep.category, default: 0] += sleep.durationMinutes
        }
        return result
    }
    
    /// 일별 수면 시간 계산
    private func calculateDailySleep() -> [(date: Date, minutes: Int)] {
        let calendar = Calendar.current
        var dailySleep: [Date: Int] = [:]
        
        for sleep in viewModel.sleepData {
            // 실제 수면만 계산 (침대에 있음, 깨어있음 제외)
            guard sleep.category != .inBed && sleep.category != .awake else { continue }
            
            let day = calendar.startOfDay(for: sleep.startDate)
            dailySleep[day, default: 0] += sleep.durationMinutes
        }
        
        return dailySleep
            .sorted { $0.key < $1.key }
            .map { (date: $0.key, minutes: $0.value) }
    }
    
    /// 분을 시간:분 형식으로 변환
    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)시간 \(mins)분"
    }
}

// MARK: - 품질 배지
/// 수면 품질을 표시하는 배지
struct QualityBadge: View {
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
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - 수면 카테고리 행
/// 수면 카테고리별 시간을 표시하는 행
struct SleepCategoryRow: View {
    let category: SleepCategory
    let minutes: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(colorForCategory(category))
                .frame(width: 12, height: 12)
            
            Text(category.rawValue)
                .font(.subheadline)
            
            Spacer()
            
            Text(formatMinutes(minutes))
                .font(.subheadline)
                .foregroundStyle(.secondary)
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
    
    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)시간 \(mins)분"
        }
        return "\(mins)분"
    }
}

// MARK: - 수면 구성 차트
/// 수면 구성을 가로 막대 차트로 표시
struct SleepCompositionChart: View {
    let data: [SleepCategory: Int]
    
    private var totalMinutes: Int {
        data.values.reduce(0, +)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(SleepCategory.allCases, id: \.self) { category in
                    if let minutes = data[category], minutes > 0 {
                        let width = CGFloat(minutes) / CGFloat(max(totalMinutes, 1)) * geometry.size.width
                        Rectangle()
                            .fill(colorForCategory(category))
                            .frame(width: max(width, 4))
                    }
                }
            }
            .clipShape(Capsule())
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

// MARK: - 주간 수면 차트
/// 주간 수면 시간을 막대 그래프로 표시
struct WeeklySleepChart: View {
    let data: [(date: Date, minutes: Int)]
    
    private var maxMinutes: Int {
        max(data.map { $0.minutes }.max() ?? 480, 1)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(data.indices, id: \.self) { index in
                let item = data[index]
                VStack(spacing: 8) {
                    // 시간 표시
                    Text("\(item.minutes / 60)h")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    // 막대
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.indigo, .purple],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: CGFloat(item.minutes) / CGFloat(maxMinutes) * 120)
                    
                    // 요일
                    Text(weekday(from: item.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 180)
    }
    
    private func weekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// MARK: - 빈 상태 뷰
/// 데이터가 없을 때 표시하는 뷰
struct EmptyStateView: View {
    let icon: String
    let message: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - 수면 팁 행
/// 수면 팁을 표시하는 행
struct SleepTipRow: View {
    let tip: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.indigo)
                .font(.subheadline)
            
            Text(tip)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 프리뷰
#Preview {
    SleepView()
        .environmentObject(HealthViewModel())
}
