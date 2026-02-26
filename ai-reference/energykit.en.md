# EnergyKit AI Reference

> Energy data app implementation guide. Read this document to generate EnergyKit code.

## Overview

EnergyKit is an energy usage and grid data access framework available on iOS 18+.
It enables development of energy efficiency apps using information such as user power usage patterns, solar generation, and carbon footprint.

## Required Import

```swift
import EnergyKit
```

## Project Setup

### 1. Add Capability
Xcode > Signing & Capabilities > + EnergyKit

### 2. Info.plist

```xml
<key>NSEnergyUsageDescription</key>
<string>Required to analyze energy usage patterns.</string>
```

## Core Components

### 1. EnergyManager

```swift
import EnergyKit

// Energy manager instance
let energyManager = EnergyManager.shared

// Request authorization
func requestAccess() async throws -> Bool {
    try await energyManager.requestAuthorization()
}

// Authorization status
let status = energyManager.authorizationStatus
```

### 2. EnergyUsage (Usage Data)

```swift
// Today's energy usage
let usage = try await energyManager.fetchUsage(for: .today)

usage.totalConsumption    // Total consumption (kWh)
usage.peakDemand          // Peak demand
usage.offPeakConsumption  // Off-peak consumption
usage.carbonFootprint     // Carbon footprint (kg CO2)
```

### 3. GridStatus (Grid Status)

```swift
// Current grid status
let gridStatus = try await energyManager.fetchGridStatus()

gridStatus.carbonIntensity    // Carbon intensity (g CO2/kWh)
gridStatus.renewablePercent   // Renewable energy percentage
gridStatus.isLowCarbonTime    // Low carbon time indicator
gridStatus.nextLowCarbonTime  // Next low carbon time period
```

## Complete Working Example

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
            errorMessage = "Authorization request failed: \(error.localizedDescription)"
        }
    }
    
    func fetchData() async {
        guard isAuthorized else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Today's usage
            todayUsage = try await energyManager.fetchUsage(for: .today)
            
            // Weekly usage
            let calendar = Calendar.current
            var daily: [DailyUsage] = []
            
            for dayOffset in 0..<7 {
                let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
                let usage = try await energyManager.fetchUsage(for: date)
                daily.append(DailyUsage(date: date, usage: usage))
            }
            weeklyUsage = daily.reversed()
            
            // Grid status
            gridStatus = try await energyManager.fetchGridStatus()
            
        } catch {
            errorMessage = "Data load failed: \(error.localizedDescription)"
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
        formatter.locale = Locale(identifier: "en_US")
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
                        "Device Not Supported",
                        systemImage: "bolt.slash",
                        description: Text("EnergyKit is not available on this device")
                    )
                } else if !viewModel.isAuthorized {
                    VStack(spacing: 20) {
                        Image(systemName: "bolt.shield")
                            .font(.system(size: 60))
                            .foregroundStyle(.yellow)
                        
                        Text("Energy Data Access")
                            .font(.title2.bold())
                        
                        Text("Data access permission is required to analyze energy usage and provide saving tips.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        Button("Allow Permission") {
                            Task {
                                await viewModel.requestAuthorization()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if viewModel.isLoading {
                    ProgressView("Loading data...")
                        .padding(.top, 100)
                } else {
                    VStack(spacing: 20) {
                        // Today's usage
                        if let usage = viewModel.todayUsage {
                            TodayUsageCard(usage: usage)
                        }
                        
                        // Grid status
                        if let grid = viewModel.gridStatus {
                            GridStatusCard(status: grid)
                        }
                        
                        // Weekly chart
                        if !viewModel.weeklyUsage.isEmpty {
                            WeeklyChartCard(data: viewModel.weeklyUsage)
                        }
                        
                        // Saving tips
                        SavingTipsCard(gridStatus: viewModel.gridStatus)
                    }
                    .padding()
                }
                
                // Error display
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
            .navigationTitle("Energy")
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
                Text("Today's Usage")
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
                    Text("Peak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f kWh", usage.peakConsumption))
                        .font(.subheadline.bold())
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Off-Peak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f kWh", usage.offPeakConsumption))
                        .font(.subheadline.bold())
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Carbon")
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
                Text("Grid Status")
                    .font(.headline)
                
                Spacer()
                
                if status.isLowCarbonTime {
                    Label("Low Carbon Time", systemImage: "leaf.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.2), in: Capsule())
                }
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text("Renewable")
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
                    Text("Carbon Intensity")
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
            
            // Renewable energy percentage bar
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
                Text("Next low carbon time: \(nextLowCarbon.formatted(.dateTime.hour().minute()))")
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
                Text("Weekly Usage")
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
            "Use washing machines and dishwashers during off-peak hours",
            "Raising AC temperature by 1 degree saves 3% energy",
            "Turn off power strips to cut standby power consumption"
        ]
        
        if let status = gridStatus {
            if status.isLowCarbonTime {
                result.insert("It's low carbon time now! Good time to use electricity", at: 0)
            }
            if status.renewablePercent > 50 {
                result.insert("High renewable energy ratio. Using eco-friendly power!", at: 0)
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.orange)
                Text("Saving Tips")
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

## Advanced Patterns

### 1. Energy Saving Alerts

```swift
import UserNotifications

func scheduleEnergyAlerts() async {
    let gridStatus = try await energyManager.fetchGridStatus()
    
    // Low carbon time alert
    if let nextLowCarbon = gridStatus.nextLowCarbonTime {
        let content = UNMutableNotificationContent()
        content.title = "Low Carbon Time Starting"
        content.body = "Using electricity now will result in lower carbon emissions!"
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

### 2. HomeKit Integration

```swift
import HomeKit

class SmartEnergyManager {
    let homeManager = HMHomeManager()
    let energyManager = EnergyManager.shared
    
    func optimizeDevices() async throws {
        let gridStatus = try await energyManager.fetchGridStatus()
        
        // Turn off non-essential devices during high carbon time
        if !gridStatus.isLowCarbonTime {
            for home in homeManager.homes {
                for accessory in home.accessories {
                    // Identify and control non-essential devices
                    if isNonEssential(accessory) {
                        try await turnOff(accessory)
                    }
                }
            }
        }
    }
}
```

### 3. Widget

```swift
import WidgetKit

struct EnergyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "EnergyWidget", provider: EnergyTimelineProvider()) { entry in
            EnergyWidgetView(entry: entry)
        }
        .configurationDisplayName("Energy Status")
        .description("Displays today's energy usage and grid status")
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
                Label("Low Carbon Time", systemImage: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .containerBackground(.fill, for: .widget)
    }
}
```

## Important Notes

1. **iOS Version**
   - EnergyKit: Requires iOS 18+
   - Not available on earlier versions

2. **Regional Limitations**
   - Only works in regions where energy data is provided
   - Not supported in all countries/regions

3. **Smart Meter Integration**
   - Detailed data only available in homes with smart meters installed
   - Estimated data provided when not installed

4. **Privacy**
   - Energy usage data is sensitive information
   - Clear disclosure of usage purpose required

5. **Simulator**
   - Mock data provided in simulator
   - Real device needed for actual data
