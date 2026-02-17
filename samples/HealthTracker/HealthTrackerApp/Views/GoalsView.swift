import SwiftUI

// MARK: - 목표 설정 뷰
/// 건강 목표를 설정하고 관리하는 뷰
struct GoalsView: View {
    @EnvironmentObject var viewModel: HealthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var editingGoal: HealthGoal?
    
    var body: some View {
        NavigationStack {
            List {
                // 활성화된 목표 섹션
                Section {
                    ForEach(viewModel.goals.filter { $0.isEnabled }) { goal in
                        GoalRow(goal: goal) {
                            editingGoal = goal
                        }
                    }
                } header: {
                    Text("활성 목표")
                } footer: {
                    Text("매일 자정에 목표가 초기화됩니다")
                }
                
                // 비활성화된 목표 섹션
                let inactiveGoals = viewModel.goals.filter { !$0.isEnabled }
                if !inactiveGoals.isEmpty {
                    Section("비활성 목표") {
                        ForEach(inactiveGoals) { goal in
                            GoalRow(goal: goal) {
                                editingGoal = goal
                            }
                        }
                    }
                }
                
                // 목표 팁 섹션
                Section {
                    GoalTipCard()
                }
            }
            .navigationTitle("목표 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $editingGoal) { goal in
                EditGoalView(goal: goal)
            }
        }
    }
}

// MARK: - 목표 행
/// 개별 목표를 표시하는 행
struct GoalRow: View {
    let goal: HealthGoal
    let onEdit: () -> Void
    @EnvironmentObject var viewModel: HealthViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // 아이콘
            Image(systemName: goal.type.icon)
                .font(.title2)
                .foregroundStyle(goal.isEnabled ? .pink : .secondary)
                .frame(width: 44, height: 44)
                .background(goal.isEnabled ? Color.pink.opacity(0.1) : Color(.systemGray5))
                .clipShape(Circle())
            
            // 목표 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.type.rawValue)
                    .font(.headline)
                    .foregroundStyle(goal.isEnabled ? .primary : .secondary)
                
                HStack(spacing: 4) {
                    Text("목표:")
                        .foregroundStyle(.secondary)
                    Text(goal.formattedTargetValue)
                        .fontWeight(.medium)
                        .foregroundStyle(goal.isEnabled ? .pink : .secondary)
                }
                .font(.subheadline)
                
                // 진행 상황 (활성화된 경우만)
                if goal.isEnabled {
                    ProgressView(value: goal.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: goal.isCompleted ? .green : .pink))
                }
            }
            
            Spacer()
            
            // 토글 및 편집
            VStack(spacing: 8) {
                Toggle("", isOn: Binding(
                    get: { goal.isEnabled },
                    set: { _ in viewModel.toggleGoal(goal) }
                ))
                .labelsHidden()
                .tint(.pink)
                
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil.circle")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 목표 편집 뷰
/// 개별 목표를 편집하는 시트 뷰
struct EditGoalView: View {
    @EnvironmentObject var viewModel: HealthViewModel
    @Environment(\.dismiss) private var dismiss
    
    let goal: HealthGoal
    @State private var targetValue: Double
    
    init(goal: HealthGoal) {
        self.goal = goal
        self._targetValue = State(initialValue: goal.targetValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 목표 정보
                Section {
                    HStack {
                        Image(systemName: goal.type.icon)
                            .font(.title2)
                            .foregroundStyle(.pink)
                        
                        Text(goal.type.rawValue)
                            .font(.headline)
                    }
                }
                
                // 목표 값 설정
                Section("목표 값") {
                    HStack {
                        TextField("목표", value: $targetValue, format: .number)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(goal.type.unit)
                            .foregroundStyle(.secondary)
                    }
                    
                    // 빠른 선택
                    VStack(alignment: .leading, spacing: 12) {
                        Text("추천 목표")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 8) {
                            ForEach(suggestedValues, id: \.self) { value in
                                Button {
                                    targetValue = value
                                } label: {
                                    Text(formatValue(value))
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(targetValue == value ? Color.pink : Color(.systemGray5))
                                        .foregroundStyle(targetValue == value ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                // 현재 진행 상황
                Section("현재 진행 상황") {
                    HStack {
                        Text("현재 달성")
                        Spacer()
                        Text(goal.formattedCurrentValue)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("달성률")
                        Spacer()
                        Text("\(Int(calculateProgress() * 100))%")
                            .foregroundStyle(calculateProgress() >= 1.0 ? .green : .pink)
                    }
                    
                    // 진행 바
                    ProgressView(value: calculateProgress())
                        .progressViewStyle(LinearProgressViewStyle(tint: calculateProgress() >= 1.0 ? .green : .pink))
                }
                
                // 팁
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                            Text("팁")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Text(tipForGoalType)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("목표 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveGoal()
                    }
                }
            }
        }
    }
    
    /// 추천 목표 값
    private var suggestedValues: [Double] {
        switch goal.type {
        case .steps:
            return [5000, 8000, 10000, 15000]
        case .calories:
            return [200, 300, 500, 800]
        case .exerciseMinutes:
            return [20, 30, 45, 60]
        case .sleepHours:
            return [6, 7, 8, 9]
        case .distance:
            return [3, 5, 8, 10]
        }
    }
    
    /// 목표 유형별 팁
    private var tipForGoalType: String {
        switch goal.type {
        case .steps:
            return "하루 10,000걸음은 건강한 성인의 일반적인 목표입니다. 처음에는 낮게 시작해서 점차 늘려가세요."
        case .calories:
            return "개인의 체중과 활동량에 따라 적절한 칼로리 목표가 다릅니다. 꾸준히 활동하는 것이 중요합니다."
        case .exerciseMinutes:
            return "WHO는 주당 150분의 중강도 운동을 권장합니다. 하루 30분씩 5일이면 충분합니다."
        case .sleepHours:
            return "성인은 7-9시간의 수면이 권장됩니다. 규칙적인 수면 시간이 중요합니다."
        case .distance:
            return "걷기나 달리기로 이동한 거리입니다. 매일 조금씩 늘려가는 것이 좋습니다."
        }
    }
    
    /// 값 포맷
    private func formatValue(_ value: Double) -> String {
        switch goal.type {
        case .steps:
            return "\(Int(value / 1000))k"
        case .sleepHours, .distance:
            return String(format: "%.0f", value)
        default:
            return "\(Int(value))"
        }
    }
    
    /// 현재 진행률 계산
    private func calculateProgress() -> Double {
        guard targetValue > 0 else { return 0 }
        return min(goal.currentValue / targetValue, 1.0)
    }
    
    /// 목표 저장
    private func saveGoal() {
        viewModel.updateGoal(goal, targetValue: targetValue)
        dismiss()
    }
}

// MARK: - 목표 팁 카드
/// 목표 설정에 대한 팁을 보여주는 카드
struct GoalTipCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("좋은 목표 설정하기")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TipItem(text: "현실적인 목표부터 시작하세요")
                TipItem(text: "작은 성공이 동기부여가 됩니다")
                TipItem(text: "점진적으로 목표를 높여가세요")
                TipItem(text: "일관성이 강도보다 중요합니다")
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 팁 아이템
struct TipItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 프리뷰
#Preview {
    GoalsView()
        .environmentObject(HealthViewModel())
}

#Preview("목표 편집") {
    let goal = HealthGoal(type: .steps, targetValue: 10000, currentValue: 5000)
    EditGoalView(goal: goal)
        .environmentObject(HealthViewModel())
}
