import SwiftUI
import TipKit

// MARK: - 맥락 적합성 (Contextual Relevance)
// 팁은 해당 기능이 화면에 보일 때 표시되어야 합니다.

struct EditModeTip: Tip {
    var title: Text {
        Text("편집 모드 활성화")
    }
    
    var message: Text? {
        Text("편집 버튼을 탭하면 항목을 재정렬하거나 삭제할 수 있어요")
    }
}

// ✅ 좋은 예: 리스트 화면에서 편집 기능 팁 표시
struct GoodContextView: View {
    let editTip = EditModeTip()
    
    var body: some View {
        NavigationStack {
            List {
                // 리스트 상단에 팁 표시 - 편집 버튼이 보이는 맥락
                TipView(editTip)
                
                ForEach(0..<10) { index in
                    Text("항목 \(index)")
                }
            }
            .toolbar {
                EditButton()  // 팁이 설명하는 기능이 바로 여기 있음
            }
        }
    }
}

// ❌ 나쁜 예: 설정 화면에서 편집 기능 팁 표시
struct BadContextView: View {
    let editTip = EditModeTip()
    
    var body: some View {
        NavigationStack {
            Form {
                // 설정 화면에서 편집 팁? 맥락이 안 맞음!
                TipView(editTip)  // ❌ 적절하지 않음
                
                Section("일반") {
                    Toggle("알림", isOn: .constant(true))
                }
            }
        }
    }
}
