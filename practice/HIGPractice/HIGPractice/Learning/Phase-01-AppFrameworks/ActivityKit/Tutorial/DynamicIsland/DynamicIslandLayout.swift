//
//  DynamicIslandLayout.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 2/26/26.
//

import SwiftUI

// MARK: - Compact Layout
// Dynamic Island - Compact 레이아수
// Leading(좌)과 Trailing(우) 영역

// Compact Leading: 좌측 - 아이콘 또는 이미지
private struct CompactLeadingView: View {
    var body: some View {
        Image(systemName: "bicycle")
            .font(.system(size: 14, weight: .semibold))
    }
}

// Compact Trailing: 우측 - 핵심 숫자/텍스트
private struct CompactTrailingView: View {
    let minutesRemaining: Int
    
    var body: some View {
        Text("\(minutesRemaining)분")
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .monospacedDigit()
    }
}

// MARK: - Minimal Layout
// Dynamic Island - Minimal 레이아웃
// 다른 Live Activity와 함께 표시될 때
private struct MinimalView: View {
    let status: LiveActivityUseCases
    
    var body: some View {
        // 원형 영역 안에 핵심 아이콘만
        Image(systemName: "globe")
            .font(.system(size: 12, weight: .semibold))
    }
}

// MARK: - Expanded Layout
// Dynamic Island - Expanded 레이아웃
// 길게 눌렀을 때 표시
private struct ExpandedView: View {
    var body: some View {
        VStack(spacing: 12) {
            // 상단: 가게 정보 + 배달 상태
            HStack {
                // Leading
                Image(systemName: "storefront")
                    .font(.title2)
                
                // Center
                VStack(alignment: .leading) {
                    Text("가게 이름")
                        .font(.headline)
                    Text("배달 상태")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Trailing
                Image(systemName: "globe")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            
            // Bottom: 진행 바
            ProgressView()
        }
        .padding()
    }
}
