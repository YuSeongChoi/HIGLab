// 완성된 갤러리 그리드 뷰

import SwiftUI
import PhotosUI

struct GalleryGridView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var loadedImages: [(id: String, image: Image)] = []
    @State private var isLoading = false
    
    let columns = [GridItem(.adaptive(minimum: 110), spacing: 2)]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if loadedImages.isEmpty && !isLoading {
                    ContentUnavailableView(
                        "사진을 추가하세요",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("아래 버튼을 눌러 사진을 선택하세요")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(loadedImages, id: \.id) { item in
                                item.image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                            }
                        }
                    }
                }
                
                // 하단 툴바
                HStack {
                    Text("\(loadedImages.count)장 선택됨")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 30,
                        selectionBehavior: .ordered,
                        matching: .images
                    ) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .navigationTitle("내 갤러리")
            .overlay {
                if isLoading {
                    ProgressView("로딩 중...")
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                await loadImages(from: newItems)
            }
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) async {
        isLoading = true
        defer { isLoading = false }
        
        loadedImages.removeAll()
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                let id = item.itemIdentifier ?? UUID().uuidString
                loadedImages.append((id: id, image: Image(uiImage: uiImage)))
            }
        }
    }
}
