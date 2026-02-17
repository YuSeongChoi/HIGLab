// ChargingScheduleView.swift
// GreenCharge - 충전 스케줄 화면
// iOS 26 EnergyKit 활용

import SwiftUI

// MARK: - 충전 스케줄 뷰

/// 충전 일정 관리 및 추천 화면
struct ChargingScheduleView: View {
    
    // MARK: - 환경 객체
    
    @Environment(EnergyService.self) private var energyService
    
    // MARK: - 상태
    
    /// 충전 일정 목록
    @State private var schedules: [ChargingSchedule] = []
    
    /// 추천 목록
    @State private var recommendations: [ChargingRecommendation] = []
    
    /// 새 일정 추가 시트 표시
    @State private var showingAddSchedule = false
    
    /// 편집 중인 일정
    @State private var editingSchedule: ChargingSchedule?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 오늘의 추천
                    todayRecommendations
                    
                    // 내 충전 일정
                    mySchedules
                    
                    // 다음 최적 시간대
                    nextOptimalPeriod
                }
                .padding()
            }
            .navigationTitle("충전 스케줄")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSchedule = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSchedule) {
                AddScheduleSheet(schedules: $schedules)
            }
            .sheet(item: $editingSchedule) { schedule in
                EditScheduleSheet(schedule: schedule, schedules: $schedules)
            }
            .task {
                loadRecommendations()
            }
        }
    }
    
    // MARK: - 컴포넌트
    
    /// 오늘의 충전 추천
    private var todayRecommendations: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("오늘의 추천 충전 시간")
                    .font(.headline)
                
                Spacer()
                
                Button("자세히") {
                    // 상세 보기
                }
                .font(.caption)
            }
            
            if recommendations.isEmpty {
                // 추천 없음
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    
                    Text("추천할 충전 시간이 없습니다")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                // 추천 목록
                ForEach(recommendations.prefix(3)) { recommendation in
                    RecommendationCard(recommendation: recommendation)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// 내 충전 일정
    private var mySchedules: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("내 충전 일정")
                    .font(.headline)
                
                Spacer()
                
                if !schedules.isEmpty {
                    Button("편집") {
                        // 편집 모드
                    }
                    .font(.caption)
                }
            }
            
            if schedules.isEmpty {
                // 일정 없음
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    
                    Text("충전 일정을 추가하세요")
                        .font(.subheadline)
                    
                    Text("기기별 충전 일정을 설정하면\n최적의 충전 시간을 추천해드립니다")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        showingAddSchedule = true
                    } label: {
                        Label("일정 추가", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                // 일정 목록
                ForEach(schedules) { schedule in
                    ScheduleRow(schedule: schedule) {
                        editingSchedule = schedule
                    } onToggle: { isEnabled in
                        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
                            schedules[index].isEnabled = isEnabled
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// 다음 최적 충전 시간대
    private var nextOptimalPeriod: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("다음 최적 충전 시간")
                .font(.headline)
            
            if let nextOptimal = energyService.nextOptimalChargingTime {
                HStack(spacing: 16) {
                    // 시간 표시
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatTime(nextOptimal.startTime))
                            .font(.title2.bold())
                        
                        Text("~\(formatTime(nextOptimal.endTime))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // 청정도 표시
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(nextOptimal.cleanEnergyPercentage * 100))%")
                            .font(.title.bold())
                            .foregroundStyle(.green)
                        
                        Text("청정 에너지")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 남은 시간
                if let remaining = remainingTime(until: nextOptimal.startTime) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.orange)
                        
                        Text(remaining)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Button("알림 설정") {
                            // 알림 설정
                        }
                        .font(.caption)
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)
                }
            } else {
                Text("예보 데이터를 불러오는 중...")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 메서드
    
    /// 추천 목록 로드
    private func loadRecommendations() {
        guard let forecasts = energyService.dailyForecasts.first?.hourlyForecasts else { return }
        
        // 기본 충전 일정으로 추천 생성
        let defaultSchedule = ChargingSchedule(
            deviceName: "기본",
            targetChargeLevel: 80,
            estimatedDuration: 3600
        )
        
        recommendations = ChargingRecommendationGenerator.generateRecommendations(
            from: forecasts,
            for: defaultSchedule
        )
    }
    
    /// 시간 포맷
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h시 mm분"
        return formatter.string(from: date)
    }
    
    /// 남은 시간 계산
    private func remainingTime(until date: Date) -> String? {
        let now = Date()
        guard date > now else { return nil }
        
        let interval = date.timeIntervalSince(now)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분 후"
        } else {
            return "\(minutes)분 후"
        }
    }
}

// MARK: - 추천 카드

/// 충전 추천 카드 컴포넌트
struct RecommendationCard: View {
    let recommendation: ChargingRecommendation
    
    var body: some View {
        HStack(spacing: 12) {
            // 우선순위 표시
            VStack {
                Image(systemName: recommendation.priority.iconName)
                    .foregroundStyle(priorityColor)
                    .font(.title2)
            }
            .frame(width: 40)
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.shortTimeString)
                    .font(.headline)
                
                Text(recommendation.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 청정도
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(recommendation.estimatedCleanPercentage * 100))%")
                    .font(.title3.bold())
                    .foregroundStyle(.green)
                
                Text("청정")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(priorityColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case .high: return .green
        case .medium: return .yellow
        case .low: return .gray
        }
    }
}

