import SwiftUI
import TipKit

struct AddItemTip: Tip {
    var title: Text { Text("새 항목 추가") }
    var message: Text? { Text("탭하여 새로운 항목을 만들어보세요") }
    var image: Image? { Image(systemName: "plus.circle.fill") }
}

struct ToolbarTipView: View {
    let addTip = AddItemTip()
    @State private var items: [String] = []
    
    var body: some View {
        NavigationStack {
            List(items, id: \.self) { item in
                Text(item)
            }
            .navigationTitle("목록")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        items.append("새 항목 \(items.count + 1)")
                        addTip.invalidate(reason: .actionPerformed)
                    } label: {
                        Image(systemName: "plus")
                    }
                    // 툴바 버튼에 popoverTip 적용
                    .popoverTip(addTip)
                }
            }
        }
    }
}
