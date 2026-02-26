# WeatherKit AI Reference

> Weather data app implementation guide. Read this document to generate WeatherKit code.

## Overview

WeatherKit is Apple's weather service that provides current weather, hourly/daily forecasts, severe weather alerts, and more.
It includes 500,000 free API calls per month and requires an Apple Developer account.

## Required Import

```swift
import WeatherKit
import CoreLocation
```

## Project Setup

### 1. Add Capability
Xcode > Signing & Capabilities > + WeatherKit

### 2. App ID Configuration
Enable WeatherKit service in Apple Developer Console

```xml
<!-- Info.plist (Location permission) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Required to check weather at your current location.</string>
```

## Core Components

### 1. WeatherService

```swift
import WeatherKit
import CoreLocation

// Weather service instance
let weatherService = WeatherService.shared

// Location-based weather request
func getWeather(for location: CLLocation) async throws -> Weather {
    try await weatherService.weather(for: location)
}
```

### 2. Weather Data Types

```swift
// Current weather
let current: CurrentWeather = weather.currentWeather
current.temperature        // Measurement<UnitTemperature>
current.apparentTemperature // Feels like temperature
current.humidity           // Humidity (0.0 ~ 1.0)
current.condition          // WeatherCondition (sunny, cloudy, etc.)
current.symbolName         // SF Symbol name

// Hourly forecast
let hourly: Forecast<HourWeather> = weather.hourlyForecast
for hour in hourly {
    hour.date
    hour.temperature
    hour.precipitationChance
}

// Daily forecast
let daily: Forecast<DayWeather> = weather.dailyForecast
for day in daily {
    day.date
    day.highTemperature
    day.lowTemperature
    day.precipitationChance
}
```

### 3. Weather Alerts

```swift
// Severe weather alerts
let alerts: [WeatherAlert]? = weather.weatherAlerts
for alert in alerts ?? [] {
    alert.summary
    alert.severity  // .minor, .moderate, .severe, .extreme
    alert.region
}
```

## Complete Working Example

```swift
import SwiftUI
import WeatherKit
import CoreLocation

// MARK: - Weather ViewModel
@Observable
class WeatherViewModel {
    var currentWeather: CurrentWeather?
    var hourlyForecast: [HourWeather] = []
    var dailyForecast: [DayWeather] = []
    var isLoading = false
    var errorMessage: String?
    
    private let weatherService = WeatherService.shared
    
    func fetchWeather(for location: CLLocation) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let weather = try await weatherService.weather(for: location)
            
            currentWeather = weather.currentWeather
            hourlyForecast = Array(weather.hourlyForecast.prefix(24))
            dailyForecast = Array(weather.dailyForecast.prefix(7))
        } catch {
            errorMessage = "Unable to load weather: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Location Manager
@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    var location: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

// MARK: - Main View
struct WeatherView: View {
    @State private var viewModel = WeatherViewModel()
    @State private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Loading weather...")
                        .padding(.top, 100)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Error Occurred",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if let current = viewModel.currentWeather {
                    VStack(spacing: 24) {
                        // Current weather
                        CurrentWeatherCard(weather: current)
                        
                        // Hourly forecast
                        HourlyForecastView(forecast: viewModel.hourlyForecast)
                        
                        // Daily forecast
                        DailyForecastView(forecast: viewModel.dailyForecast)
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "Location Permission Required",
                        systemImage: "location.slash",
                        description: Text("Location permission is needed to check weather.")
                    )
                    .onTapGesture {
                        locationManager.requestLocation()
                    }
                }
            }
            .navigationTitle("Weather")
            .refreshable {
                if let location = locationManager.location {
                    await viewModel.fetchWeather(for: location)
                }
            }
        }
        .task {
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            if let location = newLocation {
                Task {
                    await viewModel.fetchWeather(for: location)
                }
            }
        }
    }
}

// MARK: - Current Weather Card
struct CurrentWeatherCard: View {
    let weather: CurrentWeather
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: weather.symbolName)
                .font(.system(size: 64))
                .symbolRenderingMode(.multicolor)
            
            Text(weather.temperature.formatted(.measurement(width: .abbreviated)))
                .font(.system(size: 48, weight: .thin))
            
            Text(weather.condition.description)
                .font(.title3)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 24) {
                Label {
                    Text("Feels like \(weather.apparentTemperature.formatted(.measurement(width: .abbreviated)))")
                } icon: {
                    Image(systemName: "thermometer.medium")
                }
                
                Label {
                    Text("\(Int(weather.humidity * 100))%")
                } icon: {
                    Image(systemName: "humidity")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Hourly Forecast
struct HourlyForecastView: View {
    let forecast: [HourWeather]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Hourly Forecast", systemImage: "clock")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(forecast, id: \.date) { hour in
                        VStack(spacing: 8) {
                            Text(hour.date.formatted(.dateTime.hour()))
                                .font(.caption)
                            
                            Image(systemName: hour.symbolName)
                                .font(.title2)
                                .symbolRenderingMode(.multicolor)
                            
                            Text(hour.temperature.formatted(.measurement(width: .narrow)))
                                .font(.subheadline)
                        }
                        .frame(width: 60)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Daily Forecast
struct DailyForecastView: View {
    let forecast: [DayWeather]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("7-Day Forecast", systemImage: "calendar")
                .font(.headline)
            
            ForEach(forecast, id: \.date) { day in
                HStack {
                    Text(day.date.formatted(.dateTime.weekday(.wide)))
                        .frame(width: 80, alignment: .leading)
                    
                    Image(systemName: day.symbolName)
                        .symbolRenderingMode(.multicolor)
                        .frame(width: 32)
                    
                    Spacer()
                    
                    Text(day.lowTemperature.formatted(.measurement(width: .narrow)))
                        .foregroundStyle(.secondary)
                    
                    TemperatureBar(
                        low: day.lowTemperature.value,
                        high: day.highTemperature.value
                    )
                    .frame(width: 80)
                    
                    Text(day.highTemperature.formatted(.measurement(width: .narrow)))
                }
                .font(.subheadline)
                
                if day.date != forecast.last?.date {
                    Divider()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Temperature Bar
struct TemperatureBar: View {
    let low: Double
    let high: Double
    
    var body: some View {
        GeometryReader { geometry in
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.blue, .yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 4)
                .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview {
    WeatherView()
}
```

