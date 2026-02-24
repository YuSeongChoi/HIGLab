//
//  WeatherService.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 2/24/26.
//

import Foundation
import CoreLocation

// MARK: - Weather Service
// WeatherKit 사용 시 실제 API로 교체 가능한 구조
// HIG: 데이터 갱신은 사용자 경험에 영향을 주지 않도록 백그라운드에서 처리

/// 날씨 데이터 제공 서비스 (Actor로 thread-safe 보장)
actor WeatherService {
    
    // MARK: - Singleton
    
    static let shared = WeatherService()
    private init() {}
    
    // MARK: - 캐시
    
    /// 메모리 캐시 (도시별)
    private var weatherCache: [CityOption: CachedWeather] = [:]
    private var airQualityCache: [CityOption: CachedAirQuality] = [:]
    private var uvIndexCache: [CityOption: CachedUVIndex] = [:]
    
    /// 캐시 유효 시간 (분)
    private let weatherCacheValidMinutes: Int = 10
    private let airQualityCacheValidMinutes: Int = 30
    private let uvIndexCacheValidMinutes: Int = 30
    
    // MARK: - 날씨 데이터 조회
    
    /// 도시별 날씨 데이터 가져오기
    /// - Parameter city: 조회할 도시
    /// - Returns: 날씨 데이터
    func fetchWeather(for city: CityOption = .seoul) async -> WeatherData {
        // 캐시 확인
        if let cached = weatherCache[city], !cached.isExpired(minutes: weatherCacheValidMinutes) {
            return cached.data
        }
        
        // 실제 앱에서는 WeatherKit API 호출:
        // let weather = try await WeatherKit.WeatherService.shared.weather(for: city.coordinate)
        
        // Mock 데이터 생성 (시뮬레이션)
        let weatherData = await generateMockWeather(for: city)
        
        // 캐시 저장
        weatherCache[city] = CachedWeather(data: weatherData)
        
        return weatherData
    }
    
    /// 대기질 데이터 가져오기
    /// - Parameter city: 조회할 도시
    /// - Returns: 대기질 데이터
    func fetchAirQuality(for city: CityOption = .seoul) async -> AirQualityData {
        // 캐시 확인
        if let cached = airQualityCache[city], !cached.isExpired(minutes: airQualityCacheValidMinutes) {
            return cached.data
        }
        
        // Mock 데이터 생성
        let airQualityData = generateMockAirQuality(for: city)
        
        // 캐시 저장
        airQualityCache[city] = CachedAirQuality(data: airQualityData)
        
        return airQualityData
    }
    
    /// 자외선 지수 데이터 가져오기
    /// - Parameter city: 조회할 도시
    /// - Returns: 자외선 지수 데이터
    func fetchUVIndex(for city: CityOption = .seoul) async -> UVIndexData {
        // 캐시 확인
        if let cached = uvIndexCache[city], !cached.isExpired(minutes: uvIndexCacheValidMinutes) {
            return cached.data
        }
        
        // Mock 데이터 생성
        let uvIndexData = generateMockUVIndex(for: city)
        
        // 캐시 저장
        uvIndexCache[city] = CachedUVIndex(data: uvIndexData)
        
        return uvIndexData
    }
    
    /// 캐시 초기화
    func clearCache() {
        weatherCache.removeAll()
        airQualityCache.removeAll()
        uvIndexCache.removeAll()
    }
    
    /// 특정 도시 캐시만 초기화
    func clearCache(for city: CityOption) {
        weatherCache.removeValue(forKey: city)
        airQualityCache.removeValue(forKey: city)
        uvIndexCache.removeValue(forKey: city)
    }
    
    // MARK: - Mock 데이터 생성
    
    /// 도시별 Mock 날씨 데이터 생성
    private func generateMockWeather(for city: CityOption) async -> WeatherData {
        // 네트워크 지연 시뮬레이션
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초
        
        let baseCondition = city.mockCondition
        let baseTemp = city.mockBaseTemperature
        
        let calendar = Calendar.current
        let now = Date()
        
        // 오늘 일출/일몰 시간 계산
        var sunriseComponents = calendar.dateComponents([.year, .month, .day], from: now)
        sunriseComponents.hour = 6
        sunriseComponents.minute = Int.random(in: 0...30)
        let sunrise = calendar.date(from: sunriseComponents) ?? now
        
        var sunsetComponents = calendar.dateComponents([.year, .month, .day], from: now)
        sunsetComponents.hour = 18
        sunsetComponents.minute = Int.random(in: 30...59)
        let sunset = calendar.date(from: sunsetComponents) ?? now
        
        return WeatherData(
            cityName: city.displayName,
            temperature: baseTemp + Int.random(in: -2...2),
            feelsLike: baseTemp + Int.random(in: -4...0),
            highTemperature: baseTemp + Int.random(in: 3...6),
            lowTemperature: baseTemp - Int.random(in: 5...8),
            condition: baseCondition,
            humidity: Int.random(in: 40...80),
            windSpeed: Double.random(in: 1.0...8.0),
            windDirection: WindDirection.allCases.randomElement() ?? .north,
            pressure: Int.random(in: 1010...1025),
            visibility: Double.random(in: 8.0...20.0),
            dewPoint: baseTemp - Int.random(in: 8...15),
            hourlyForecast: generateHourlyForecast(baseTemp: baseTemp, baseCondition: baseCondition),
            dailyForecast: generateDailyForecast(baseTemp: baseTemp),
            sunrise: sunrise,
            sunset: sunset,
            lastUpdated: now
        )
    }
    
    /// 시간별 예보 생성 (24시간)
    private func generateHourlyForecast(baseTemp: Int, baseCondition: WeatherCondition) -> [HourlyWeather] {
        let calendar = Calendar.current
        var forecasts: [HourlyWeather] = []
        
        let conditions: [WeatherCondition] = [
            baseCondition, baseCondition, baseCondition,
            .cloudy, .cloudy, .partlyCloudy,
            baseCondition, baseCondition, .cloudy,
            .cloudy, baseCondition, baseCondition
        ]
        
        for i in 0..<24 {
            guard let hourDate = calendar.date(byAdding: .hour, value: i, to: Date()) else { continue }
            
            let hour = calendar.component(.hour, from: hourDate)
            
            // 시간대별 온도 변화 (오후 2-3시 최고, 새벽 4-5시 최저)
            let tempVariation: Int
            switch hour {
            case 0...5: tempVariation = -5
            case 6...9: tempVariation = -2
            case 10...13: tempVariation = 2
            case 14...16: tempVariation = 4
            case 17...20: tempVariation = 1
            default: tempVariation = -2
            }
            
            let condition = conditions[i % conditions.count]
            let precipChance = condition.needsUmbrella ? Int.random(in: 40...90) : Int.random(in: 0...20)
            
            forecasts.append(HourlyWeather(
                date: hourDate,
                temperature: baseTemp + tempVariation + Int.random(in: -1...1),
                condition: condition,
                precipitationChance: precipChance,
                humidity: Int.random(in: 40...80),
                windSpeed: Double.random(in: 1.0...6.0),
                uvIndex: (hour >= 6 && hour <= 18) ? Int.random(in: 1...8) : 0
            ))
        }
        
        return forecasts
    }
    
    /// 일별 예보 생성 (7일)
    private func generateDailyForecast(baseTemp: Int) -> [DailyWeather] {
        let calendar = Calendar.current
        var forecasts: [DailyWeather] = []
        
        let conditions: [WeatherCondition] = [
            .sunny, .partlyCloudy, .cloudy, .rainy, .cloudy, .sunny, .sunny
        ]
        
        let moonPhases: [MoonPhase] = MoonPhase.allCases
        
        for i in 0..<7 {
            guard let dayDate = calendar.date(byAdding: .day, value: i, to: Date()) else { continue }
            
            let condition = conditions[i]
            let precipChance = condition.needsUmbrella ? Int.random(in: 60...90) : Int.random(in: 0...30)
            
            // 일출/일몰
            var sunriseComponents = calendar.dateComponents([.year, .month, .day], from: dayDate)
            sunriseComponents.hour = 6
            sunriseComponents.minute = Int.random(in: 0...30)
            let sunrise = calendar.date(from: sunriseComponents) ?? dayDate
            
            var sunsetComponents = calendar.dateComponents([.year, .month, .day], from: dayDate)
            sunsetComponents.hour = 18
            sunsetComponents.minute = Int.random(in: 30...59)
            let sunset = calendar.date(from: sunsetComponents) ?? dayDate
            
            forecasts.append(DailyWeather(
                date: dayDate,
                high: baseTemp + Int.random(in: 2...5),
                low: baseTemp - Int.random(in: 4...7),
                condition: condition,
                precipitationChance: precipChance,
                sunrise: sunrise,
                sunset: sunset,
                uvIndex: Int.random(in: 3...9),
                moonPhase: moonPhases[(i + 3) % moonPhases.count]
            ))
        }
        
        return forecasts
    }
    
    /// 대기질 Mock 데이터 생성
    private func generateMockAirQuality(for city: CityOption) -> AirQualityData {
        let aqi = city.mockAQI
        let pm25 = Double(aqi) * 0.35 + Double.random(in: -5...5)
        let pm10 = Double(aqi) * 0.7 + Double.random(in: -10...10)
        
        return AirQualityData(
            aqi: aqi,
            category: AirQualityLevel(aqi: aqi),
            pm25: max(0, pm25),
            pm10: max(0, pm10),
            o3: Double.random(in: 20...60),
            no2: Double.random(in: 10...40),
            co: Double.random(in: 0.2...0.8),
            so2: Double.random(in: 1...10),
            dominantPollutant: aqi > 80 ? .pm25 : [.pm25, .pm10, .ozone].randomElement()!,
            lastUpdated: Date()
        )
    }
    
    /// 자외선 지수 Mock 데이터 생성
    private func generateMockUVIndex(for city: CityOption) -> UVIndexData {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        
        // 현재 시간대별 UV 지수 (낮 시간에 높음)
        let currentUV: Int
        switch hour {
        case 0...6: currentUV = 0
        case 7...8: currentUV = Int.random(in: 1...3)
        case 9...10: currentUV = Int.random(in: 3...5)
        case 11...14: currentUV = Int.random(in: 6...9)
        case 15...16: currentUV = Int.random(in: 4...6)
        case 17...18: currentUV = Int.random(in: 2...4)
        default: currentUV = 0
        }
        
        // 최대 UV 시간 (정오~오후 1시)
        var maxTimeComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        maxTimeComponents.hour = Int.random(in: 12...13)
        maxTimeComponents.minute = Int.random(in: 0...59)
        let maxTime = calendar.date(from: maxTimeComponents) ?? Date()
        
        // 시간별 UV 예보
        var hourlyUV: [HourlyUVIndex] = []
        for i in 0..<12 {
            guard let hourDate = calendar.date(byAdding: .hour, value: i, to: Date()) else { continue }
            let futureHour = calendar.component(.hour, from: hourDate)
            
            let uvValue: Int
            switch futureHour {
            case 0...6, 19...23: uvValue = 0
            case 7...8: uvValue = Int.random(in: 1...3)
            case 9...10: uvValue = Int.random(in: 3...5)
            case 11...14: uvValue = Int.random(in: 6...9)
            case 15...16: uvValue = Int.random(in: 4...6)
            case 17...18: uvValue = Int.random(in: 2...4)
            default: uvValue = 0
            }
            
            hourlyUV.append(HourlyUVIndex(date: hourDate, uvIndex: uvValue))
        }
        
        return UVIndexData(
            currentIndex: currentUV,
            maxIndex: Int.random(in: 7...10),
            maxTime: maxTime,
            level: UVLevel(index: currentUV),
            hourlyForecast: hourlyUV,
            lastUpdated: Date()
        )
    }
}

