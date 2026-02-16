import WeatherKit
import SwiftUI
import Foundation

// 온도 단위 변환

struct TemperatureView: View {
    let temperature: Measurement<UnitTemperature>
    
    var body: some View {
        VStack {
            // 시스템 설정에 따른 자동 포맷
            Text(temperature.formatted())
            
            // 섭씨로 표시
            Text(temperature.formatted(.measurement(
                width: .abbreviated,
                usage: .asProvided,
                numberFormatStyle: .number.precision(.fractionLength(0))
            )))
            
            // 화씨로 변환
            let fahrenheit = temperature.converted(to: .fahrenheit)
            Text(fahrenheit.formatted())
        }
    }
}

// 사용자 설정에 따른 온도 단위 선택
enum TemperatureUnit: String, CaseIterable {
    case celsius = "°C"
    case fahrenheit = "°F"
    
    func format(_ temp: Measurement<UnitTemperature>) -> String {
        let converted: Measurement<UnitTemperature>
        switch self {
        case .celsius:
            converted = temp.converted(to: .celsius)
        case .fahrenheit:
            converted = temp.converted(to: .fahrenheit)
        }
        return "\(Int(converted.value))\(rawValue)"
    }
}
