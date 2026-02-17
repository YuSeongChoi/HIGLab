import SwiftUI
import TipKit

@main
struct TipShowcaseApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // MARK: - TipKit 초기화
                    // 앱 시작 시 TipKit을 설정합니다.
                    await configureTips()
                }
        }
    }
    
    /// TipKit 설정을 초기화합니다.
    private func configureTips() async {
        do {
            // Tips.configure() 옵션:
            // - .displayFrequency: 팁 표시 빈도 (.immediate, .hourly, .daily, .weekly, .monthly)
            // - .datastoreLocation: 데이터 저장 위치
            try Tips.configure([
                // 개발 중에는 .immediate를 사용하여 팁을 즉시 확인
                // 프로덕션에서는 .daily 등으로 변경 권장
                .displayFrequency(.immediate),
                
                // 팁 데이터 저장 위치 (기본값 사용)
                .datastoreLocation(.applicationDefault)
            ])
            
            // 앱이 열릴 때마다 이벤트 기록 (ProTip 조건용)
            await TipEvents.recordAppOpened()
            
        } catch {
            // TipKit 설정 실패 시 에러 처리
            print("TipKit 설정 실패: \(error.localizedDescription)")
        }
    }
}

// MARK: - 디버그용 팁 리셋
#if DEBUG
extension TipShowcaseApp {
    /// 개발 중 모든 팁을 리셋하는 유틸리티
    static func resetAllTips() async {
        do {
            try Tips.resetDatastore()
            print("✅ 모든 팁이 리셋되었습니다.")
        } catch {
            print("❌ 팁 리셋 실패: \(error.localizedDescription)")
        }
    }
}
#endif