// MARK: - 캐시 구조체

/// 날씨 데이터 캐시
private struct CachedWeather {
    let data: WeatherData
    let cachedAt: Date
    
    init(data: WeatherData) {
        self.data = data
        self.cachedAt = Date()
    }
    
    func isExpired(minutes: Int) -> Bool {
        Date().timeIntervalSince(cachedAt) > Double(minutes * 60)
    }
}

/// 대기질 데이터 캐시
private struct CachedAirQuality {
    let data: AirQualityData
    let cachedAt: Date
    
    init(data: AirQualityData) {
        self.data = data
        self.cachedAt = Date()
    }
    
    func isExpired(minutes: Int) -> Bool {
        Date().timeIntervalSince(cachedAt) > Double(minutes * 60)
    }
}

/// 자외선 지수 데이터 캐시
private struct CachedUVIndex {
    let data: UVIndexData
    let cachedAt: Date
    
    init(data: UVIndexData) {
        self.data = data
        self.cachedAt = Date()
    }
    
    func isExpired(minutes: Int) -> Bool {
        Date().timeIntervalSince(cachedAt) > Double(minutes * 60)
    }
}

// MARK: - CityOption Extension

extension CityOption {
    /// 도시별 기본 온도 (테스트용)
    var mockBaseTemperature: Int {
        switch self {
        case .seoul: return 23
        case .busan: return 22
        case .jeju: return 26
        case .daejeon: return 24
        case .gwangju: return 25
        case .incheon: return 21
        case .daegu: return 28
        }
    }
    
