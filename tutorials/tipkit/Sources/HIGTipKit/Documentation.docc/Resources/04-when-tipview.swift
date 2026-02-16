import SwiftUI
import TipKit

// MARK: - TipView가 적합한 경우

struct AnnouncementTip: Tip {
    var title: Text { Text("새로운 업데이트") }
    var message: Text? { Text("버전 2.0의 새로운 기능을 확인해보세요") }
    var actions: [Action] { Action(id: "learn", title: "자세히 보기") }
}

struct WhenToUseTipView: View {
    let announcementTip = AnnouncementTip()
    
    var body: some View {
        List {
            // ✅ 리스트 상단에 공지/안내 삽입
            TipView(announcementTip)
            
            Section("최근 항목") {
                ForEach(0..<5) { i in
                    Text("항목 \(i)")
                }
            }
        }
    }
}

// TipView 적합 시나리오:
// - 리스트/스크롤 내 콘텐츠로 삽입
// - 화면 상단/하단에 고정 안내 표시
// - 섹션 사이에 가이드 메시지 삽입
// - 레이아웃의 일부로 팁 배치
