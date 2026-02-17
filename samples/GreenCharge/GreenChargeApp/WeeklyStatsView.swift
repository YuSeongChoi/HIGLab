// WeeklyStatsView.swift
// GreenCharge - 주간 통계 화면
// iOS 26 EnergyKit 활용

import SwiftUI
import Charts

// MARK: - 주간 통계 뷰

/// 주간 충전 및 탄소 절감 통계 화면
struct WeeklyStatsView: View {
    
    // MARK: - 환경 객체
    
    @Environment(EnergyService.self) private var energyService
    
    // MARK: - 상태
    
    /// 선택된 주차 (0 = 이번 주)
    @State private var selectedWeekOffset = 0
    
    /// 애니메이션 진행 상태
    @State private var animationProgress = 0.0
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 주차 선택기
                    weekSelector
                    
                    // 요약 카드
                    summaryCards
                    
                    // 일별 차트
                    dailyChart
                    
                    // 환경 영향
                    environmentalImpact
                    
                    // 충전 기록
                    chargingHistory
                }
                .padding()
            }
            .navigationTitle("주간 통계")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        CarbonChartView()
                    } label: {
                        Image(systemName: "chart.xyaxis.line")
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            }
        }
    }
    
    // MARK: - 컴포넌트
    
    /// 주차 선택기
    private var weekSelector: some View {
        HStack {
            Button {
                withAnimation {
                    selectedWeekOffset -= 1
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(selectedWeekOffset <= -4)
            
            Spacer()
            
            Text(weekRangeString)
                .font(.headline)
            
            Spacer()
            
            Button {
                withAnimation {
                    selectedWeekOffset += 1
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(selectedWeekOffset >= 0)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// 요약 카드
    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            // 총 충전량
            StatCard(
                title: "총 충전량",
                value: String(format: "%.1f", weeklyStats?.totalEnergyCharged ?? 0),
                unit: "kWh",
                icon: "bolt.fill",
                color: .blue,
                progress: animationProgress
            )
            
            // 탄소 절감량
            StatCard(
                title: "탄소 절감",
                value: String(format: "%.2f", weeklyStats?.totalCarbonSaved ?? 0),
                unit: "kg",
                icon: "leaf.fill",
                color: .green,
                progress: animationProgress
            )
            
            // 평균 청정도
            StatCard(
                title: "평균 청정도",
                value: String(format: "%.0f", (weeklyStats?.averageCleanRatio ?? 0) * 100),
                unit: "%",
                icon: "sparkles",
                color: .mint,
                progress: animationProgress
            )
            
            // 충전 횟수
            StatCard(
                title: "충전 횟수",
                value: "\(totalChargingSessions)",
                unit: "회",
                icon: "battery.100.bolt",
                color: .orange,
                progress: animationProgress
            )
        }
    }
    
    /// 일별 차트
    private var dailyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("일별 탄소 절감량")
                .font(.headline)
            
            if let stats = weeklyStats {
                Chart(stats.dailyStats) { day in
                    BarMark(
                        x: .value("요일", day.dayOfWeekString),
                        y: .value("절감량", day.carbonSaved * animationProgress)
                    )
                    .foregroundStyle(.green.gradient)
                    .cornerRadius(6)
                    
                    // 청정도 라인
                    LineMark(
                        x: .value("요일", day.dayOfWeekString),
                        y: .value("청정도", day.averageCleanRatio * (stats.dailyStats.map(\.carbonSaved).max() ?? 1) * animationProgress)
                    )
                    .foregroundStyle(.orange)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    
                    PointMark(
                        x: .value("요일", day.dayOfWeekString),
                        y: .value("청정도", day.averageCleanRatio * (stats.dailyStats.map(\.carbonSaved).max() ?? 1) * animationProgress)
                    )
                    .foregroundStyle(.orange)
                    .symbolSize(40)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text(String(format: "%.1f", v))
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartYAxisLabel("kg CO₂", position: .leading)
                .frame(height: 200)
                
                // 범례
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.green.gradient)
                            .frame(width: 16, height: 10)
                        Text("탄소 절감량")
                            .font(.caption)
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.orange)
                            .frame(width: 8, height: 8)
                        Text("청정도")
                            .font(.caption)
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// 환경 영향
    private var environmentalImpact: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("환경 영향")
                .font(.headline)
            
            let impact = EnvironmentalImpact(carbonSaved: weeklyStats?.totalCarbonSaved ?? 0)
            
            HStack(spacing: 0) {
                // 자동차 주행 거리
                ImpactCard(
                    icon: "car.fill",
                    value: impact.formattedCarDistance,
                    description: "자동차 주행\n거리 절감",
                    color: .blue
                )
                
                Divider()
                    .frame(height: 80)
                
                // 나무 환산
                ImpactCard(
                    icon: "tree.fill",
                    value: impact.formattedTreesCount,
                    description: "나무 심기\n환산",
                    color: .green
                )
                
                Divider()
                    .frame(height: 80)
                
                // 스마트폰 충전
                ImpactCard(
                    icon: "iphone",
                    value: String(format: "%.0f회", impact.phoneChargesEquivalent),
                    description: "스마트폰\n충전 횟수",
                    color: .purple
                )
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// 충전 기록
    private var chargingHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("충전 기록")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink("전체 보기") {
                    ChargingHistoryListView()
                }
                .font(.caption)
            }
            
            if energyService.chargingRecords.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "battery.0")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    
                    Text("충전 기록이 없습니다")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(energyService.chargingRecords.prefix(3)) { record in
                    ChargingRecordRow(record: record)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 계산 속성
    
    /// 선택된 주의 통계
    private var weeklyStats: WeeklyCarbonStats? {
        let calendar = Calendar.current
        let today = Date()
        
        guard let weekStart = calendar.date(byAdding: .weekOfYear, value: selectedWeekOffset, to: calendar.startOfWeek(for: today)) else {
            return nil
        }
        
        return energyService.chargingRecords.weeklyStats(for: weekStart)
    }
    
    /// 총 충전 횟수
    private var totalChargingSessions: Int {
        weeklyStats?.dailyStats.map(\.chargingSessions).reduce(0, +) ?? 0
    }
    
    /// 주간 범위 문자열
    private var weekRangeString: String {
        weeklyStats?.weekRangeString ?? "데이터 없음"
    }
}

// MARK: - 통계 카드

/// 통계 요약 카드
struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                
                Spacer()
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title.bold())
                    .contentTransition(.numericText())
                
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 환경 영향 카드

/// 환경 영향 표시 카드
struct ImpactCard: View {
    let icon: String
    let value: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.headline)
            
            Text(description)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 충전 기록 행

/// 충전 기록 표시 행
struct ChargingRecordRow: View {
    let record: ChargingRecord
    
    var body: some View {
        HStack {
            // 기기 아이콘
            Image(systemName: deviceIcon)
                .font(.title3)
                .foregroundStyle(.green)
                .frame(width: 36)
            
            // 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(record.deviceName)
                    .font(.subheadline.bold())
                
                Text("\(record.dateString) \(record.timeRangeString)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 절감량
            VStack(alignment: .trailing, spacing: 2) {
                Text("-\(String(format: "%.2f", record.carbonSaved))kg")
                    .font(.subheadline.bold())
                    .foregroundStyle(.green)
                
                Text("\(Int(record.cleanEnergyPercentage * 100))% 청정")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var deviceIcon: String {
        let name = record.deviceName.lowercased()
        if name.contains("iphone") || name.contains("폰") {
            return "iphone"
        } else if name.contains("ipad") {
            return "ipad"
        } else if name.contains("watch") {
            return "applewatch"
        } else if name.contains("mac") {
            return "macbook"
        } else if name.contains("car") || name.contains("차") {
            return "car.fill"
        } else {
            return "bolt.fill"
        }
    }
}

// MARK: - 충전 기록 목록 뷰

/// 전체 충전 기록 목록
struct ChargingHistoryListView: View {
    @Environment(EnergyService.self) private var energyService
    
    var body: some View {
        List {
            ForEach(groupedRecords, id: \.key) { date, records in
                Section(sectionHeader(for: date)) {
                    ForEach(records) { record in
                        ChargingRecordRow(record: record)
                    }
                }
            }
        }
        .navigationTitle("충전 기록")
    }
    
    private var groupedRecords: [(key: Date, value: [ChargingRecord])] {
        let grouped = energyService.chargingRecords.groupedByDate()
        return grouped.sorted { $0.key > $1.key }
    }
    
    private func sectionHeader(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }
}

// MARK: - Calendar 확장

extension Calendar {
    /// 주의 시작일 계산
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}

// MARK: - 미리보기

#Preview {
    WeeklyStatsView()
        .environment(EnergyService())
}
