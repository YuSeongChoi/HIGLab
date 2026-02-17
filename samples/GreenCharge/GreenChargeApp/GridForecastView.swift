// GridForecastView.swift
// GreenCharge - 전력망 예보 화면
// iOS 26 EnergyKit 활용

import SwiftUI
import Charts

// MARK: - 전력망 예보 뷰

/// 전력망 청정 에너지 예보 메인 화면
struct GridForecastView: View {
    
    // MARK: - 환경 객체
    
    @Environment(EnergyService.self) private var energyService
    @Environment(LocationService.self) private var locationService
    
    // MARK: - 상태
    
    /// 선택된 날짜 인덱스
    @State private var selectedDayIndex = 0
    
    /// 선택된 시간대 (상세 보기용)
    @State private var selectedEntry: GridForecastEntry?
    
    /// 새로고침 중 여부
    @State private var isRefreshing = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 현재 상태 카드
                    currentStatusCard
                    
                    // 날짜 선택기
                    daySelector
                    
                    // 시간대별 예보 차트
                    forecastChart
                    
                    // 시간대별 상세 목록
                    hourlyForecastList
                    
                    // 에너지 믹스 표시
                    energyMixSection
                }
                .padding()
            }
            .navigationTitle("전력망 예보")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await refreshForecast()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .symbolEffect(.rotate, isActive: isRefreshing)
                    }
                    .disabled(isRefreshing)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    locationButton
                }
            }
            .refreshable {
                await refreshForecast()
            }
            .sheet(item: $selectedEntry) { entry in
                ForecastDetailSheet(entry: entry)
                    .presentationDetents([.medium])
            }
        }
    }
    
    // MARK: - 컴포넌트
    
    /// 현재 상태 카드
    private var currentStatusCard: some View {
        VStack(spacing: 16) {
            // 현재 청정도 표시
            if let current = energyService.currentForecast {
                HStack(spacing: 20) {
                    // 청정도 게이지
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 12)
                        
                        Circle()
                            .trim(from: 0, to: current.cleanEnergyPercentage)
                            .stroke(
                                gradeColor(for: current.cleanlinessGrade).gradient,
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 4) {
                            Text("\(Int(current.cleanEnergyPercentage * 100))%")
                                .font(.title.bold())
                            
                            Text("청정 에너지")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 120, height: 120)
                    
                    // 상세 정보
                    VStack(alignment: .leading, spacing: 12) {
                        // 등급
                        HStack {
                            Text("등급")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(current.cleanlinessGrade.rawValue)
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(gradeColor(for: current.cleanlinessGrade).opacity(0.2))
                                .clipShape(Capsule())
                        }
                        
                        // 탄소 집약도
                        HStack {
                            Text("탄소 집약도")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(current.carbonIntensity)) g/kWh")
                                .font(.subheadline.bold())
                        }
                        
                        // 주요 에너지원
                        HStack {
                            Text("주요 에너지원")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Label(current.primarySource.rawValue, systemImage: current.primarySource.iconName)
                                .font(.subheadline)
                        }
                    }
                }
                
                // 충전 권장 여부
                if current.isOptimalForCharging {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("지금은 충전하기 좋은 시간입니다!")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                // 로딩 상태
                ProgressView("예보 데이터 로드 중...")
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// 날짜 선택기
    private var daySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(energyService.dailyForecasts.enumerated()), id: \.element.id) { index, forecast in
                    DaySelectorButton(
                        forecast: forecast,
                        isSelected: selectedDayIndex == index
                    ) {
                        withAnimation {
                            selectedDayIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    /// 예보 차트
    private var forecastChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("시간대별 청정도")
                .font(.headline)
            
            if let dayForecast = energyService.dailyForecasts[safe: selectedDayIndex] {
                Chart(dayForecast.hourlyForecasts) { entry in
                    // 청정 에너지 비율 막대
                    BarMark(
                        x: .value("시간", entry.startTime, unit: .hour),
                        y: .value("청정도", entry.cleanEnergyPercentage)
                    )
                    .foregroundStyle(gradeColor(for: entry.cleanlinessGrade).gradient)
                    .cornerRadius(4)
                    
                    // 최적 충전 시간 표시
                    if entry.isOptimalForCharging {
                        RuleMark(x: .value("최적", entry.startTime, unit: .hour))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            .foregroundStyle(.green.opacity(0.5))
                    }
                }
                .chartYScale(domain: 0...1)
                .chartYAxis {
                    AxisMarks(values: [0, 0.25, 0.5, 0.75, 1.0]) { value in
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text("\(Int(v * 100))%")
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                        AxisValueLabel(format: .dateTime.hour())
                        AxisGridLine()
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// 시간대별 예보 목록
    private var hourlyForecastList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("시간대별 상세")
                .font(.headline)
            
            if let dayForecast = energyService.dailyForecasts[safe: selectedDayIndex] {
                ForEach(dayForecast.hourlyForecasts) { entry in
                    HourlyForecastRow(entry: entry)
                        .onTapGesture {
                            selectedEntry = entry
                        }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// 에너지 믹스 섹션
    private var energyMixSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("현재 에너지 믹스")
                .font(.headline)
            
            if let mix = energyService.currentEnergyMix {
                // 막대 차트로 표시
                VStack(spacing: 8) {
                    ForEach(mix.sources.sorted(by: { $0.percentage > $1.percentage })) { source in
                        HStack {
                            Image(systemName: source.source.iconName)
                                .frame(width: 24)
                            
                            Text(source.source.rawValue)
                                .frame(width: 60, alignment: .leading)
                            
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(sourceColor(for: source.source).gradient)
                                    .frame(width: geo.size.width * source.percentage)
                            }
                            .frame(height: 20)
                            
                            Text(source.percentageString)
                                .font(.caption)
                                .frame(width: 45, alignment: .trailing)
                        }
                    }
                }
                
                // 청정/화석 요약
                HStack {
                    Label("청정 에너지", systemImage: "leaf.fill")
                        .foregroundStyle(.green)
                    Text("\(Int(mix.cleanEnergyTotal * 100))%")
                        .font(.headline)
                    
                    Spacer()
                    
                    Label("화석 연료", systemImage: "smoke.fill")
                        .foregroundStyle(.gray)
                    Text("\(Int(mix.fossilFuelTotal * 100))%")
                        .font(.headline)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// 위치 버튼
    private var locationButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "location.fill")
                .font(.caption)
            Text(locationService.currentLocationName ?? "위치 없음")
                .font(.caption)
        }
        .foregroundStyle(.secondary)
    }
    
    // MARK: - 메서드
    
    /// 예보 새로고침
    private func refreshForecast() async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        if let location = locationService.currentLocation {
            await energyService.fetchForecast(for: location)
        }
    }
    
    /// 등급별 색상
    private func gradeColor(for grade: CleanlinessGrade) -> Color {
        switch grade {
        case .excellent: return .green
        case .good: return .mint
        case .moderate: return .yellow
        case .poor: return .orange
        case .veryPoor: return .red
        }
    }
    
    /// 에너지원별 색상
    private func sourceColor(for source: EnergySource) -> Color {
        switch source {
        case .solar: return .yellow
        case .wind: return .cyan
        case .hydro: return .blue
        case .nuclear: return .purple
        case .naturalGas: return .orange
        case .coal: return .gray
        case .other: return .secondary
        }
    }
}

// MARK: - 날짜 선택 버튼

/// 날짜 선택 버튼 컴포넌트
struct DaySelectorButton: View {
    let forecast: DailyGridForecast
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // 요일
                Text(dayOfWeek)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                
                // 날짜
                Text(dayNumber)
                    .font(.title3.bold())
                    .foregroundStyle(isSelected ? .green : .primary)
                
                // 평균 청정도 표시
                Circle()
                    .fill(averageGradeColor.gradient)
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.green.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: forecast.date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: forecast.date)
    }
    
    private var averageGradeColor: Color {
        let avg = forecast.averageCleanPercentage
        switch avg {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .mint
        case 0.4..<0.6: return .yellow
        case 0.2..<0.4: return .orange
        default: return .red
        }
    }
}

// MARK: - 시간대별 예보 행

/// 시간대별 예보 표시 행
struct HourlyForecastRow: View {
    let entry: GridForecastEntry
    
    var body: some View {
        HStack {
            // 시간
            Text(timeString)
                .font(.subheadline.monospaced())
                .frame(width: 50, alignment: .leading)
            
            // 청정도 바
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(gradeColor.gradient)
                        .frame(width: geo.size.width * entry.cleanEnergyPercentage)
                }
            }
            .frame(height: 24)
            
            // 청정도 수치
            Text("\(Int(entry.cleanEnergyPercentage * 100))%")
                .font(.subheadline.bold())
                .frame(width: 45, alignment: .trailing)
            
            // 최적 충전 표시
            if entry.isOptimalForCharging {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: entry.startTime)
    }
    
    private var gradeColor: Color {
        switch entry.cleanlinessGrade {
        case .excellent: return .green
        case .good: return .mint
        case .moderate: return .yellow
        case .poor: return .orange
        case .veryPoor: return .red
        }
    }
}

// MARK: - 예보 상세 시트

/// 특정 시간대 상세 정보 시트
struct ForecastDetailSheet: View {
    let entry: GridForecastEntry
    
    var body: some View {
        NavigationStack {
            List {
                Section("시간대") {
                    LabeledContent("시작", value: formatTime(entry.startTime))
                    LabeledContent("종료", value: formatTime(entry.endTime))
                }
                
                Section("청정 에너지") {
                    LabeledContent("청정도", value: "\(Int(entry.cleanEnergyPercentage * 100))%")
                    LabeledContent("등급", value: entry.cleanlinessGrade.description)
                    LabeledContent("주요 에너지원", value: entry.primarySource.rawValue)
                }
                
                Section("탄소 배출") {
                    LabeledContent("탄소 집약도", value: "\(Int(entry.carbonIntensity)) gCO2/kWh")
                }
                
                Section {
                    if entry.isOptimalForCharging {
                        Label("이 시간대에 충전을 권장합니다", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Label("더 좋은 충전 시간을 찾아보세요", systemImage: "info.circle")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("시간대 상세")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h시 mm분"
        return formatter.string(from: date)
    }
}

// MARK: - 안전한 배열 접근

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - 미리보기

#Preview {
    GridForecastView()
        .environment(EnergyService())
        .environment(LocationService())
}
