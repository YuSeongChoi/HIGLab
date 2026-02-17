// EnergyService.swift
// GreenCharge - EnergyKit 서비스
// iOS 26 EnergyKit 활용

import Foundation
import EnergyKit
import CoreLocation
import Observation

// MARK: - 에너지 서비스

/// EnergyKit을 활용한 전력망 예보 서비스
@Observable
final class EnergyService {
    
    // MARK: - 속성
    
    /// 현재 시간대 예보
    private(set) var currentForecast: GridForecastEntry?
    
    /// 일간 예보 목록
    private(set) var dailyForecasts: [DailyGridForecast] = []
    
    /// 현재 에너지 믹스
    private(set) var currentEnergyMix: EnergyMix?
    
    /// 탄소 배출 히스토리 (차트용)
    private(set) var carbonEmissionHistory: [CarbonEmissionData] = []
    
    /// 충전 기록
    private(set) var chargingRecords: [ChargingRecord] = []
    
    /// 로딩 상태
    private(set) var isLoading = false
    
    /// 에러 메시지
    private(set) var errorMessage: String?
    
    /// 마지막 업데이트 시간
    private(set) var lastUpdated: Date?
    
    // MARK: - 계산 속성
    
    /// 현재 탄소 집약도
    var currentCarbonIntensity: Double {
        currentForecast?.carbonIntensity ?? 0
    }
    
    /// 일일 평균 탄소 집약도
    var dailyAverageCarbonIntensity: Double {
        guard let today = dailyForecasts.first else { return 0 }
        let intensities = today.hourlyForecasts.map(\.carbonIntensity)
        guard !intensities.isEmpty else { return 0 }
        return intensities.reduce(0, +) / Double(intensities.count)
    }
    
    /// 다음 최적 충전 시간대
    var nextOptimalChargingTime: GridForecastEntry? {
        let now = Date()
        
        for forecast in dailyForecasts {
            if let optimal = forecast.optimalChargingPeriods.first(where: { $0.startTime > now }) {
                return optimal
            }
        }
        
        return nil
    }
    
    // MARK: - EnergyKit 연동
    
    /// 위치 기반 전력망 예보 조회
    /// - Parameter location: 조회할 위치
    @MainActor
    func fetchForecast(for location: CLLocation) async {
        await fetchForecast(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    /// 좌표 기반 전력망 예보 조회
    /// - Parameters:
    ///   - latitude: 위도
    ///   - longitude: 경도
    @MainActor
    func fetchForecast(latitude: Double, longitude: Double) async {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
            lastUpdated = Date()
        }
        
        do {
            // EKGridForecast 조회 (iOS 26 API)
            let forecast = try await EKGridForecast.forecast(
                for: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            )
            
            // 시간대별 예보 변환
            var entries: [GridForecastEntry] = []
            
            for window in forecast.windows {
                let entry = GridForecastEntry(from: window, location: "현재 위치")
                entries.append(entry)
            }
            
            // 현재 시간대 설정
            let now = Date()
            currentForecast = entries.first { $0.startTime <= now && now < $0.endTime }
            
            // 일별로 그룹화
            dailyForecasts = groupByDay(entries)
            
            // 에너지 믹스 업데이트
            await fetchEnergyMix(from: forecast)
            
            // 탄소 배출 히스토리 업데이트
            updateCarbonHistory(from: entries)
            
        } catch {
            errorMessage = "예보 데이터를 불러올 수 없습니다: \(error.localizedDescription)"
            
            // 에러 시 샘플 데이터로 대체 (개발용)
            loadSampleData()
        }
    }
    
    /// 에너지 믹스 조회
    private func fetchEnergyMix(from forecast: EKGridForecast) async {
        // 현재 에너지 믹스 구성
        var sources: [EnergySourceShare] = []
        
        if let currentWindow = forecast.windows.first(where: {
            $0.startDate <= Date() && Date() < $0.endDate
        }) {
            // EnergyKit에서 제공하는 에너지원 비율 사용
            for (source, percentage) in currentWindow.energySourceBreakdown {
                let share = EnergySourceShare(
                    source: EnergySource.from(ekSource: source),
                    percentage: percentage
                )
                sources.append(share)
            }
        }
        
        currentEnergyMix = EnergyMix(timestamp: Date(), sources: sources)
    }
    
    /// 일별 그룹화
    private func groupByDay(_ entries: [GridForecastEntry]) -> [DailyGridForecast] {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.startTime)
        }
        
