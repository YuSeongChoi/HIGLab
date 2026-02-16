// 최대 선택 개수 제한

import SwiftUI
import PhotosUI

struct MaxSelectionView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    
    // 최대 선택 가능 개수
    let maxCount = 5
    
    var body: some View {
        VStack {
            Text("최대 \(maxCount)장까지 선택 가능")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("선택됨: \(selectedItems.count) / \(maxCount)")
                .font(.headline)
            
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: maxCount,  // ✅ 최대 개수 제한
                matching: .images
            ) {
                Label("사진 선택", systemImage: "photo.stack")
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            
            // 선택된 개수에 따른 상태 메시지
            if selectedItems.count == maxCount {
                Label("최대 개수에 도달했습니다", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else if selectedItems.count > 0 {
                Text("\(maxCount - selectedItems.count)장 더 선택 가능")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
