import SwiftUI
import TipKit

// MARK: - 복수 이벤트 정의
// 여러 행동을 각각 추적합니다.

struct ProTip: Tip {
    // 여러 이벤트 정의
    static let photoEdited = Event(id: "photoEdited")
    static let filterApplied = Event(id: "filterApplied")
    static let photoExported = Event(id: "photoExported")
    
    var title: Text {
        Text("프로 편집 팁")
    }
    
    var message: Text? {
        Text("레이어와 마스크를 사용해보세요")
    }
    
    var image: Image? {
        Image(systemName: "wand.and.stars")
    }
}

// 각 이벤트는 독립적으로 추적됨
struct PhotoEditor: View {
    var body: some View {
        VStack {
            Button("편집") {
                ProTip.photoEdited.donate()
            }
            
            Button("필터 적용") {
                ProTip.filterApplied.donate()
            }
            
            Button("내보내기") {
                ProTip.photoExported.donate()
            }
        }
    }
}
