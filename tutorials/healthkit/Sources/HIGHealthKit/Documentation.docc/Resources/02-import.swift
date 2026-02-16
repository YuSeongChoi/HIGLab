// MARK: - HealthKit 프레임워크 임포트

import HealthKit  // HealthKit 사용을 위한 필수 임포트
import SwiftUI    // UI 구성

// HealthKit의 주요 클래스들
// - HKHealthStore: 데이터 접근의 핵심 클래스
// - HKQuantityType: 숫자형 데이터 타입
// - HKCategoryType: 카테고리형 데이터 타입
// - HKSampleQuery: 데이터 조회 쿼리
// - HKStatisticsQuery: 통계 조회 쿼리

// 사용 예시
let healthStore = HKHealthStore()
let stepType = HKQuantityType(.stepCount)
