//
//  SmallWeatherWidget.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 2/24/26.
//

import SwiftUI
import WidgetKit

/// Small 위젯 (169×169pt)
/// 정보 4개 이내, 단일 딥링크
/// HIG 권장: 현재 기온 + 도시명 + 날씨 아이콘 + 최고/최저
struct SmallWeatherWidget: View {
    var body: some View {
        VStack(spacing: 4) {
            // 1. 도시명
            HStack {
                Text("서울")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Spacer()

            // 2. 날씨 아이콘
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 36))
                .symbolRenderingMode(.multicolor)

            // 3. 현재 기온 (가장 중요!)
            Text("24°")
                .font(.system(size: 40, weight: .bold))

            // 4. 최고/최저 기온
            HStack(spacing: 8) {
                Text("H:28°")
                    .font(.caption)
                Text("L:18°")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview {
    SmallWeatherWidget()
        .previewContext(WidgetPreviewContext(family: .systemSmall))
}
