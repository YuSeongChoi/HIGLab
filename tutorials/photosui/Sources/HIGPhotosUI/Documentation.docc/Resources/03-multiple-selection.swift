// 다중 선택 구현

import SwiftUI
import PhotosUI

struct MultipleSelectionView: View {
    // 배열로 선언하면 다중 선택 모드!
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var loadedImages: [Image] = []
    
    var body: some View {
        VStack {
            // 선택된 개수 표시
            Text("선택됨: \(selectedItems.count)장")
                .font(.headline)
            
            // 선택된 이미지 그리드
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(loadedImages.indices, id: \.self) { index in
                        loadedImages[index]
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
            
            // 다중 선택 PhotosPicker
            PhotosPicker(
                selection: $selectedItems,  // [PhotosPickerItem] 바인딩
                matching: .images
            ) {
                Label("사진 추가", systemImage: "photo.badge.plus")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                await loadImages(from: newItems)
            }
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) async {
        loadedImages.removeAll()
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                loadedImages.append(Image(uiImage: uiImage))
            }
        }
    }
}
