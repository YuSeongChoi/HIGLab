import SwiftUI
import TipKit

// 각각 다른 기능에 대한 팁
struct EditTip: Tip {
    var title: Text { Text("편집") }
    var message: Text? { Text("콘텐츠를 수정할 수 있어요") }
}

struct ShareTip: Tip {
    var title: Text { Text("공유") }
    var message: Text? { Text("친구에게 공유해보세요") }
}

struct DeleteTip: Tip {
    var title: Text { Text("삭제") }
    var message: Text? { Text("필요 없는 항목을 삭제하세요") }
}

struct SequentialTipsView: View {
    let editTip = EditTip()
    let shareTip = ShareTip()
    let deleteTip = DeleteTip()
    
    var body: some View {
        HStack(spacing: 20) {
            // TipKit은 자동으로 한 번에 하나만 표시
            // 첫 번째 팁을 닫으면 두 번째 팁이 표시됨
            
            Button { } label: {
                Image(systemName: "pencil")
            }
            .popoverTip(editTip)
            
            Button { } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .popoverTip(shareTip)
            
            Button { } label: {
                Image(systemName: "trash")
            }
            .popoverTip(deleteTip)
        }
        .font(.title2)
    }
}
