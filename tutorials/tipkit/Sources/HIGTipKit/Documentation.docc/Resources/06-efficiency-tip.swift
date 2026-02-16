import SwiftUI
import TipKit

// MARK: - 비효율 감지 팁 패턴
// 반복적인 비효율 행동을 감지하고 더 나은 방법을 안내합니다.

struct AutoRefreshTip: Tip {
    // 수동 새로고침 이벤트
    static let manualRefresh = Event(id: "manualRefresh")
    
    var title: Text {
        Text("자동 새로고침 켜기")
    }
    
    var message: Text? {
        Text("자동 새로고침을 켜면 항상 최신 정보를 볼 수 있어요")
    }
    
    var image: Image? {
        Image(systemName: "arrow.clockwise.circle")
    }
    
    // 수동 새로고침 5번 이상 시 팁 표시
    var rules: [Rule] {
        #Rule(Self.manualRefresh.donations.count >= 5) { $0 }
    }
}

struct ContentListView: View {
    let autoRefreshTip = AutoRefreshTip()
    
    var body: some View {
        List {
            TipView(autoRefreshTip)
            // 목록...
        }
        .refreshable {
            // 사용자가 당겨서 새로고침할 때마다 기록
            AutoRefreshTip.manualRefresh.donate()
            await loadData()
        }
    }
    
    func loadData() async {
        // 데이터 로드
    }
}