    /// 도시별 기본 날씨 상태
    var mockCondition: WeatherCondition {
        switch self {
        case .seoul: return .sunny
        case .busan: return .partlyCloudy
        case .jeju: return .cloudy
        case .daejeon: return .sunny
        case .gwangju: return .sunny
        case .incheon: return .foggy
        case .daegu: return .sunny
        }
    }
    
    /// 도시별 대기질 (서울, 인천이 상대적으로 안좋음)
    var mockAQI: Int {
        switch self {
        case .seoul: return Int.random(in: 70...120)
        case .busan: return Int.random(in: 40...70)
        case .jeju: return Int.random(in: 20...45)
        case .daejeon: return Int.random(in: 50...80)
        case .gwangju: return Int.random(in: 45...75)
        case .incheon: return Int.random(in: 80...130)
        case .daegu: return Int.random(in: 60...90)
        }
    }
}

// MARK: - Preview 데이터

extension WeatherData {
    /// 미리보기용 기본 데이터
    static let preview = WeatherData(
        cityName: "서울",
        temperature: 23,
        feelsLike: 21,
        highTemperature: 27,
        lowTemperature: 18,
        condition: .sunny,
        humidity: 65,
        windSpeed: 3.2,
        windDirection: .southWest,
        pressure: 1015,
        visibility: 15.0,
        dewPoint: 15,
        hourlyForecast: [
            HourlyWeather(date: Date(), temperature: 23, condition: .sunny, precipitationChance: 10),
            HourlyWeather(date: Date().addingTimeInterval(3600), temperature: 24, condition: .sunny, precipitationChance: 10),
            HourlyWeather(date: Date().addingTimeInterval(7200), temperature: 25, condition: .partlyCloudy, precipitationChance: 20),
            HourlyWeather(date: Date().addingTimeInterval(10800), temperature: 24, condition: .cloudy, precipitationChance: 30),
            HourlyWeather(date: Date().addingTimeInterval(14400), temperature: 22, condition: .rainy, precipitationChance: 70),
            HourlyWeather(date: Date().addingTimeInterval(18000), temperature: 21, condition: .rainy, precipitationChance: 80),
        ],
        dailyForecast: [
            DailyWeather(date: Date(), high: 27, low: 18, condition: .sunny, precipitationChance: 10),
            DailyWeather(date: Date().addingTimeInterval(86400), high: 24, low: 16, condition: .rainy, precipitationChance: 70),
            DailyWeather(date: Date().addingTimeInterval(172800), high: 22, low: 15, condition: .cloudy, precipitationChance: 30),
            DailyWeather(date: Date().addingTimeInterval(259200), high: 25, low: 17, condition: .sunny, precipitationChance: 10),
            DailyWeather(date: Date().addingTimeInterval(345600), high: 26, low: 18, condition: .sunny, precipitationChance: 5),
        ],
        sunrise: Calendar.current.date(bySettingHour: 6, minute: 15, second: 0, of: Date()) ?? Date(),
        sunset: Calendar.current.date(bySettingHour: 18, minute: 45, second: 0, of: Date()) ?? Date(),
        lastUpdated: Date()
    )
    