// MARK: - 일정 행

/// 충전 일정 행 컴포넌트
struct ScheduleRow: View {
    let schedule: ChargingSchedule
    let onEdit: () -> Void
    let onToggle: (Bool) -> Void
    
    @State private var isEnabled: Bool
    
    init(schedule: ChargingSchedule, onEdit: @escaping () -> Void, onToggle: @escaping (Bool) -> Void) {
        self.schedule = schedule
        self.onEdit = onEdit
        self.onToggle = onToggle
        self._isEnabled = State(initialValue: schedule.isEnabled)
    }
    
    var body: some View {
        HStack {
            // 기기 아이콘
            Image(systemName: deviceIcon)
                .font(.title2)
                .foregroundStyle(isEnabled ? .green : .secondary)
                .frame(width: 40)
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(schedule.deviceName)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Text("목표: \(schedule.targetChargeLevel)%")
                    Text("·")
                    Text(schedule.durationString)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 토글
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .onChange(of: isEnabled) { _, newValue in
                    onToggle(newValue)
                }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            onEdit()
        }
    }
    
    private var deviceIcon: String {
        let name = schedule.deviceName.lowercased()
        if name.contains("iphone") || name.contains("폰") {
            return "iphone"
        } else if name.contains("ipad") || name.contains("패드") {
            return "ipad"
        } else if name.contains("watch") || name.contains("워치") {
            return "applewatch"
        } else if name.contains("mac") || name.contains("맥") {
            return "macbook"
        } else if name.contains("car") || name.contains("자동차") || name.contains("차") {
            return "car.fill"
        } else {
            return "bolt.fill"
        }
    }
}

// MARK: - 일정 추가 시트

/// 새 충전 일정 추가
struct AddScheduleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var schedules: [ChargingSchedule]
    
    @State private var deviceName = ""
    @State private var targetLevel = 80.0
    @State private var duration = 60.0  // 분
    @State private var useOptimalTiming = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("기기 정보") {
                    TextField("기기 이름", text: $deviceName)
                    
                    LabeledContent("목표 충전량") {
                        Stepper("\(Int(targetLevel))%", value: $targetLevel, in: 50...100, step: 5)
                    }
                    
                    LabeledContent("예상 충전 시간") {
                        Stepper("\(Int(duration))분", value: $duration, in: 15...480, step: 15)
                    }
                }
                
                Section {
                    Toggle("최적 시간 자동 선택", isOn: $useOptimalTiming)
                } footer: {
                    Text("활성화하면 청정 에너지 비율이 가장 높은 시간에 자동으로 충전을 시작합니다.")
                }
            }
            .navigationTitle("일정 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        addSchedule()
                        dismiss()
                    }
                    .disabled(deviceName.isEmpty)
                }
            }
        }
    }
    
    private func addSchedule() {
        let schedule = ChargingSchedule(
            deviceName: deviceName,
            targetChargeLevel: Int(targetLevel),
            estimatedDuration: duration * 60,
            useOptimalTiming: useOptimalTiming
        )
        schedules.append(schedule)
    }
}

// MARK: - 일정 편집 시트

/// 충전 일정 편집
struct EditScheduleSheet: View {
    @Environment(\.dismiss) private var dismiss
    let schedule: ChargingSchedule
    @Binding var schedules: [ChargingSchedule]
    
    @State private var deviceName: String
    @State private var targetLevel: Double
    @State private var duration: Double
    @State private var useOptimalTiming: Bool
    
    init(schedule: ChargingSchedule, schedules: Binding<[ChargingSchedule]>) {
        self.schedule = schedule
        self._schedules = schedules
        self._deviceName = State(initialValue: schedule.deviceName)
        self._targetLevel = State(initialValue: Double(schedule.targetChargeLevel))
        self._duration = State(initialValue: schedule.estimatedDuration / 60)
        self._useOptimalTiming = State(initialValue: schedule.useOptimalTiming)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("기기 정보") {
                    TextField("기기 이름", text: $deviceName)
                    
                    LabeledContent("목표 충전량") {
                        Stepper("\(Int(targetLevel))%", value: $targetLevel, in: 50...100, step: 5)
                    }
                    
                    LabeledContent("예상 충전 시간") {
                        Stepper("\(Int(duration))분", value: $duration, in: 15...480, step: 15)
                    }
                }
                
                Section {
                    Toggle("최적 시간 자동 선택", isOn: $useOptimalTiming)
                }
                
                Section {
                    Button("일정 삭제", role: .destructive) {
                        deleteSchedule()
                        dismiss()
                    }
                }
            }
            .navigationTitle("일정 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveSchedule()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveSchedule() {
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            schedules[index].deviceName = deviceName
            schedules[index].targetChargeLevel = Int(targetLevel)
            schedules[index].estimatedDuration = duration * 60
            schedules[index].useOptimalTiming = useOptimalTiming
        }
    }
    
    private func deleteSchedule() {
        schedules.removeAll { $0.id == schedule.id }
    }
}

// MARK: - 미리보기

#Preview {
    ChargingScheduleView()
        .environment(EnergyService())
}
