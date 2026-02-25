# WeatherKit AI Reference

> 날씨 데이터 앱 구현 가이드. 이 문서를 읽고 WeatherKit 코드를 생성할 수 있습니다.

## 개요

WeatherKit은 Apple의 날씨 서비스로, 현재 날씨, 시간별/일별 예보, 심각한 기상 경보 등을 제공합니다.
월 50만 회 무료 API 호출이 포함되며, Apple Developer 계정이 필요합니다.

## 필수 Import

```swift
import WeatherKit
import CoreLocation
```

## 프로젝트 설정

### 1. Capability 추가
Xcode > Signing & Capabilities > + WeatherKit

### 2. App ID 설정
Apple Developer Console에서 WeatherKit 서비스 활성화

```xml
<!-- Info.plist (위치 권한) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>현재 위치의 날씨를 확인하기 위해 필요합니다.</string>
```

## 핵심 구성요소

### 1. WeatherService

```swift
import WeatherKit
import CoreLocation

// 날씨 서비스 인스턴스
let weatherService = WeatherService.shared

// 위치 기반 날씨 요청
func getWeather(for location: CLLocation) async throws -> Weather {
    try await weatherService.weather(for: location)
}
```

### 2. 날씨 데이터 타입

```swift
// 현재 날씨
let current: CurrentWeather = weather.currentWeather
current.temperature        // Measurement<UnitTemperature>
current.apparentTemperature // 체감 온도
current.humidity           // 습도 (0.0 ~ 1.0)
current.condition          // WeatherCondition (sunny, cloudy 등)
current.symbolName         // SF Symbol 이름

// 시간별 예보
let hourly: Forecast<HourWeather> = weather.hourlyForecast
for hour in hourly {
    hour.date
    hour.temperature
    hour.precipitationChance
}

// 일별 예보
let daily: Forecast<DayWeather> = weather.dailyForecast
for day in daily {
    day.date
    day.highTemperature
    day.lowTemperature
    day.precipitationChance
}
```

### 3. 기상 경보

```swift
// 심각한 기상 경보
let alerts: [WeatherAlert]? = weather.weatherAlerts
for alert in alerts ?? [] {
    alert.summary
    alert.severity  // .minor, .moderate, .severe, .extreme
    alert.region
}
```

## 전체 작동 예제

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
            errorMessage = "날씨를 불러올 수 없습니다: \(error.localizedDescription)"
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
                    ProgressView("날씨 불러오는 중...")
                        .padding(.top, 100)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView(
                        "오류 발생",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if let current = viewModel.currentWeather {
                    VStack(spacing: 24) {
                        // 현재 날씨
                        CurrentWeatherCard(weather: current)
                        
                        // 시간별 예보
                        HourlyForecastView(forecast: viewModel.hourlyForecast)
                        
                        // 일별 예보
                        DailyForecastView(forecast: viewModel.dailyForecast)
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "위치 권한 필요",
                        systemImage: "location.slash",
                        description: Text("날씨를 확인하려면 위치 권한이 필요합니다.")
                    )
                    .onTapGesture {
                        locationManager.requestLocation()
                    }
                }
            }
            .navigationTitle("날씨")
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
                    Text("체감 \(weather.apparentTemperature.formatted(.measurement(width: .abbreviated)))")
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
            Label("시간별 예보", systemImage: "clock")
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
            Label("7일 예보", systemImage: "calendar")
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

## 고급 패턴

### 1. 특정 데이터만 요청

```swift
// 필요한 데이터셋만 요청 (성능 최적화)
let (current, hourly) = try await weatherService.weather(
    for: location,
    including: .current, .hourly
)

// 일별 예보만 요청
let daily = try await weatherService.weather(
    for: location,
    including: .daily
)
```

### 2. Attribution 표시 (필수)

```swift
struct WeatherAttributionView: View {
    var body: some View {
        VStack {
            // ... 날씨 UI
            
            // Apple Weather 출처 표시 (필수)
            AsyncImage(url: WeatherService.shared.attribution.combinedMarkDarkURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                EmptyView()
            }
            .frame(height: 12)
            
            Link("데이터 출처", destination: WeatherService.shared.attribution.legalPageURL)
                .font(.caption2)
        }
    }
}
```

### 3. 기상 경보 처리

```swift
func checkWeatherAlerts(for location: CLLocation) async {
    do {
        let weather = try await weatherService.weather(for: location)
        
        if let alerts = weather.weatherAlerts, !alerts.isEmpty {
            for alert in alerts {
                switch alert.severity {
                case .extreme, .severe:
                    // 긴급 알림 표시
                    showUrgentAlert(alert)
                case .moderate:
                    // 일반 알림
                    showWarning(alert)
                case .minor:
                    // 참고 정보
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

### 4. UV 지수 및 상세 정보

```swift
// 현재 날씨 상세 정보
let current = weather.currentWeather

let uvIndex = current.uvIndex           // UV 지수
let visibility = current.visibility     // 가시거리
let pressure = current.pressure         // 기압
let dewPoint = current.dewPoint         // 이슬점
let windSpeed = current.wind.speed      // 풍속
let windDirection = current.wind.direction // 풍향
let cloudCover = current.cloudCover     // 구름량 (0.0 ~ 1.0)
```

## 주의사항

1. **Attribution 필수**
   - WeatherKit 사용 시 Apple Weather 출처 표시 필수
   - `WeatherService.shared.attribution` 사용

2. **API 호출 제한**
   - 무료: 월 50만 회
   - 초과 시 유료 (Apple Developer 대시보드에서 확인)

3. **위치 권한**
   - WeatherKit 자체는 위치 권한 불필요
   - 현재 위치 날씨를 위해선 CoreLocation 필요

4. **오프라인 처리**
   - 네트워크 필요 (오프라인 캐싱 없음)
   - 적절한 에러 처리 필수

5. **지역 제한**
   - 일부 국가에서 기상 경보 미지원
   - 데이터 가용성은 지역마다 다름