    /// 비 오는 날 미리보기
    static let rainyPreview = WeatherData(
        cityName: "부산",
        temperature: 18,
        feelsLike: 16,
        highTemperature: 20,
        lowTemperature: 15,
        condition: .rainy,
        humidity: 85,
        windSpeed: 5.1,
        windDirection: .east,
        pressure: 1008,
        visibility: 8.0,
        dewPoint: 16,
        hourlyForecast: [
            HourlyWeather(date: Date(), temperature: 18, condition: .rainy, precipitationChance: 80),
            HourlyWeather(date: Date().addingTimeInterval(3600), temperature: 17, condition: .rainy, precipitationChance: 85),
            HourlyWeather(date: Date().addingTimeInterval(7200), temperature: 17, condition: .stormy, precipitationChance: 90),
            HourlyWeather(date: Date().addingTimeInterval(10800), temperature: 16, condition: .rainy, precipitationChance: 75),
            HourlyWeather(date: Date().addingTimeInterval(14400), temperature: 16, condition: .cloudy, precipitationChance: 40),
            HourlyWeather(date: Date().addingTimeInterval(18000), temperature: 17, condition: .cloudy, precipitationChance: 30),
        ],
        dailyForecast: [
            DailyWeather(date: Date(), high: 20, low: 15, condition: .rainy, precipitationChance: 80),
            DailyWeather(date: Date().addingTimeInterval(86400), high: 22, low: 16, condition: .cloudy, precipitationChance: 40),
            DailyWeather(date: Date().addingTimeInterval(172800), high: 24, low: 17, condition: .sunny, precipitationChance: 10),
        ],
        sunrise: Calendar.current.date(bySettingHour: 6, minute: 20, second: 0, of: Date()) ?? Date(),
        sunset: Calendar.current.date(bySettingHour: 18, minute: 50, second: 0, of: Date()) ?? Date(),
        lastUpdated: Date()
    )
}

