//
//  HIGPrinciples.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 2/26/26.
//

import Foundation

// HIG Live Activity 핵심 원칙
// 1. Glanceable = 한눈에 파악
struct GlanceableDesign {
    // ✅ Do: 핵심 정보만 크게
    let prominentInfo = "도착까지 12분"
    
    // ❌ Don't: 불필요한 정보 나열
    // "주문번호 #12345, 가게명, 메뉴, 배달원, 연락처..."
}

// 2. Real-time - 실시간 반영
struct RealtimeUpdates {
    // ✅ Do: 실제 상태 반영
    func updateDeliveryStatus(_ status: LiveActivityUseCases) {
        // 배달원 위치, 예상 시간 업데이트
    }
    
    // ❌ Don't: 오래된 정보 방치
}

// 3. Actionable - 탭하면 앱으로
struct ActionableLink {
    // 탭 시 앱의 관련 화면으로 이동
    let deepLink = URL(string: "myapp://order/12345")
}
