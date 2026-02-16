import SwiftUI
import TipKit

// MARK: - 비침습적 팁 디자인
// 팁은 화면을 차지하지 않고, 자연스럽게 UI에 녹아듭니다.
// 사용자는 언제든 팁을 무시하거나 닫을 수 있습니다.

struct ShortcutTip: Tip {
    var title: Text {
        Text("키보드 단축키")
    }
    
    var message: Text? {
        Text("⌘ + S로 빠르게 저장할 수 있어요")
    }
    
    var image: Image? {
        Image(systemName: "keyboard")
    }
}

struct DocumentView: View {
    let shortcutTip = ShortcutTip()
    
    var body: some View {
        VStack(spacing: 0) {
            // 문서 내용
            TextEditor(text: .constant("문서 내용..."))
            
            // 팁은 하단에 자연스럽게 표시됨
            // 사용자가 X 버튼을 누르면 사라짐
            TipView(shortcutTip)
                .padding()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("저장") {
                    // 저장 로직
                }
            }
        }
    }
}
