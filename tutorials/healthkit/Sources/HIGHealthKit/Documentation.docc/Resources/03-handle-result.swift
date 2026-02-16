import HealthKit

// MARK: - 권한 요청 결과 처리

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var authorizationComplete = false
    
    func requestAuthorization() async {
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.stepCount)
        ]
        
        do {
            try await healthStore.requestAuthorization(
                toShare: nil,
                read: typesToRead
            )
            
            // ⚠️ 주의: 이 시점에서 success가 true여도
            // 사용자가 모든 권한을 승인했다는 의미가 아닙니다!
            // 단지 권한 UI가 정상적으로 표시되었다는 의미입니다.
            
            await MainActor.run {
                self.authorizationComplete = true
            }
            
            // 실제 데이터를 조회해봐야 권한이 있는지 알 수 있습니다
            // (그것도 "데이터 없음"과 "권한 거부"를 구분할 수 없음)
            
        } catch {
            // 권한 UI를 표시하는 데 실패한 경우
            print("권한 요청 실패: \(error)")
        }
    }
}
