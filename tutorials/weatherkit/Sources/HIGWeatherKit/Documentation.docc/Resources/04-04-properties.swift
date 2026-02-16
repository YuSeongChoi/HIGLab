import WeatherKit

// HourWeather 주요 속성

func exploreHourWeather(_ hour: HourWeather) {
    // 기본 정보
    let date = hour.date                          // 해당 시간
    let temperature = hour.temperature             // 예상 온도
    let apparentTemp = hour.apparentTemperature   // 체감 온도
    let condition = hour.condition                 // 날씨 상태
    
    // 강수 정보
    let precipChance = hour.precipitationChance   // 강수 확률 (0.0-1.0)
    let precipAmount = hour.precipitationAmount   // 예상 강수량
    
    // 바람 정보
    let windSpeed = hour.wind.speed
    let windDirection = hour.wind.direction
    
    print("시간: \(date.formatted(date: .omitted, time: .shortened))")
    print("온도: \(temperature.formatted())")
    print("날씨: \(condition.description)")
    print("강수확률: \(Int(precipChance * 100))%")
    print("풍속: \(windSpeed.formatted())")
}
