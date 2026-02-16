// 비동기 이미지 로딩

import SwiftUI
import PhotosUI

// 개별 이미지 셀 - 각자 로딩 관리
struct AsyncImageCell: View {
    let item: PhotosPickerItem
    @State private var image: Image?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.gray.opacity(0.2))
            } else {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .clipped()
        .task {  // 뷰가 나타날 때 로딩 시작
            await loadImage()
        }
    }
    
    private func loadImage() async {
        defer { isLoading = false }
        
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            image = Image(uiImage: uiImage)
        }
    }
}

// 그리드에서 사용
struct AsyncGridView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(selectedItems, id: \.itemIdentifier) { item in
                    AsyncImageCell(item: item)  // 각 셀이 자체 로딩
                        .frame(height: 100)
                }
            }
        }
    }
}
