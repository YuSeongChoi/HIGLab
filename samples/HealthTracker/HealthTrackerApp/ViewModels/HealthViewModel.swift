import Foundation
import SwiftUI
import Combine

// MARK: - 건강 뷰모델
/// 앱 전체의 건강 데이터를 관리하는 뷰모델
@MainActor
final class HealthViewModel: ObservableObject {
    
    // MARK: - 서비스
    private let healthService = HealthKitService.shared
    
    // MARK: - 권한 상태
    @Published var isAuthorized: Bool = false
    
    // MARK: - 에러 상태
    @Published var showError: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - 로딩 상태
    @Published var isLoadingSteps: Bool = false
    @Published var isLoadingHeartRate: Bool = false
    @Published var isLoadingSleep: Bool = false
    @Published var isLoadingWorkouts: Bool = false
    @Published var isLoadingStatistics: Bool = false
    
    // MARK: - 오늘의 데이터
    @Published var todaySteps: Int = 0
    @Published var todayCalories: Double = 0
    @Published var todayDistance: Double = 0
    @Published var latestHeartRate: HeartRateData?
    @Published var lastNightSleepMinutes: Int = 0
    @Published var lastNightSleepQuality: String = ""
    
    // MARK: - 상세 데이터
    @Published var weeklySteps: [StepData] = []
    @Published var heartRateData: [HeartRateData] = []
    @Published var sleepData: [SleepData] = []
    @Published var workouts: [WorkoutData] = []
    
    // MARK: - 통계 데이터
    @Published var statisticsPeriod: StatisticsPeriod = .week
    @Published var statisticsData: StatisticsData?
    
    // MARK: - 건강 목표
    @Published var goals: [HealthGoal] = []
    
    // MARK: - UserDefaults 키
    private let goalsKey = "healthGoals"
    
    // MARK: - 초기화
    init() {
        loadGoals()
    }
    
    // MARK: - 권한 요청
    /// HealthKit 권한 요청
    func requestAuthorization() async {
        do {
            try await healthService.requestAuthorization()
            isAuthorized = true
            // 권한 승인 후 데이터 로드
            await loadAllData()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - 모든 데이터 로드
    /// 앱 시작 시 또는 새로고침 시 모든 데이터 로드
    func loadAllData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTodayData() }
            group.addTask { await self.loadWeeklySteps() }
            group.addTask { await self.loadHeartRateData() }
            group.addTask { await self.loadSleepData() }
            group.addTask { await self.loadWorkouts() }
        }
        
