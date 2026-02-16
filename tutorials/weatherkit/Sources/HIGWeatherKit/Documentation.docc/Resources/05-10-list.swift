import WeatherKit
import SwiftUI

// 전체 일별 예보 리스트

struct DailyForecastList: View {
    let forecast: Forecast<DayWeather>
    
    private var temperatureRange: ClosedRange<Double> {
        let allLows = forecast.map { $0.lowTemperature.value }
        let allHighs = forecast.map { $0.highTemperature.value }
        let minTemp = allLows.min() ?? 0
        let maxTemp = allHighs.max() ?? 30
        return minTemp...maxTemp
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("10일 예보")
                .font(.headline)
                .padding(.bottom, 8)
            
            Divider()
            
            ForEach(forecast, id: \.date) { day in
                DailyForecastRow(
                    day: day,
                    tempRange: temperatureRange
                )
                
                if day.date != forecast.last?.date {
                    Divider()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
