import SwiftUI
import TipKit

// MARK: - 마일스톤 축하 팁 패턴
// 사용자의 달성을 축하하며 다음 기능을 소개합니다.

struct MilestoneTip: Tip {
    static let workoutCompleted = Event(id: "workoutCompleted")
    
    var title: Text {
        Text("🎉 10회 달성!")
    }
    
    var message: Text? {
        Text("운동 10회를 완료했어요! 운동 기록 분석 기능을 사용해보세요.")
    }
    
    var image: Image? {
        Image(systemName: "chart.bar.fill")
    }
    
    var actions: [Action] {
        Action(id: "view-stats", title: "기록 보기")
    }
    
    // 정확히 10회 완료 시 표시
    var rules: [Rule] {
        #Rule(Self.workoutCompleted.donations.count == 10) { $0 }
    }
}

struct WorkoutView: View {
    let milestoneTip = MilestoneTip()
    
    var body: some View {
        VStack {
            TipView(milestoneTip) { action in
                if action.id == "view-stats" {
                    // 통계 화면으로 이동
                }
            }
            
            Button("운동 완료") {
                MilestoneTip.workoutCompleted.donate()
            }
        }
    }
}
