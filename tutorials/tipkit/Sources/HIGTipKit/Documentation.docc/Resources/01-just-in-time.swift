import SwiftUI
import TipKit

// MARK: - Just-in-Time 팁의 예시
// 사용자가 사진 편집 화면에 진입했을 때
// 해당 맥락에서 의미 있는 팁을 표시합니다.

struct CompareOriginalTip: Tip {
    var title: Text {
        Text("원본과 비교하기")
    }
    
    var message: Text? {
        Text("화면을 더블 탭하면 원본 사진과 비교할 수 있어요")
    }
    
    var image: Image? {
        Image(systemName: "photo.on.rectangle")
    }
}

struct PhotoEditView: View {
    let compareTip = CompareOriginalTip()
    
    var body: some View {
        VStack {
            // 편집 중인 사진
            Image("edited-photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            // 편집 도구 위에 팁 표시
            TipView(compareTip)
                .padding()
            
            // 편집 도구들...
            EditingToolbar()
        }
    }
}
