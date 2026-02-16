import WeatherKit
import SwiftUI

// SF Symbols을 사용한 날씨 아이콘

struct WeatherIconView: View {
    let condition: WeatherCondition
    let isDaylight: Bool
    
    var body: some View {
        Image(systemName: condition.symbolName)
            .symbolRenderingMode(.multicolor)
            .font(.system(size: 64))
    }
}

// symbolName 예시
func printSymbolNames() {
    let conditions: [WeatherCondition] = [
        .clear, .cloudy, .rain, .snow, .thunderstorms
    ]
    
    for condition in conditions {
        print("\(condition): \(condition.symbolName)")
    }
    
    // 출력 예시:
    // clear: sun.max.fill
    // cloudy: cloud.fill
    // rain: cloud.rain.fill
    // snow: cloud.snow.fill
    // thunderstorms: cloud.bolt.rain.fill
}
