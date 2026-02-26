# EnergyKit AI Reference

> 에너지 데이터 앱 구현 가이드. 이 문서를 읽고 EnergyKit 코드를 생성할 수 있습니다.

## 개요

EnergyKit은 iOS 18+에서 제공하는 에너지 사용량 및 그리드 데이터 접근 프레임워크입니다.
사용자의 전력 사용 패턴, 태양광 발전량, 탄소 발자국 등의 정보를 활용해 에너지 효율 앱을 개발할 수 있습니다.

## 필수 Import

```swift
import EnergyKit
```

## 프로젝트 설정

### 1. Capability 추가
Xcode > Signing & Capabilities > + EnergyKit

### 2. Info.plist

```xml
<key>NSEnergyUsageDescription</key>
<string>에너지 사용 패턴을 분석하기 위해 필요합니다.</string>
```

## 핵심 구성요소

### 1. EnergyManager

```swift
import EnergyKit

// 에너지 매니저 인스턴스
let energyManager = EnergyManager.shared

// 권한 요청
func requestAccess() async throws -> Bool {
    try await energyManager.requestAuthorization()
}

// 권한 상태
let status = energyManager.authorizationStatus
```

### 2. EnergyUsage (사용량 데이터)

```swift
// 오늘의 에너지 사용량
let usage = try await energyManager.fetchUsage(for: .today)

usage.totalConsumption    // 총 소비량 (kWh)
usage.peakDemand          // 최대 수요
usage.offPeakConsumption  // 비피크 소비량
usage.carbonFootprint     // 탄소 발자국 (kg CO2)
```

### 3. GridStatus (전력망 상태)

```swift
// 현재 전력망 상태
let gridStatus = try await energyManager.fetchGridStatus()

gridStatus.carbonIntensity    // 탄소 집약도 (g CO2/kWh)
gridStatus.renewablePercent   // 재생에너지 비율
gridStatus.isLowCarbonTime    // 저탄소 시간대 여부
gridStatus.nextLowCarbonTime  // 다음 저탄소 시간대
```

## 전체 작동 예제

```swift
import SwiftUI
import EnergyKit

// MARK: - Energy View Model
@Observable
class EnergyViewModel {
    var isAuthorized = false
    var todayUsage: EnergyUsage?
    var weeklyUsage: [DailyUsage] = []
    var gridStatus: GridStatus?
    var isLoading = false
    var errorMessage: String?
    
    private let energyManager = EnergyManager.shared
    
    var isSupported: Bool {
        EnergyManager.isSupported
    }
    
    func checkAuthorization() {
        isAuthorized = energyManager.authorizationStatus == .authorized
    }
    
    func requestAuthorization() async {
        do {
            isAuthorized = try await energyManager.requestAuthorization()
        } catch {
            errorMessage = "권한 요청 실패: \(error.localizedDescription)"
        }
    }
    
    func fetchData() async {
        guard isAuthorized else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 오늘의 사용량
            todayUsage = try await energyManager.fetchUsage(for: .today)
            
            // 주간 사용량
            let calendar = Calendar.current
            var daily: [DailyUsage] = []
            
            for dayOffset in 0..<7 {
                let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
                let usage = try await energyManager.fetchUsage(for: date)
                daily.append(DailyUsage(date: date, usage: usage))
            }
            weeklyUsage = daily.reversed()
            
            // 전력망 상태
            gridStatus = try await energyManager.fetchGridStatus()
            
        } catch {
            errorMessage = "데이터 로드 실패: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Models
struct DailyUsage: Identifiable {
    let id = UUID()
    let date: Date
    let usage: EnergyUsage
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// MARK: - Main View
struct EnergyDashboardView: View {
    @State private var viewModel = EnergyViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if !viewModel.isSupported {
                    ContentUnavailableView(
                        "지원되지 않는 기기",
                        systemImage: "bolt.slash",
                        description: Text("이 기기에서는 EnergyKit을 사용할 수 없습니다")
                    )
                } else if !viewModel.isAuthorized {
                    VStack(spacing: 20) {
                        Image(systemName: "bolt.shield")
                            .font(.system(size: 60))
                            .foregroundStyle(.yellow)
                        
                        Text("에너지 데이터 접근")
                            .font(.title2.bold())
                        
                        Text("에너지 사용량을 분석하고 절약 팁을 제공하기 위해 데이터 접근 권한이 필요합니다.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        Button("권한 허용") {
                            Task {
                                await viewModel.requestAuthorization()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if viewModel.isLoading {
                    ProgressView("데이터 로딩 중...")
                        .padding(.top, 100)
                } else {
                    VStack(spacing: 20) {
                        // 오늘의 사용량
                        if let usage = viewModel.todayUsage {
                            TodayUsageCard(usage: usage)
                        }
                        
                        // 전력망 상태
                        if let grid = viewModel.gridStatus {
                            GridStatusCard(status: grid)
                        }
                        
                        // 주간 차트
                        if !viewModel.weeklyUsage.isEmpty {
                            WeeklyChartCard(data: viewModel.weeklyUsage)
                        }
                        
                        // 절약 팁
                        SavingTipsCard(gridStatus: viewModel.gridStatus)
                    }
                    .padding()
                }
                
                // 에러 표시
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
            .navigationTitle("에너지")
            .refreshable {
                await viewModel.fetchData()
            }
            .task {
                viewModel.checkAuthorization()
                if viewModel.isAuthorized {
                    await viewModel.fetchData()
                }
            }
        }
    }
}

// MARK: - Today Usage Card
struct TodayUsageCard: View {
    let usage: EnergyUsage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.yellow)
                Text("오늘의 사용량")
                    .font(.headline)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(String(format: "%.1f", usage.totalConsumption))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                Text("kWh")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("피크")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f kWh", usage.peakConsumption))
                        .font(.subheadline.bold())
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("비피크")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f kWh", usage.offPeakConsumption))
                        .font(.subheadline.bold())
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("탄소")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f kg", usage.carbonFootprint))
                        .font(.subheadline.bold())
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Grid Status Card
struct GridStatusCard: View {
    let status: GridStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "globe")
                    .foregroundStyle(.green)
                Text("전력망 상태")
                    .font(.headline)
                
                Spacer()
                
                if status.isLowCarbonTime {
                    Label("저탄소 시간", systemImage: "leaf.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.2), in: Capsule())
                }
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text("재생에너지")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(status.renewablePercent))")
                            .font(.title.bold())
                        Text("%")
                            .foregroundStyle(.secondary)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("탄소 집약도")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(status.carbonIntensity))")
                            .font(.title.bold())
                        Text("g/kWh")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // 재생에너지 비율 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.green)
                        .frame(width: geometry.size.width * status.renewablePercent / 100)
                }
            }
            .frame(height: 8)
            
            if let nextLowCarbon = status.nextLowCarbonTime {
                Text("다음 저탄소 시간: \(nextLowCarbon.formatted(.dateTime.hour().minute()))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Weekly Chart Card
struct WeeklyChartCard: View {
    let data: [DailyUsage]
    
    var maxUsage: Double {
        data.map(\.usage.totalConsumption).max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.blue)
                Text("주간 사용량")
                    .font(.headline)
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { daily in
                    VStack(spacing: 4) {
                        Text(String(format: "%.0f", daily.usage.totalConsumption))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.blue.gradient)
                            .frame(height: CGFloat(daily.usage.totalConsumption / maxUsage) * 100)
                        
                        Text(daily.dayName)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Saving Tips Card
struct SavingTipsCard: View {
    let gridStatus: GridStatus?
    
    var tips: [String] {
        var result = [
            "세탁기와 식기세척기는 비피크 시간대에 사용하세요",
            "에어컨 온도를 1도 높이면 에너지 3% 절약",
            "대기전력 차단을 위해 멀티탭 스위치를 끄세요"
        ]
        
        if let status = gridStatus {
            if status.isLowCarbonTime {
                result.insert("지금은 저탄소 시간! 전기 사용에 좋은 때입니다", at: 0)
            }
            if status.renewablePercent > 50 {
                result.insert("재생에너지 비율이 높습니다. 친환경 전력 사용 중!", at: 0)
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.orange)
                Text("절약 팁")
                    .font(.headline)
            }
            
            ForEach(tips.prefix(3), id: \.self) { tip in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                    Text(tip)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    EnergyDashboardView()
}
```