        return grouped.map { date, hourlyForecasts in
            DailyGridForecast(date: date, hourlyForecasts: hourlyForecasts.sorted { $0.startTime < $1.startTime })
        }.sorted { $0.date < $1.date }
    }
    
    /// 탄소 히스토리 업데이트
    private func updateCarbonHistory(from entries: [GridForecastEntry]) {
        carbonEmissionHistory = entries.map { entry in
            CarbonEmissionData(
                timestamp: entry.startTime,
                emissionIntensity: entry.carbonIntensity,
                cleanEnergyRatio: entry.cleanEnergyPercentage
            )
        }
    }
    
    // MARK: - 충전 기록 관리
    
    /// 충전 기록 추가
    func addChargingRecord(_ record: ChargingRecord) {
        chargingRecords.append(record)
        saveChargingRecords()
    }
    
    /// 충전 기록 저장 (UserDefaults)
    private func saveChargingRecords() {
        if let encoded = try? JSONEncoder().encode(chargingRecords) {
            UserDefaults.standard.set(encoded, forKey: "chargingRecords")
        }
    }
    
    /// 충전 기록 로드
    func loadChargingRecords() {
        if let data = UserDefaults.standard.data(forKey: "chargingRecords"),
           let records = try? JSONDecoder().decode([ChargingRecord].self, from: data) {
            chargingRecords = records
        }
    }
    
    // MARK: - 샘플 데이터 (개발용)
    
    /// 샘플 데이터 로드
    private func loadSampleData() {
        let calendar = Calendar.current
        let now = Date()
        
        var entries: [GridForecastEntry] = []
        
        // 48시간 예보 생성
        for hourOffset in 0..<48 {
            guard let startTime = calendar.date(byAdding: .hour, value: hourOffset, to: calendar.startOfDay(for: now)) else { continue }
            guard let endTime = calendar.date(byAdding: .hour, value: 1, to: startTime) else { continue }
            
            let hour = calendar.component(.hour, from: startTime)
            
            // 시간대별 청정도 시뮬레이션 (낮에 높고 밤에 낮음)
            let baseClean: Double
            switch hour {
            case 10...16:  // 낮 시간 (태양광 최대)
                baseClean = Double.random(in: 0.7...0.95)
            case 6...9, 17...20:  // 아침, 저녁
                baseClean = Double.random(in: 0.5...0.75)
            default:  // 밤
                baseClean = Double.random(in: 0.3...0.55)
            }
            
            let carbonIntensity = 500.0 * (1.0 - baseClean) + Double.random(in: -50...50)
            
            let sources: [EnergySource] = [.solar, .wind, .nuclear, .naturalGas, .coal]
            let primarySource = baseClean > 0.6 ? sources.randomElement()! : .naturalGas
            
            let entry = GridForecastEntry(
                startTime: startTime,
                endTime: endTime,
                cleanEnergyPercentage: baseClean,
                carbonIntensity: max(50, carbonIntensity),
                primarySource: primarySource,
                isOptimalForCharging: baseClean >= AppConstants.optimalChargingThreshold
            )
            
            entries.append(entry)
        }
        
        // 현재 시간대 설정
        currentForecast = entries.first { $0.startTime <= now && now < $0.endTime }
        
        // 일별 그룹화
        dailyForecasts = groupByDay(entries)
        
        // 탄소 히스토리 업데이트
        updateCarbonHistory(from: entries)
        
        // 샘플 에너지 믹스
        currentEnergyMix = EnergyMix(
            timestamp: now,
            sources: [
                EnergySourceShare(source: .solar, percentage: 0.25),
                EnergySourceShare(source: .wind, percentage: 0.15),
                EnergySourceShare(source: .nuclear, percentage: 0.28),
                EnergySourceShare(source: .naturalGas, percentage: 0.22),
                EnergySourceShare(source: .coal, percentage: 0.08),
                EnergySourceShare(source: .hydro, percentage: 0.02)
            ]
        )
        
        // 샘플 충전 기록
        loadSampleChargingRecords()
    }
    
    /// 샘플 충전 기록 로드
    private func loadSampleChargingRecords() {
        let calendar = Calendar.current
        let now = Date()
        
        var records: [ChargingRecord] = []
        
        // 최근 7일간의 샘플 기록 생성
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            
            // 하루에 0~2회 충전
            let sessionsPerDay = Int.random(in: 0...2)
            
            for _ in 0..<sessionsPerDay {
                let hour = Int.random(in: 8...22)
                guard let startTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date) else { continue }
                guard let endTime = calendar.date(byAdding: .hour, value: Int.random(in: 1...3), to: startTime) else { continue }
                
                let cleanPercentage = Double.random(in: 0.5...0.95)
                let energyUsed = Double.random(in: 0.5...2.0)
                let carbonEmitted = energyUsed * (1.0 - cleanPercentage) * 0.5
                let carbonSaved = energyUsed * cleanPercentage * 0.3
                
                let devices = ["iPhone 16 Pro", "iPad Pro", "MacBook Air", "Apple Watch", "전기차"]
                
                let record = ChargingRecord(
                    deviceName: devices.randomElement()!,
                    startTime: startTime,
                    endTime: endTime,
                    energyUsed: energyUsed,
                    cleanEnergyPercentage: cleanPercentage,
                    carbonEmitted: carbonEmitted,
                    carbonSaved: carbonSaved
                )
                
                records.append(record)
            }
        }
        
        chargingRecords = records.sorted { $0.startTime > $1.startTime }
    }
}

// MARK: - EKGridForecast.Window 확장 (iOS 26 호환)

extension EKGridForecast.Window {
    /// 에너지원 비율 맵 (시뮬레이션)
    var energySourceBreakdown: [EKEnergySource: Double] {
        // 실제 API에서는 이 데이터를 제공
        // 여기서는 시뮬레이션 값 반환
        [
            .solar: cleanEnergyPercentage * 0.4,
            .wind: cleanEnergyPercentage * 0.3,
            .nuclear: cleanEnergyPercentage * 0.2,
            .naturalGas: (1 - cleanEnergyPercentage) * 0.6,
            .coal: (1 - cleanEnergyPercentage) * 0.3,
            .hydro: cleanEnergyPercentage * 0.1
        ]
    }
}