## Advanced Patterns

### 1. Request Specific Data Only

```swift
// Request only needed datasets (performance optimization)
let (current, hourly) = try await weatherService.weather(
    for: location,
    including: .current, .hourly
)

// Request daily forecast only
let daily = try await weatherService.weather(
    for: location,
    including: .daily
)
```

### 2. Display Attribution (Required)

```swift
struct WeatherAttributionView: View {
    var body: some View {
        VStack {
            // ... Weather UI
            
            // Apple Weather attribution (required)
            AsyncImage(url: WeatherService.shared.attribution.combinedMarkDarkURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                EmptyView()
            }
            .frame(height: 12)
            
            Link("Data Source", destination: WeatherService.shared.attribution.legalPageURL)
                .font(.caption2)
        }
    }
}
```

### 3. Weather Alert Handling

```swift
func checkWeatherAlerts(for location: CLLocation) async {
    do {
        let weather = try await weatherService.weather(for: location)
        
        if let alerts = weather.weatherAlerts, !alerts.isEmpty {
            for alert in alerts {
                switch alert.severity {
                case .extreme, .severe:
                    // Show urgent notification
                    showUrgentAlert(alert)
                case .moderate:
                    // General warning
                    showWarning(alert)
                case .minor:
                    // Informational
                    logInfo(alert)
                default:
                    break
                }
            }
        }
    } catch {
        print("Weather alert check failed: \(error)")
    }
}
```

### 4. UV Index and Detailed Information

```swift
// Current weather details
let current = weather.currentWeather

let uvIndex = current.uvIndex           // UV index
let visibility = current.visibility     // Visibility
let pressure = current.pressure         // Air pressure
let dewPoint = current.dewPoint         // Dew point
let windSpeed = current.wind.speed      // Wind speed
let windDirection = current.wind.direction // Wind direction
let cloudCover = current.cloudCover     // Cloud cover (0.0 ~ 1.0)
```

## Important Notes

1. **Attribution Required**
   - Apple Weather attribution must be displayed when using WeatherKit
   - Use `WeatherService.shared.attribution`

2. **API Call Limits**
   - Free: 500,000 calls per month
   - Overage is charged (check Apple Developer dashboard)

3. **Location Permission**
   - WeatherKit itself doesn't require location permission
   - CoreLocation needed for current location weather

4. **Offline Handling**
   - Network required (no offline caching)
   - Proper error handling essential

5. **Regional Limitations**
   - Weather alerts not supported in some countries
   - Data availability varies by region
