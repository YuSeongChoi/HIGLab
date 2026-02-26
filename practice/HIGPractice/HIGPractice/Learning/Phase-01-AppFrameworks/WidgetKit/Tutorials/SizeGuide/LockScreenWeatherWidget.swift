//
//  LockScreenWeatherWidget.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 2/24/26.
//

import SwiftUI
import WidgetKit

/// Lock Screen 위젯 (accessory)
/// 극도로 간결해야 함 - 아이콘 + 기온만 표시
/// 색상은 시스템이 제어 (항상 단색)
struct LockScreenWeatherWidget: View {
    var body: some View {
        // Circular (원형) 스타일
        VStack(spacing: 2) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 24))


            Text("24°")
                .font(.system(size: 16, weight: .semibold))
        }
        .widgetAccentable() // 시스템 색상 적용
    }
}


/// Rectangular (직사각형) 스타일
struct LockScreenWeatherRectangular: View {
    var body: some View {
        HStack {
            Image(systemName: "sun.max.fill")
                .font(.title2)


            VStack(alignment: .leading, spacing: 2) {
                Text("24°")
                    .font(.title3.bold())
                Text("서울")
                    .font(.caption2)
            }
        }
        .widgetAccentable()
    }
}


/// Inline (인라인) 스타일 - 시계 위/아래
struct LockScreenWeatherInline: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sun.max.fill")
            Text("24° 서울")
        }
        .font(.caption)
        .widgetAccentable()
    }
}


// Lock Screen 위젯의 핵심 원칙:
// 1. 색상 최소화 - 시스템이 단색으로 변환
// 2. 정보 극소화 - 1-2개 데이터만
// 3. SF Symbols 활용 - 선명한 아이콘
// 4. widgetAccentable() 필수 - 액센트 컬러 적용


