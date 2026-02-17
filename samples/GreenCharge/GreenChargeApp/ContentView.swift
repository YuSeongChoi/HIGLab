// ContentView.swift
// GreenCharge - 메인 컨텐츠 뷰
// iOS 26 EnergyKit 활용

import SwiftUI

// MARK: - 메인 컨텐츠 뷰

/// 앱 메인 화면 (탭 기반 네비게이션)
struct ContentView: View {
    
    // MARK: - 환경 객체
    
    @Environment(EnergyService.self) private var energyService
    @Environment(LocationService.self) private var locationService
    
    // MARK: - 상태
    
    /// 현재 선택된 탭
    @State private var selectedTab: MainTab = .forecast
    
    /// 새로고침 중 여부
    @State private var isRefreshing = false
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 전력망 예보 탭
            Tab(MainTab.forecast.rawValue, systemImage: MainTab.forecast.iconName, value: .forecast) {
                GridForecastView()
            }
            
            // 충전 스케줄 탭
            Tab(MainTab.schedule.rawValue, systemImage: MainTab.schedule.iconName, value: .schedule) {
                ChargingScheduleView()
            }
            
            // 통계 탭
            Tab(MainTab.stats.rawValue, systemImage: MainTab.stats.iconName, value: .stats) {
                WeeklyStatsView()
            }
            
            // 설정 탭
            Tab(MainTab.settings.rawValue, systemImage: MainTab.settings.iconName, value: .settings) {
                SettingsView()
            }
        }
        .tint(.green)
        .task {
            await loadInitialData()
        }
    }
    
    // MARK: - 메서드
    
    /// 초기 데이터 로드
    private func loadInitialData() async {
        guard let location = locationService.currentLocation else {
            // 위치 없으면 기본 위치 사용 (서울)
            await energyService.fetchForecast(latitude: 37.5665, longitude: 126.9780)
            return
        }
        
        await energyService.fetchForecast(for: location)
    }
}

// MARK: - 설정 뷰

/// 앱 설정 화면
struct SettingsView: View {
    
    @Environment(NotificationService.self) private var notificationService
    
    var body: some View {
        NavigationStack {
            List {
                // 알림 설정 섹션
                Section("알림") {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("알림 설정", systemImage: "bell.fill")
                    }
                }
                
                // 위치 설정 섹션
                Section("위치") {
                    NavigationLink {
                        LocationSettingsView()
                    } label: {
                        Label("위치 설정", systemImage: "location.fill")
                    }
                }
                
                // 앱 정보 섹션
                Section("정보") {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text(AppConstants.appVersion)
                            .foregroundStyle(.secondary)
                    }
                    
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("앱 정보", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("설정")
        }
    }
}

// MARK: - 위치 설정 뷰

/// 위치 관련 설정
struct LocationSettingsView: View {
    
    @Environment(LocationService.self) private var locationService
    @State private var useCurrentLocation = true
    @State private var selectedRegion = "서울"
    
    private let regions = ["서울", "부산", "대구", "인천", "광주", "대전", "울산", "세종", "제주"]
    
    var body: some View {
        Form {
            Section {
                Toggle("현재 위치 사용", isOn: $useCurrentLocation)
                
                if let location = locationService.currentLocation {
                    HStack {
                        Text("현재 위치")
                        Spacer()
                        Text(locationService.currentLocationName ?? "알 수 없음")
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("위치 설정")
            } footer: {
                Text("현재 위치를 사용하면 더 정확한 전력망 예보를 받을 수 있습니다.")
            }
            
            if !useCurrentLocation {
                Section("지역 선택") {
                    Picker("지역", selection: $selectedRegion) {
                        ForEach(regions, id: \.self) { region in
                            Text(region).tag(region)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
            
            Section {
                Button {
                    Task {
                        await locationService.requestAuthorization()
                    }
                } label: {
                    Label("위치 권한 재요청", systemImage: "location.circle")
                }
            }
        }
        .navigationTitle("위치 설정")
    }
}

// MARK: - 앱 정보 뷰

/// 앱 정보 화면
struct AboutView: View {
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // 앱 아이콘 및 이름
                VStack(spacing: 16) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green.gradient)
                        .symbolEffect(.pulse)
                    
                    Text(AppConstants.appName)
                        .font(.largeTitle.bold())
                    
                    Text("청정 에너지로 충전하세요")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                // 기능 설명
                VStack(alignment: .leading, spacing: 24) {
                    FeatureRow(
                        icon: "sun.max.fill",
                        color: .yellow,
                        title: "실시간 전력망 예보",
                        description: "EnergyKit을 활용한 정확한 청정 에너지 예보"
                    )
                    
                    FeatureRow(
                        icon: "clock.fill",
                        color: .mint,
                        title: "최적 충전 시간 추천",
                        description: "청정 에너지 비율이 가장 높은 시간대 안내"
                    )
                    
                    FeatureRow(
                        icon: "leaf.fill",
                        color: .green,
                        title: "탄소 절감 추적",
                        description: "충전으로 절감한 탄소 배출량 실시간 확인"
                    )
                    
                    FeatureRow(
                        icon: "bell.fill",
                        color: .orange,
                        title: "스마트 알림",
                        description: "청정 에너지 시간대 시작 전 미리 알림"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 저작권
                Text("© 2026 GreenCharge")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 20)
            }
        }
        .navigationTitle("앱 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 기능 설명 행

/// 기능 설명 행 컴포넌트
struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - 미리보기

#Preview {
    ContentView()
        .environment(EnergyService())
        .environment(LocationService())
        .environment(NotificationService())
}
