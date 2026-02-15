import SwiftUI

// MARK: - HIG: 날씨 조건별 그래디언트 배경

extension WeatherCondition {
    var gradient: LinearGradient {
        switch self {
        case .sunny:
            LinearGradient(
                colors: [Color(hex: "FF9500"), Color(hex: "FFCC02")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cloudy:
            LinearGradient(
                colors: [Color(hex: "8E8E93"), Color(hex: "C7C7CC")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .rainy:
            LinearGradient(
                colors: [Color(hex: "5856D6"), Color(hex: "007AFF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .snowy:
            LinearGradient(
                colors: [Color(hex: "E5E5EA"), Color(hex: "AEAEB2")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .stormy:
            LinearGradient(
                colors: [Color(hex: "1C1C1E"), Color(hex: "5856D6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var textColor: Color {
        switch self {
        case .sunny, .cloudy, .snowy:
            return .primary
        case .rainy, .stormy:
            return .white
        }
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
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
