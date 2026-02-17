// CarbonChartView.swift
// GreenCharge - 탄소 배출량 차트 화면
// iOS 26 EnergyKit 활용

import SwiftUI
import Charts

// MARK: - 탄소 차트 뷰

/// 탄소 배출량 시각화 화면
struct CarbonChartView: View {
    
    // MARK: - 환경 객체
    
    @Environment(EnergyService.self) private var energyService
    
    // MARK: - 상태
    
    /// 차트 기간 선택
    @State private var selectedPeriod: ChartPeriod = .day
    
    /// 선택된 데이터 포인트
    @State private var selectedDataPoint: CarbonEmissionData?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 기간 선택기
                    periodSelector
                    
                    // 메인 차트
                    mainChart
                    
                    // 에너지원별 분포
                    sourceDistribution
                    
                    // 비교 통계
                    comparisonStats
                }
                .padding()
            }
            .navigationTitle("탄소 배출량")
        }
    }
    
    // MARK: - 컴포넌트
    
    /// 기간 선택기
    private var periodSelector: some View {
        Picker("기간", selection: $selectedPeriod) {
            ForEach(ChartPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }
    
    /// 메인 탄소 배출 차트
    private var mainChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("탄소 집약도 추이")
                .font(.headline)
            
            Chart(energyService.carbonEmissionHistory) { data in
                // 영역 차트
                AreaMark(
                    x: .value("시간", data.timestamp),
                    y: .value("배출량", data.emissionIntensity)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [.orange.opacity(0.6), .orange.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // 라인 차트
                LineMark(
                    x: .value("시간", data.timestamp),
                    y: .value("배출량", data.emissionIntensity)
                )
                .foregroundStyle(.orange)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                // 포인트
                PointMark(
                    x: .value("시간", data.timestamp),
                    y: .value("배출량", data.emissionIntensity)
                )
                .foregroundStyle(.orange)
                .symbolSize(selectedDataPoint?.id == data.id ? 100 : 30)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(Int(v))")
                        }
                    }
                    AxisGridLine()
                }
            }
            .chartYAxisLabel("gCO₂/kWh", position: .leading)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel(format: selectedPeriod.dateFormat)
                    AxisGridLine()
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    selectDataPoint(at: value.location, proxy: proxy, geo: geo)
                                }
                                .onEnded { _ in
                                    selectedDataPoint = nil
                                }
                        )
                }
            }
            .frame(height: 220)
            
            // 선택된 데이터 포인트 정보
            if let selected = selectedDataPoint {
                HStack {
                    Text(formatTime(selected.timestamp))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(selected.emissionIntensity)) gCO₂/kWh")
                        .font(.caption.bold())
                    
                    Circle()
                        .fill(intensityColor(for: selected.intensityLevel))
                        .frame(width: 8, height: 8)
                }
                .padding(8)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// 에너지원별 분포 차트
    private var sourceDistribution: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("에너지원별 분포")
                .font(.headline)
            
            if let mix = energyService.currentEnergyMix {
                // 파이 차트
                Chart(mix.sources) { source in
                    SectorMark(
                        angle: .value("비율", source.percentage),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(sourceColor(for: source.source))
                    .cornerRadius(4)
                }
                .frame(height: 200)
                
                // 범례
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                    ForEach(mix.sources) { source in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(sourceColor(for: source.source))
                                .frame(width: 10, height: 10)
                            
                            Text(source.source.rawValue)
                                .font(.caption)
                            
                            Spacer()
                            
                            Text(source.percentageString)
                                .font(.caption.bold())
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// 비교 통계
    private var comparisonStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("현재 vs 평균")
                .font(.headline)
            
            HStack(spacing: 16) {
                // 현재 값
                VStack(spacing: 4) {
                    Text("현재")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(Int(energyService.currentCarbonIntensity))")
                        .font(.title.bold())
                        .foregroundStyle(currentIntensityColor)
                    
                    Text("gCO₂/kWh")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // 일평균
                VStack(spacing: 4) {
                    Text("일평균")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(Int(energyService.dailyAverageCarbonIntensity))")
                        .font(.title.bold())
                    
                    Text("gCO₂/kWh")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // 전국 평균
                VStack(spacing: 4) {
                    Text("전국 평균")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("420")
                        .font(.title.bold())
                        .foregroundStyle(.secondary)
                    
                    Text("gCO₂/kWh")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            // 현재 상태 메시지
            HStack {
                Image(systemName: currentStatusIcon)
                    .foregroundStyle(currentIntensityColor)
                
                Text(currentStatusMessage)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(currentIntensityColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 메서드
    
    /// 차트 데이터 포인트 선택
    private func selectDataPoint(at location: CGPoint, proxy: ChartProxy, geo: GeometryProxy) {
        let origin = geo[proxy.plotFrame!].origin
        let x = location.x - origin.x
        
        guard let date: Date = proxy.value(atX: x) else { return }
        
        // 가장 가까운 데이터 포인트 찾기
        selectedDataPoint = energyService.carbonEmissionHistory.min(by: {
            abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date))
        })
    }
    
    /// 시간 포맷
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M/d a h시"
        return formatter.string(from: date)
    }
    
    /// 배출 수준 색상
    private func intensityColor(for level: EmissionLevel) -> Color {
        switch level {
        case .veryLow: return .green
        case .low: return .mint
        case .medium: return .yellow
        case .high: return .orange
        case .veryHigh: return .red
        }
    }
    
    /// 에너지원 색상
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
    
    /// 현재 집약도 색상
    private var currentIntensityColor: Color {
        let intensity = energyService.currentCarbonIntensity
        switch intensity {
        case 0..<100: return .green
        case 100..<200: return .mint
        case 200..<350: return .yellow
        case 350..<500: return .orange
        default: return .red
        }
    }
    
    /// 현재 상태 아이콘
    private var currentStatusIcon: String {
        let intensity = energyService.currentCarbonIntensity
        if intensity < 200 {
            return "leaf.fill"
        } else if intensity < 400 {
            return "cloud"
        } else {
            return "smoke.fill"
        }
    }
    
    /// 현재 상태 메시지
    private var currentStatusMessage: String {
        let intensity = energyService.currentCarbonIntensity
        let avg = energyService.dailyAverageCarbonIntensity
        
        if intensity < avg * 0.8 {
            return "지금이 충전하기 좋은 시간입니다!"
        } else if intensity < avg * 1.2 {
            return "현재 평균 수준의 탄소 집약도입니다."
        } else {
            return "더 좋은 충전 시간을 기다려보세요."
        }
    }
}

// MARK: - 차트 기간

/// 차트 표시 기간
enum ChartPeriod: String, CaseIterable, Identifiable {
    case day = "오늘"
    case week = "주간"
    case month = "월간"
    
    var id: String { rawValue }
    
    /// 날짜 포맷
    var dateFormat: Date.FormatStyle {
        switch self {
        case .day:
            return .dateTime.hour()
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.day()
        }
    }
}

// MARK: - 미리보기

#Preview {
    CarbonChartView()
        .environment(EnergyService())
}
