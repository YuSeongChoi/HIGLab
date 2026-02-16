import WeatherKit
import CoreLocation

// CurrentWeather의 주요 속성

func exploreCurrentWeather(_ current: CurrentWeather) {
    // 온도 관련
    let temperature = current.temperature           // 현재 온도
    let apparentTemp = current.apparentTemperature  // 체감 온도
    let dewPoint = current.dewPoint                 // 이슬점
    
    // 대기 상태
    let humidity = current.humidity                 // 상대 습도 (0.0-1.0)
    let pressure = current.pressure                 // 기압
    let visibility = current.visibility             // 가시거리
    
    // 날씨 상태
    let condition = current.condition               // WeatherCondition enum
    let cloudCover = current.cloudCover             // 운량 (0.0-1.0)
    let isDaylight = current.isDaylight             // 낮/밤 여부
    
    // 자외선
    let uvIndex = current.uvIndex                   // UV 지수
    
    // 출력
    print("온도: \(temperature.formatted())")
    print("체감온도: \(apparentTemp.formatted())")
    print("습도: \(Int(humidity * 100))%")
    print("날씨: \(condition.description)")
    print("UV 지수: \(uvIndex.value)")
}