extension AirQualityData {
    /// 미리보기용 기본 데이터
    static let preview = AirQualityData(
        aqi: 75,
        category: .moderate,
        pm25: 28.5,
        pm10: 52.0,
        o3: 45.0,
        no2: 22.0,
        co: 0.4,
        so2: 5.0,
        dominantPollutant: .pm25,
        lastUpdated: Date()
    )
    
    /// 나쁜 대기질 미리보기
    static let unhealthyPreview = AirQualityData(
        aqi: 156,
        category: .unhealthy,
        pm25: 78.0,
        pm10: 125.0,
        o3: 65.0,
        no2: 45.0,
        co: 0.8,
        so2: 12.0,
        dominantPollutant: .pm25,
        lastUpdated: Date()
    )
}

extension UVIndexData {
    /// 미리보기용 기본 데이터
    static let preview = UVIndexData(
        currentIndex: 6,
        maxIndex: 8,
        maxTime: Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: Date()) ?? Date(),
        level: .high,
        hourlyForecast: [
            HourlyUVIndex(date: Date(), uvIndex: 6),
            HourlyUVIndex(date: Date().addingTimeInterval(3600), uvIndex: 7),
            HourlyUVIndex(date: Date().addingTimeInterval(7200), uvIndex: 8),
            HourlyUVIndex(date: Date().addingTimeInterval(10800), uvIndex: 7),
            HourlyUVIndex(date: Date().addingTimeInterval(14400), uvIndex: 5),
            HourlyUVIndex(date: Date().addingTimeInterval(18000), uvIndex: 3),
        ],
        lastUpdated: Date()
    )
}
