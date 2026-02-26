//
//  MediumWeatherWidget.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 2/24/26.
//

import SwiftUI
import WidgetKit

/// Medium 위젯 (360×169pt)
/// 복수 딥링크 가능, 더 많은 정보 표시
/// HIG 권장: 현재 날씨 + 시간별 예보
struct MediumWeatherWidget: View {
    var body: some View {
        HStack(spacing: 16) {
            // 왼쪽: 현재 날씨 (Small 위젯과 유사)
            VStack(alignment: .leading, spacing: 8) {
                Text("서울")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)


                Spacer()


                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 36))
                    .symbolRenderingMode(.multicolor)


                Text("24°")
                    .font(.system(size: 40, weight: .bold))


                HStack(spacing: 8) {
                    Text("H:28°")
                        .font(.caption)
                    Text("L:18°")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            .frame(maxHeight: .infinity)


            Divider()


            // 오른쪽: 시간별 예보 (Medium의 추가 공간 활용)
            VStack(alignment: .leading, spacing: 8) {
                Text("시간별 예보")
                    .font(.caption)
                    .foregroundStyle(.secondary)


                HStack(spacing: 12) {
                    ForEach(hourlyForecasts) { forecast in
                        VStack(spacing: 4) {
                            Text(forecast.time)
                                .font(.caption2)
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
            .frame(maxHeight: .infinity)
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


    var hourlyForecasts: [HourlyForecast] {
        [
            HourlyForecast(time: "지금", icon: "cloud.sun.fill", temperature: 24),
            HourlyForecast(time: "15시", icon: "sun.max.fill", temperature: 26),
            HourlyForecast(time: "16시", icon: "sun.max.fill", temperature: 27),
            HourlyForecast(time: "17시", icon: "cloud.fill", temperature: 25),
            HourlyForecast(time: "18시", icon: "cloud.moon.fill", temperature: 23)
        ]
    }
}


struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: String
    let icon: String
    let temperature: Int
}


