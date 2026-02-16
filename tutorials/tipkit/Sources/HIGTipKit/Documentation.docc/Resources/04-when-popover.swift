import SwiftUI
import TipKit

// MARK: - popoverTip이 적합한 경우

struct LongPressTip: Tip {
    var title: Text { Text("길게 누르기") }
    var message: Text? { Text("추가 옵션을 보려면 길게 누르세요") }
    var image: Image? { Image(systemName: "hand.tap") }
}

struct WhenToUsePopover: View {
    let longPressTip = LongPressTip()
    
    var body: some View {
        NavigationStack {
            List(0..<10, id: \.self) { index in
                Text("항목 \(index)")
                    .contextMenu {
                        Button("편집") { }
                        Button("삭제", role: .destructive) { }
                    }
            }
            .navigationTitle("목록")
            .toolbar {
                // ✅ 툴바 버튼에 기능 설명
                ToolbarItem {
                    Button { } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .popoverTip(longPressTip)
                }
            }
        }
    }
}

// popoverTip 적합 시나리오:
// - 특정 버튼/아이콘의 기능 설명
// - 툴바, 탭바 아이템 안내
// - 숨겨진 제스처(길게 누르기, 스와이프) 힌트
// - 설정 토글의 용도 설명
