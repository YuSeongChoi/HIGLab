import WeatherKit
import SwiftUI

// 가로 스크롤 시간별 예보

struct HourlyForecastScrollView: View {
    let forecast: Forecast<HourWeather>
    
    private var next24Hours: [HourWeather] {
        Array(forecast.prefix(24))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("시간별 예보")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(next24Hours, id: \.date) { hour in
                        HourlyForecastCard(hour: hour)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
