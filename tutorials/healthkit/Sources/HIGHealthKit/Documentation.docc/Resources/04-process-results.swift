import HealthKit

// MARK: - 쿼리 결과 처리

func processStepSamples(_ samples: [HKQuantitySample]) -> Int {
    var totalSteps: Double = 0
    
    for sample in samples {
        // HKQuantity에서 값 추출
        let steps = sample.quantity.doubleValue(for: .count())
        totalSteps += steps
        
        // 추가 정보도 확인 가능
        print("""
        샘플 정보:
        - 시작: \(sample.startDate)
        - 종료: \(sample.endDate)
        - 걸음 수: \(Int(steps))
        - 소스: \(sample.sourceRevision.source.name)
        - 기기: \(sample.device?.name ?? "알 수 없음")
        """)
    }
    
    return Int(totalSteps)
}

// ⚠️ 주의: 여러 소스의 데이터가 중복될 수 있음
// Apple Watch와 iPhone이 동시에 같은 걸음을 기록할 수 있습니다
// -> HKStatisticsQuery를 사용하면 자동으로 중복 제거됨 (Chapter 7 참조)
