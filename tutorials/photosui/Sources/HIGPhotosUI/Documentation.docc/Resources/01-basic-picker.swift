// 기본 PhotosPicker 사용법

import SwiftUI
import PhotosUI

struct BasicPickerView: View {
    // 선택된 항목을 저장할 State
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack {
            // PhotosPicker 기본 사용
            PhotosPicker(
                selection: $selectedItem,  // 바인딩
                matching: .images           // 이미지만 필터링
            ) {
                Label("사진 선택", systemImage: "photo")
            }
            
            // 선택된 항목이 있으면 표시
            if let item = selectedItem {
                Text("선택됨: \(item.itemIdentifier ?? "알 수 없음")")
            }
        }
    }
}
