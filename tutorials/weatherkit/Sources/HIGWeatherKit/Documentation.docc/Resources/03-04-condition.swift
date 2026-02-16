import WeatherKit
import SwiftUI

// WeatherCondition 처리

func describeCondition(_ condition: WeatherCondition) -> String {
    switch condition {
    case .clear:
        return "맑음"
    case .cloudy:
        return "흐림"
    case .mostlyClear:
        return "대체로 맑음"
    case .mostlyCloudy:
        return "대체로 흐림"
    case .partlyCloudy:
        return "구름 조금"
    case .rain:
        return "비"
    case .heavyRain:
        return "폭우"
    case .drizzle:
        return "이슬비"
    case .snow:
        return "눈"
    case .heavySnow:
        return "폭설"
    case .sleet:
        return "진눈깨비"
    case .thunderstorms:
        return "뇌우"
    case .foggy:
        return "안개"
    case .haze:
        return "연무"
    case .windy:
        return "강풍"
    case .hot:
        return "무더위"
    case .frigid:
        return "혹한"
    default:
        return condition.description
    }
}
