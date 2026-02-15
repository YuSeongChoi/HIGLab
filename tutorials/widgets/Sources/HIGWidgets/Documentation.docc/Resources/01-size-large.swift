import SwiftUI
import WidgetKit

/// Large 위젯 (360×376pt)
/// 가장 많은 정보 표시 가능
/// HIG 권장: 현재 + 시간별 + 주간 예보
struct LargeWeatherWidget: View {
    var body: some View {
        VStack(spacing: 16) {
            // 상단: 현재 날씨
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("서울")
                        .font(.title3.bold())
                    Text("대체로 맑음")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(alignment: .top, spacing: 4) {
                        Text("24")
                            .font(.system(size: 52, weight: .bold))
                        Text("°")
                            .font(.title)
                    }
                    Text("H:28° L:18°")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // 중간: 시간별 예보
            VStack(alignment: .leading, spacing: 8) {
                Text("시간별 예보")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    ForEach(hourlyForecasts) { forecast in
                        VStack(spacing: 6) {
                            Text(forecast.time)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Image(systemName: forecast.icon)
                                .font(.system(size: 20))
                                .symbolRenderingMode(.multicolor)

                            Text("\(forecast.temperature)°")
                                .font(.caption.bold())
                        }
                    }
                }
            }

            Divider()

            // 하단: 주간 예보
            VStack(alignment: .leading, spacing: 8) {
                Text("주간 예보")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                VStack(spacing: 6) {
                    ForEach(weeklyForecasts) { forecast in
                        HStack {
                            Text(forecast.day)
                                .font(.subheadline)
                                .frame(width: 40, alignment: .leading)

                            Image(systemName: forecast.icon)
                                .font(.system(size: 16))
                                .symbolRenderingMode(.multicolor)
                                .frame(width: 30)

                            Spacer()

                            Text("\(forecast.low)°")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            // 온도 범위 바
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(.gray.opacity(0.3))
                                    .frame(width: 60, height: 4)

                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 42, height: 4)
                            }

                            Text("\(forecast.high)°")
                                .font(.subheadline.bold())
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    var hourlyForecasts: [LargeHourlyForecast] {
        [
            LargeHourlyForecast(time: "지금", icon: "cloud.sun.fill", temperature: 24),
            LargeHourlyForecast(time: "15시", icon: "sun.max.fill", temperature: 26),
            LargeHourlyForecast(time: "16시", icon: "sun.max.fill", temperature: 27),
            LargeHourlyForecast(time: "17시", icon: "cloud.fill", temperature: 25),
            LargeHourlyForecast(time: "18시", icon: "cloud.moon.fill", temperature: 23)
        ]
    }

    var weeklyForecasts: [WeeklyForecast] {
        [
            WeeklyForecast(day: "오늘", icon: "cloud.sun.fill", low: 18, high: 28),
            WeeklyForecast(day: "월", icon: "sun.max.fill", low: 20, high: 30),
            WeeklyForecast(day: "화", icon: "cloud.rain.fill", low: 17, high: 24),
            WeeklyForecast(day: "수", icon: "cloud.fill", low: 16, high: 22)
        ]
    }
}

struct LargeHourlyForecast: Identifiable {
    let id = UUID()
    let time: String
    let icon: String
    let temperature: Int
}

struct WeeklyForecast: Identifiable {
    let id = UUID()
    let day: String
    let icon: String
    let low: Int
    let high: Int
}

#Preview {
    LargeWeatherWidget()
        .previewContext(WidgetPreviewContext(family: .systemLarge))
}
