//
//  LiveActivityUseCases.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 2/26/26.
//

import Foundation

// Live Activity 적합 사례
enum LiveActivityUseCases {
    // ✅ 좋은 사례: 시간 제한이 있는 진행 중인 작업
    case deliveryTracking      // 배달 추적
    case rideShare             // 택시/차량 공유
    case sportsScore           // 스포츠 경기 점수
    case flightStatus          // 항공편 상태
    case timer                 // 타이머/스톱워치
    case musicPlayback         // 음악 재생
    case workoutSession        // 운동 세션
    
    // ❌ 나쁜 사례: 지속적/정적 정보
    // case weatherWidget      // → Widget 사용
    // case calendarReminder   // → Notification 사용
    // case stockPrice         // → Widget 사용
}
