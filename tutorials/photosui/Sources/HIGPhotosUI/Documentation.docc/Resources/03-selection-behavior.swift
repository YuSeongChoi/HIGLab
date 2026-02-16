// 선택 동작 제어

import SwiftUI
import PhotosUI

struct SelectionBehaviorView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(spacing: 20) {
            // 기본 동작 (.default)
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 10,
                selectionBehavior: .default,  // 순서 보장 안됨
                matching: .images
            ) {
                Text("기본 (.default)")
            }
            
            // 순서 유지 (.ordered)
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 10,
                selectionBehavior: .ordered,  // ✅ 순서 유지 + 번호 표시
                matching: .images
            ) {
                Text("순서 유지 (.ordered)")
            }
            
            // 현재 선택 순서 표시
            if !selectedItems.isEmpty {
                VStack(alignment: .leading) {
                    Text("선택 순서:")
                        .font(.headline)
                    
                    ForEach(selectedItems.indices, id: \.self) { index in
                        Text("\(index + 1). \(selectedItems[index].itemIdentifier ?? "알 수 없음")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
    }
}

/*
 .default: 
 - 선택 순서가 보장되지 않음
 - UI에 선택 번호가 표시되지 않음
 
 .ordered:
 - 선택한 순서대로 배열에 추가됨
 - Picker UI에 1, 2, 3... 순서 번호 표시
 - 스토리, 앨범 순서 지정에 유용
 */
