//
//  DeliveryCompactLayout.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 3/3/26.
//

import SwiftUI

// 이 파일은 Dynamic Island의 compact/minimal 상태 전용 레이아웃 컴포넌트를 제공합니다.
/*
 Dynamic Island - Compact 레이아웃
 Dynamic Island의 가장 작은 레이아웃인 Compact와 Minimal 상태를 구현합니다.
 
 Compactsms Leading과 Trailing 두 영역으로 나뉩니다.
 가장 핵심적인 정보만 표시하세요.
 */
// MARK: - Compact Leading View
// Dynamic Island 좌측 영역

struct DeliveryCompactLeadingView: View {
    let status: DeliveryStatus
    
    var body: some View {
        Image(systemName: status.symbolName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(status.color)
    }
}

// 사용 예시 (DynamicIsland 내부)
/*
DynamicIsland {
    ... compactLeading: {
        DeliveryCompactLeadingView(status: context.state.status)
    }
}
*/
 
// MARK: - Compact Trailing View
// Dynamic Island 우측 영역 - 예상 도착 시간

struct DeliveryCompactTrailingView: View {
    let estimatedArrival: Date
    
    var body: some View {
        // 카운트다운 타이머 스타일
        Text(estimatedArrival, style: .timer)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.primary)
    }
}

// MARK: - Minimal View
// 다른 Live Activity와 함께 표시될 때
// 우측의 작은 원형 영역만 사용

struct DeliveryMinimalView: View {
    let status: DeliveryStatus
    
    var body: some View {
        // 작은 원형 영역이므로 아이콘만 표시
        ZStack {
            // 배경 (선택적)
            Circle()
                .fill(status.color.opacity(0.2))
            
            // 아이콘
            Image(systemName: status.symbolName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(status.color)
        }
    }
}

// HIG 팁: Minimal에서는 가장 핵심적인 상태만 표시
// 텍스트는 읽기 어려우므로 아이콘 사용 권장
