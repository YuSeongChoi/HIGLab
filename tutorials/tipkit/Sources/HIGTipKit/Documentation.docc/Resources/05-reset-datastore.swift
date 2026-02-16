import SwiftUI
import TipKit

// MARK: - 모든 팁 리셋
// 개발/테스트 목적으로 모든 팁 상태를 초기화합니다.

struct ResetTipsView: View {
    var body: some View {
        VStack {
            Button("모든 팁 리셋") {
                resetAllTips()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    func resetAllTips() {
        // 모든 팁 기록 삭제
        // - 닫힌 팁도 다시 표시됨
        // - 이벤트 기록도 초기화됨
        // - 파라미터 값도 초기화됨
        try? Tips.resetDatastore()
        
        print("모든 팁 데이터가 초기화되었습니다")
    }
}

// ⚠️ 주의:
// - 프로덕션에서는 사용하지 않는 것이 좋음
// - 사용자 경험 연속성이 깨짐
// - 개발/테스트 목적으로만 사용