## 고급 패턴

### 1. 에너지 절약 알림

```swift
import UserNotifications

func scheduleEnergyAlerts() async {
    let gridStatus = try await energyManager.fetchGridStatus()
    
    // 저탄소 시간대 알림
    if let nextLowCarbon = gridStatus.nextLowCarbonTime {
        let content = UNMutableNotificationContent()
        content.title = "저탄소 시간대 시작"
        content.body = "지금 전기를 사용하면 탄소 배출이 적습니다!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: nextLowCarbon.timeIntervalSinceNow,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "lowCarbon",
            content: content,
            trigger: trigger
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
}
```

### 2. HomeKit 연동

```swift
import HomeKit

class SmartEnergyManager {
    let homeManager = HMHomeManager()
    let energyManager = EnergyManager.shared
    
    func optimizeDevices() async throws {
        let gridStatus = try await energyManager.fetchGridStatus()
        
        // 고탄소 시간대에는 불필요한 기기 끄기
        if !gridStatus.isLowCarbonTime {
            for home in homeManager.homes {
                for accessory in home.accessories {
                    // 비필수 기기 식별 및 제어
                    if isNonEssential(accessory) {
                        try await turnOff(accessory)
                    }
                }
            }
        }
    }
}
```

### 3. 위젯

```swift
import WidgetKit

struct EnergyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "EnergyWidget", provider: EnergyTimelineProvider()) { entry in
            EnergyWidgetView(entry: entry)
        }
        .configurationDisplayName("에너지 현황")
        .description("오늘의 에너지 사용량과 전력망 상태를 표시합니다")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct EnergyWidgetView: View {
    let entry: EnergyEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.yellow)
                Text("\(String(format: "%.1f", entry.usage)) kWh")
                    .font(.headline)
            }
            
            if entry.isLowCarbonTime {
                Label("저탄소 시간", systemImage: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .containerBackground(.fill, for: .widget)
    }
}
```

## 주의사항

1. **iOS 버전**
   - EnergyKit: iOS 18+ 필요
   - 이전 버전에서는 사용 불가

2. **지역 제한**
   - 에너지 데이터 제공 지역에서만 동작
   - 모든 국가/지역에서 지원되지 않음

3. **스마트 미터 연동**
   - 스마트 미터가 설치된 가정에서만 상세 데이터 제공
   - 미설치 시 추정 데이터 제공

4. **개인정보**
   - 에너지 사용 데이터는 민감 정보
   - 명확한 사용 목적 고지 필요

5. **시뮬레이터**
   - 시뮬레이터에서 모의 데이터 제공
   - 실제 데이터는 실기기 필요
