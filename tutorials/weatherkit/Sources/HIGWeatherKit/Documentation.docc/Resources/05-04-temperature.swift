import WeatherKit

// DayWeather 온도 정보

func exploreDayTemperature(_ day: DayWeather) {
    // 최고 온도
    let highTemp = day.highTemperature
    print("최고 온도: \(highTemp.formatted())")
    
    // 최저 온도
    let lowTemp = day.lowTemperature
    print("최저 온도: \(lowTemp.formatted())")
    
    // 온도 차이
    let tempDiff = highTemp.value - lowTemp.value
    print("일교차: \(Int(tempDiff))°")
    
    // 일교차가 큰 날 경고
    if tempDiff > 10 {
        print("⚠️ 일교차가 큽니다. 겉옷을 준비하세요.")
    }
    
    // 날씨 상태
    print("주간 날씨: \(day.condition.description)")
}
