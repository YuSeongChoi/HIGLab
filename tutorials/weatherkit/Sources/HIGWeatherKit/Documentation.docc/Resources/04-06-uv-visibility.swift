import WeatherKit

// UV 지수와 가시거리

func exploreUVAndVisibility(_ hour: HourWeather) {
    // UV 지수
    let uvIndex = hour.uvIndex
    print("UV 지수: \(uvIndex.value)")
    print("UV 카테고리: \(uvIndex.category)")
    
    // UV 카테고리별 권장사항
    switch uvIndex.category {
    case .low:
        print("자외선 낮음 - 외출 안전")
    case .moderate:
        print("자외선 보통 - 자외선 차단제 권장")
    case .high:
        print("자외선 높음 - 자외선 차단 필수")
    case .veryHigh:
        print("자외선 매우 높음 - 실외활동 자제")
    case .extreme:
        print("자외선 극심함 - 실외활동 피하기")
    @unknown default:
        print("알 수 없음")
    }
    
    // 가시거리
    let visibility = hour.visibility
    print("가시거리: \(visibility.formatted())")
    
    // 운량
    let cloudCover = hour.cloudCover
    print("운량: \(Int(cloudCover * 100))%")
}
