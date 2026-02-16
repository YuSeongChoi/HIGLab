import WeatherKit
import CoreLocation

// 바람 관련 데이터

func exploreWindData(_ current: CurrentWeather) {
    let wind = current.wind
    
    // 풍속
    let speed = wind.speed
    print("풍속: \(speed.formatted())")
    
    // 풍향 (방위각, 북쪽이 0°)
    let direction = wind.direction
    print("풍향: \(direction.formatted())")
    
    // 돌풍 (옵셔널)
    if let gust = wind.gust {
        print("돌풍: \(gust.formatted())")
    }
    
    // 풍향을 한글로 변환
    let compassDirection = compassDirectionFromDegrees(direction.value)
    print("풍향(한글): \(compassDirection)")
}

func compassDirectionFromDegrees(_ degrees: Double) -> String {
    let directions = ["북", "북동", "동", "남동", "남", "남서", "서", "북서"]
    let index = Int((degrees + 22.5) / 45.0) % 8
    return directions[index]
}
