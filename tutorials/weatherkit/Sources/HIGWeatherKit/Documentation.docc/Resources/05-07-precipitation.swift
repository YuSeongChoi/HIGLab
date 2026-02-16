import WeatherKit

// 일별 강수 정보

func exploreDayPrecipitation(_ day: DayWeather) {
    // 강수 확률
    let precipChance = day.precipitationChance
    print("강수 확률: \(Int(precipChance * 100))%")
    
    // 강수 유형
    let precipType = day.precipitation
    switch precipType {
    case .none:
        print("강수 없음")
    case .rain:
        print("비 예상")
    case .snow:
        print("눈 예상")
    case .sleet:
        print("진눈깨비 예상")
    case .hail:
        print("우박 예상")
    case .mixed:
        print("혼합 강수 예상")
    @unknown default:
        print("알 수 없음")
    }
    
    // 예상 강수량
    let rainAmount = day.rainfallAmount
    print("예상 강수량: \(rainAmount.formatted())")
    
    // 예상 적설량
    let snowAmount = day.snowfallAmount
    print("예상 적설량: \(snowAmount.formatted())")
}
