import WeatherKit

// 강수 관련 상세 정보

func explorePrecipitation(_ hour: HourWeather) {
    // 강수 유형
    let precipType = hour.precipitation
    switch precipType {
    case .none:
        print("강수 없음")
    case .rain:
        print("비")
    case .snow:
        print("눈")
    case .sleet:
        print("진눈깨비")
    case .hail:
        print("우박")
    case .mixed:
        print("혼합 강수")
    @unknown default:
        print("알 수 없는 강수 유형")
    }
    
    // 강수량
    let rainAmount = hour.precipitationAmount
    print("예상 강수량: \(rainAmount.formatted())")
    
    // 적설량
    let snowAmount = hour.snowfallAmount
    print("예상 적설량: \(snowAmount.formatted())")
    
    // 강수 확률
    let chance = hour.precipitationChance
    print("강수 확률: \(Int(chance * 100))%")
}
