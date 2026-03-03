//
//  DeliveryExpandedLayout.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 3/3/26.
//

import SwiftUI
import WidgetKit

/*
 Dynamic Island - Expanded 레이아웃
 길게 눌렀을 때 표시되는 Expanded 레이아웃을 구현합니다.
 가장 풍부한 정보와 인터랙션을 제공합니다.
 
 Expanded는 4개 영역으로 나뉩니다:
 - leading:   좌측 상단
 - trailing:  우측 상단
 - center:    중앙
 - bottom:    하단 전체
 */

// MARK: - Expanded Leading View
// 배달원 프로피 이미지
struct ExpandedLeadingView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        if let driverImageURL = context.state.driverImageURL {
            AsyncImage(url: driverImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                driverPlaceholder
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
        } else {
            driverPlaceholder
        }
    }
    
    var driverPlaceholder: some View {
        ZStack {
            Circle()
                .fill(.quaternary)
            Image(systemName: "person.fill")
                .foregroundStyle(.secondary)
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - Expanded Trailing View
// 배달 상태 아이콘 + 시간

struct ExpandedTrailingView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // 상태 아이콘
            Image(systemName: context.state.status.symbolName)
                .font(.title2)
                .foregroundStyle(context.state.status.color)
                .symbolEffect(.pulse, value: context.state.status == .nearby)
            
            // 예상 도착 시간
            Text(context.state.estimatedArrival, style: .time)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Expanded Center View
// 가게명과 상태 메시지

struct ExpandedCenterView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 가게명
            Text(context.attributes.storeName)
                .font(.headline)
                .lineLimit(1)
            
            // 상태 메시지
            Text(context.state.statusMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            
            // 배달원 이름 (있으면)
            if let driverName = context.state.driverName,
               context.state.status == .pickedUp || context.state.status == .nearby {
                Text("\(driverName)님이 배달 중")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Expanded Bottom View
// 배달 진행 상태 바

struct ExpandedBottomView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        VStack(spacing: 8) {
            // 진행 바
            DeliveryProgressBar(progress: context.state.progress)
            
            // 단계 라벨
            HStack {
                ForEach(DeliveryStatus.allCases, id: \.self) { status in
                    if status != .delivered {
                        Text(status.displayName)
                            .font(.caption2)
                            .foregroundStyle(
                                context.state.status.rawValue >= status.rawValue ? .primary : .secondary
                            )
                        if status != .nearby {
                            Spacer()
                        }
                    }
                }
                Text("완료")
                    .font(.caption2)
                    .foregroundStyle(
                        context.state.status == .delivered ? .primary : .secondary
                    )
            }
        }
    }
}

private struct DeliveryProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 배경
                Capsule()
                    .fill(.quaternary)
                
                // 진행
                Capsule()
                    .fill(.green)
                    .frame(width: geometry.size.width * progress)
                    .animation(.spring, value: progress)
            }
        }
        .frame(height: 6)
    }
}