        // 목표 진행 상황 업데이트
        updateGoalProgress()
    }
    
    // MARK: - 오늘의 데이터 로드
    /// 오늘의 걸음 수, 칼로리, 거리, 심박수 로드
    func loadTodayData() async {
        do {
            async let steps = healthService.fetchTodaySteps()
            async let calories = healthService.fetchTodayCalories()
            async let distance = healthService.fetchTodayDistance()
            async let heartRate = healthService.fetchLatestHeartRate()
            async let sleep = healthService.fetchLastNightSleep()
            
            let (stepsResult, caloriesResult, distanceResult, heartRateResult, sleepResult) = try await (steps, calories, distance, heartRate, sleep)
            
            todaySteps = stepsResult
            todayCalories = caloriesResult
            todayDistance = distanceResult
            latestHeartRate = heartRateResult
            lastNightSleepMinutes = sleepResult.totalMinutes
            lastNightSleepQuality = sleepResult.quality
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - 주간 걸음 수 로드
    /// 지난 7일간의 걸음 수 데이터 로드
    func loadWeeklySteps() async {
        isLoadingSteps = true
        defer { isLoadingSteps = false }
        
        do {
            weeklySteps = try await healthService.fetchSteps(for: 7)
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - 심박수 데이터 로드
    /// 지난 24시간의 심박수 데이터 로드
    func loadHeartRateData() async {
        isLoadingHeartRate = true
        defer { isLoadingHeartRate = false }
        
        do {
            heartRateData = try await healthService.fetchHeartRate(for: 24)
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - 수면 데이터 로드
    /// 지난 7일간의 수면 데이터 로드
    func loadSleepData() async {
        isLoadingSleep = true
        defer { isLoadingSleep = false }
        
        do {
            sleepData = try await healthService.fetchSleepData(for: 7)
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - 운동 데이터 로드
    /// 지난 30일간의 운동 데이터 로드
    func loadWorkouts() async {
        isLoadingWorkouts = true
        defer { isLoadingWorkouts = false }
        
        do {
            workouts = try await healthService.fetchWorkouts(for: 30)
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - 통계 데이터 로드
    /// 선택된 기간의 통계 데이터 로드
    func loadStatistics() async {
        isLoadingStatistics = true
        defer { isLoadingStatistics = false }
        
        do {
            let days = statisticsPeriod.days
            
            async let steps = healthService.fetchSteps(for: days)
            async let heartRates = healthService.fetchHeartRate(for: days * 24)
            async let sleep = healthService.fetchSleepData(for: days)
            async let workoutData = healthService.fetchWorkouts(for: days)
            
            let (stepsResult, heartRatesResult, sleepResult, workoutsResult) = try await (steps, heartRates, sleep, workoutData)
            
            statisticsData = StatisticsData(
                period: statisticsPeriod,
                steps: stepsResult,
                heartRates: heartRatesResult,
                sleepData: sleepResult,
                workouts: workoutsResult
            )
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - 운동 저장
    /// 새 운동 기록 저장
    /// - Parameters:
    ///   - type: 운동 유형
    ///   - duration: 운동 시간 (분)
    ///   - calories: 소모 칼로리
    ///   - distance: 이동 거리 (km, 선택)
    func saveWorkout(type: WorkoutType, duration: Int, calories: Double, distance: Double?) async {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .minute, value: -duration, to: endDate) ?? endDate
        let distanceMeters = distance.map { $0 * 1000 } // km -> m 변환
        
        do {
            try await healthService.saveWorkout(
                type: type,
                startDate: startDate,
                endDate: endDate,
                calories: calories,
                distance: distanceMeters
            )
            
            // 운동 목록 새로고침
            await loadWorkouts()
            
            // 오늘의 데이터 업데이트
            await loadTodayData()
            
            // 목표 진행 상황 업데이트
            updateGoalProgress()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - 목표 관리
    /// 저장된 목표 로드
    private func loadGoals() {
        guard let data = UserDefaults.standard.data(forKey: goalsKey),
              let savedGoals = try? JSONDecoder().decode([HealthGoal].self, from: data) else {
            // 기본 목표 설정
            goals = GoalType.allCases.map { type in
                HealthGoal(type: type, targetValue: type.defaultTarget)
            }
            saveGoals()
            return
        }
        goals = savedGoals
    }
    
    /// 목표 저장
    func saveGoals() {
        guard let data = try? JSONEncoder().encode(goals) else { return }
        UserDefaults.standard.set(data, forKey: goalsKey)
    }
    
    /// 목표 업데이트
    /// - Parameters:
    ///   - goal: 업데이트할 목표
    ///   - targetValue: 새 목표 값
    func updateGoal(_ goal: HealthGoal, targetValue: Double) {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[index].targetValue = targetValue
        saveGoals()
    }
    
    /// 목표 활성화/비활성화 토글
    func toggleGoal(_ goal: HealthGoal) {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[index].isEnabled.toggle()
        saveGoals()
    }
    
    /// 목표 진행 상황 업데이트
    func updateGoalProgress() {
        for index in goals.indices {
            switch goals[index].type {
            case .steps:
                goals[index].currentValue = Double(todaySteps)
            case .calories:
                goals[index].currentValue = todayCalories
            case .exerciseMinutes:
                // 오늘의 운동 시간 계산
                let today = Calendar.current.startOfDay(for: Date())
                let todayWorkouts = workouts.filter { Calendar.current.isDate($0.startDate, inSameDayAs: today) }
                let totalMinutes = todayWorkouts.reduce(0) { $0 + $1.durationMinutes }
                goals[index].currentValue = Double(totalMinutes)
            case .sleepHours:
                goals[index].currentValue = Double(lastNightSleepMinutes) / 60.0
            case .distance:
                goals[index].currentValue = todayDistance
            }
        }
    }
    
    // MARK: - 에러 처리
    /// 에러 처리 및 사용자에게 표시
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
    
    // MARK: - 헬퍼 메서드
    /// 걸음 수를 포맷된 문자열로 변환
    var formattedTodaySteps: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: todaySteps)) ?? "\(todaySteps)"
    }
    
    /// 칼로리를 포맷된 문자열로 변환
    var formattedTodayCalories: String {
        return String(format: "%.0f kcal", todayCalories)
    }
    
    /// 거리를 포맷된 문자열로 변환
    var formattedTodayDistance: String {
        return String(format: "%.2f km", todayDistance)
    }
    
    /// 수면 시간을 포맷된 문자열로 변환
    var formattedLastNightSleep: String {
        let hours = lastNightSleepMinutes / 60
        let minutes = lastNightSleepMinutes % 60
        return "\(hours)시간 \(minutes)분"
    }
}
