// 그리드 레이아웃 설정

import SwiftUI
import PhotosUI

struct GridLayoutView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var images: [Image] = []
    
    // Adaptive 컬럼 - 최소 100pt, 화면에 맞게 자동 조절
    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 4)
    ]
    
    // 또는 고정 개수 컬럼
    let fixedColumns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(images.indices, id: \.self) { index in
                        images[index]
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fill)  // 정사각형
                            .clipped()
                    }
                }
                .padding(4)
            }
            
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 20,
                selectionBehavior: .ordered,
                matching: .images
            ) {
                Label("사진 추가", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .padding()
        }
        .onChange(of: selectedItems) { _, _ in
            Task {
                await loadImages()
            }
        }
    }
    
    private func loadImages() async {
        images.removeAll()
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                images.append(Image(uiImage: uiImage))
            }
        }
    }
}
