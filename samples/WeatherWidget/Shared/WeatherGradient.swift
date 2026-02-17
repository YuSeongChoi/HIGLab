import SwiftUI

// MARK: - HIG: 날씨 조건별 그래디언트 배경
// Apple Weather 앱과 유사한 자연스러운 그래디언트 구현

extension WeatherCondition {
    
    /// 메인 그래디언트 (낮/밤 구분)
    func gradient(isDaytime: Bool = true) -> LinearGradient {
        if isDaytime {
            return daytimeGradient
        } else {
            return nighttimeGradient
        }
    }
    
    /// 낮 시간 그래디언트
    var daytimeGradient: LinearGradient {
        switch self {
        case .sunny:
            return LinearGradient(
                colors: [
                    Color(hex: "4A90D9"),   // 맑은 하늘 파랑
                    Color(hex: "87CEEB"),   // 밝은 하늘색
                    Color(hex: "B4E4FF")    // 연한 하늘색
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .partlyCloudy:
            return LinearGradient(
                colors: [
                    Color(hex: "6BA3D6"),
                    Color(hex: "9FC5E8"),
                    Color(hex: "D4E6F1")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .cloudy:
            return LinearGradient(
                colors: [
                    Color(hex: "8E9EAB"),
                    Color(hex: "B8C6DB"),
                    Color(hex: "D7DEE3")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .foggy:
            return LinearGradient(
                colors: [
                    Color(hex: "ACB6B6"),
                    Color(hex: "C9D6D6"),
                    Color(hex: "E0E5E5")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .rainy:
            return LinearGradient(
                colors: [
                    Color(hex: "4B6584"),
                    Color(hex: "7B8FA1"),
                    Color(hex: "A5B1C2")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .heavyRain:
            return LinearGradient(
                colors: [
                    Color(hex: "2C3E50"),
                    Color(hex: "4B6584"),
                    Color(hex: "7B8FA1")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .snowy:
            return LinearGradient(
                colors: [
                    Color(hex: "B4C6D4"),
                    Color(hex: "D5E1EB"),
                    Color(hex: "ECF0F3")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .sleet:
            return LinearGradient(
                colors: [
                    Color(hex: "8E9EAB"),
                    Color(hex: "B8C6DB"),
                    Color(hex: "D0D7DE")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .stormy:
            return LinearGradient(
                colors: [
                    Color(hex: "2C3E50"),
                    Color(hex: "34495E"),
                    Color(hex: "5D6D7E")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .windy:
            return LinearGradient(
                colors: [
                    Color(hex: "74B9FF"),
                    Color(hex: "A3D9FF"),
                    Color(hex: "D0EFFF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .haze:
            return LinearGradient(
                colors: [
                    Color(hex: "C4A35A"),
                    Color(hex: "D4B896"),
                    Color(hex: "E5D5C3")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    /// 밤 시간 그래디언트
    var nighttimeGradient: LinearGradient {
        switch self {
        case .sunny:
            return LinearGradient(
                colors: [
                    Color(hex: "0F0C29"),   // 깊은 남색
                    Color(hex: "302B63"),   // 보라빛 남색
                    Color(hex: "24243E")    // 어두운 보라
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .partlyCloudy:
            return LinearGradient(
                colors: [
                    Color(hex: "1A1A2E"),
                    Color(hex: "2D2D44"),
                    Color(hex: "3D3D5C")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .cloudy, .foggy:
            return LinearGradient(
                colors: [
                    Color(hex: "1F2530"),
                    Color(hex: "2C3A47"),
                    Color(hex: "3D4F5F")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .rainy, .heavyRain, .sleet:
            return LinearGradient(
                colors: [
                    Color(hex: "141E30"),
                    Color(hex: "243B55"),
                    Color(hex: "34506A")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .snowy:
            return LinearGradient(
                colors: [
                    Color(hex: "2C3E50"),
                    Color(hex: "4B6584"),
                    Color(hex: "5D7B9D")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .stormy:
            return LinearGradient(
                colors: [
                    Color(hex: "0D0D0D"),
                    Color(hex: "1A1A2E"),
                    Color(hex: "2D2D44")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .windy:
            return LinearGradient(
                colors: [
                    Color(hex: "1A1A2E"),
                    Color(hex: "2D3A5F"),
                    Color(hex: "3F5185")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .haze:
            return LinearGradient(
                colors: [
                    Color(hex: "2B2520"),
                    Color(hex: "4A3F35"),
                    Color(hex: "6A5D50")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    /// 텍스트/아이콘 색상 (배경 대비)
    func textColor(isDaytime: Bool = true) -> Color {
        if isDaytime {
            switch self {
            case .sunny, .partlyCloudy, .windy:
                return .white
            case .cloudy, .foggy, .snowy, .sleet, .haze:
                return .primary
            case .rainy, .heavyRain, .stormy:
                return .white
            }
        } else {
            return .white
        }
    }
    
    /// 잠금화면용 단색 배경
    var lockScreenColor: Color {
        switch self {
        case .sunny: return Color(hex: "FFB347")
        case .partlyCloudy: return Color(hex: "87CEEB")
        case .cloudy: return Color(hex: "A9A9A9")
        case .foggy: return Color(hex: "C0C0C0")
        case .rainy, .heavyRain: return Color(hex: "4682B4")
        case .snowy, .sleet: return Color(hex: "E0E5EC")
        case .stormy: return Color(hex: "483D8B")
        case .windy: return Color(hex: "87CEEB")
        case .haze: return Color(hex: "D4A76A")
        }
    }
}

// MARK: - 대기질 그래디언트

extension AirQualityLevel {
    /// 대기질 배경 그래디언트
    var gradient: LinearGradient {
        switch self {
        case .good:
            return LinearGradient(
                colors: [Color(hex: "56AB2F"), Color(hex: "A8E063")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .moderate:
            return LinearGradient(
                colors: [Color(hex: "F7971E"), Color(hex: "FFD200")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .unhealthyForSensitive:
            return LinearGradient(
                colors: [Color(hex: "F85032"), Color(hex: "E73827")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .unhealthy:
            return LinearGradient(
                colors: [Color(hex: "CB2D3E"), Color(hex: "EF473A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .veryUnhealthy:
            return LinearGradient(
                colors: [Color(hex: "8E2DE2"), Color(hex: "4A00E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .hazardous:
            return LinearGradient(
                colors: [Color(hex: "3D0000"), Color(hex: "8B0000")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - 자외선 지수 그래디언트

extension UVLevel {
    /// UV 지수 배경 그래디언트
    var gradient: LinearGradient {
        switch self {
        case .low:
            return LinearGradient(
                colors: [Color(hex: "56AB2F"), Color(hex: "A8E063")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .moderate:
            return LinearGradient(
                colors: [Color(hex: "F7971E"), Color(hex: "FFD200")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .high:
            return LinearGradient(
                colors: [Color(hex: "F85032"), Color(hex: "E73827")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .veryHigh:
            return LinearGradient(
                colors: [Color(hex: "CB2D3E"), Color(hex: "EF473A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .extreme:
            return LinearGradient(
                colors: [Color(hex: "8E2DE2"), Color(hex: "4A00E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Color Hex Extension

extension Color {
    /// Hex 문자열에서 Color 생성
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 시간대별 하늘 색상

/// 실제 시간에 따른 자연스러운 하늘 색상 생성
struct SkyGradientGenerator {
    
    /// 현재 시간에 맞는 하늘 그래디언트 생성
    static func gradient(for date: Date = Date(), condition: WeatherCondition) -> LinearGradient {
        let hour = Calendar.current.component(.hour, from: date)
        
        // 새벽/황혼 시간대 특별 처리
        switch hour {
        case 5...6: // 새벽
            return dawnGradient(condition: condition)
        case 7...17: // 낮
            return condition.daytimeGradient
        case 18...19: // 황혼
            return duskGradient(condition: condition)
        default: // 밤
            return condition.nighttimeGradient
        }
    }
    
    /// 새벽 그래디언트
    private static func dawnGradient(condition: WeatherCondition) -> LinearGradient {
        if condition == .cloudy || condition == .rainy || condition == .stormy {
            return condition.daytimeGradient
        }
        
        return LinearGradient(
            colors: [
                Color(hex: "FF9A8B"),   // 분홍빛 오렌지
                Color(hex: "FF6B6B"),   // 연한 빨강
                Color(hex: "FFD93D"),   // 노란색
                Color(hex: "87CEEB")    // 하늘색
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    /// 황혼 그래디언트
    private static func duskGradient(condition: WeatherCondition) -> LinearGradient {
        if condition == .cloudy || condition == .rainy || condition == .stormy {
            return condition.daytimeGradient
        }
        
        return LinearGradient(
            colors: [
                Color(hex: "141E30"),   // 어두운 남색
                Color(hex: "6B5B95"),   // 보라
                Color(hex: "FF6B6B"),   // 빨강
                Color(hex: "FFE66D")    // 노랑
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - 위젯 배경 스타일

/// 위젯 배경 스타일 정의
enum WidgetBackgroundStyle {
    case gradient(LinearGradient)
    case solid(Color)
    case vibrant
    case ultraThinMaterial
    
    /// SwiftUI View로 변환
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .gradient(let gradient):
            gradient
        case .solid(let color):
            color
        case .vibrant:
            Color.clear
                .background(.ultraThinMaterial)
        case .ultraThinMaterial:
            Color.clear
                .background(.ultraThinMaterial)
        }
    }
}

// MARK: - 온도 색상

/// 온도에 따른 색상 생성
struct TemperatureColor {
    
    /// 온도값에 맞는 색상 반환
    static func color(for temperature: Int) -> Color {
        switch temperature {
        case ...(-10):
            return Color(hex: "4A90D9")     // 매우 추움 - 진한 파랑
        case -9...0:
            return Color(hex: "74B9FF")     // 추움 - 밝은 파랑
        case 1...10:
            return Color(hex: "81ECEC")     // 쌀쌀 - 청록
        case 11...15:
            return Color(hex: "00CEC9")     // 시원 - 민트
        case 16...20:
            return Color(hex: "55EFC4")     // 선선 - 연두
        case 21...25:
            return Color(hex: "FFEAA7")     // 따뜻 - 노랑
        case 26...30:
            return Color(hex: "FDCB6E")     // 더움 - 주황
        case 31...35:
            return Color(hex: "E17055")     // 매우 더움 - 빨강
        default:
            return Color(hex: "D63031")     // 극한 더위 - 진한 빨강
        }
    }
    
    /// 온도 범위에 따른 그래디언트
    static func gradient(low: Int, high: Int) -> LinearGradient {
        LinearGradient(
            colors: [color(for: low), color(for: high)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
