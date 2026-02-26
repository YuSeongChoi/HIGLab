//
//  PersonalizedExample.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 2/24/26.
//

import SwiftUI
import WidgetKit

/// Personalized (개인화) 원칙을 따르는 위젯
/// 사용자가 설정한 옵션에 따라 다르게 표시
struct PersonalizedWeatherWidget: View {
    // 사용자 설정 가능한 옵션들
    let selectedCity: String      // 도시 선택
    let temperatureUnit: String   // °C 또는 °F
    let showFeelsLike: Bool       // 체감 온도 표시 여부
    
    var body: some View {
        VStack(spacing: 16) {
            // 사용자가 선택한 도시
            HStack {
                Image(systemName: "location.fill")
                    .foregroundStyle(.blue)
                Text(selectedCity)
                    .font(.headline)
                Spacer()
            }
            
            
            // 온도 - 사용자가 선택한 단위로 표시
            HStack(alignment: .top) {
                Text(currentTemperature)
                    .font(.system(size: 48, weight: .bold))
                Text(temperatureUnit)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            
            // 체감 온도 - 사용자 설정에 따라 표시/숨김
            if showFeelsLike {
                HStack {
                    Text("체감")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(feelsLikeTemperature)
                        .font(.subheadline.bold())
                }
            }
            
            
            Divider()
            
            
            // 추가 정보
            HStack {
                WeatherDetail(icon: "humidity.fill", value: "65%")
                Spacer()
                WeatherDetail(icon: "wind", value: "12km/h")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [.orange.opacity(0.2), .pink.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    
    var currentTemperature: String {
        temperatureUnit == "°C" ? "24" : "75"
    }
    
    
    var feelsLikeTemperature: String {
        temperatureUnit == "°C" ? "22°" : "72°"
    }
}

struct WeatherDetail: View {
    let icon: String
    let value: String


    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(value)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
    }
}

