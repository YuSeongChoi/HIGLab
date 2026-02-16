import WeatherKit

// 달 정보

func exploreMoonData(_ day: DayWeather) {
    let moon = day.moon
    
    // 달의 위상
    let phase = moon.phase
    print("달의 위상: \(moonPhaseName(phase))")
    
    // 월출 시간
    if let moonrise = moon.moonrise {
        print("월출: \(moonrise.formatted(date: .omitted, time: .shortened))")
    }
    
    // 월몰 시간
    if let moonset = moon.moonset {
        print("월몰: \(moonset.formatted(date: .omitted, time: .shortened))")
    }
}

func moonPhaseName(_ phase: MoonPhase) -> String {
    switch phase {
    case .new:
        return "🌑 삭 (신월)"
    case .waxingCrescent:
        return "🌒 초승달"
    case .firstQuarter:
        return "🌓 상현달"
    case .waxingGibbous:
        return "🌔 상현망간"
    case .full:
        return "🌕 보름달"
    case .waningGibbous:
        return "🌖 하현망간"
    case .lastQuarter:
        return "🌗 하현달"
    case .waningCrescent:
        return "🌘 그믐달"
    @unknown default:
        return "알 수 없음"
    }
}
