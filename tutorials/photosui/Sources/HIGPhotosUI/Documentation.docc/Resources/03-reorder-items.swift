// 드래그로 순서 변경

import SwiftUI
import PhotosUI

struct ReorderItemsView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var images: [ImageItem] = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(images) { item in
                    HStack {
                        item.image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading) {
                            Text("사진 \(item.order)")
                                .font(.headline)
                            Text(item.id.prefix(8) + "...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.secondary)
                    }
                }
                .onMove { from, to in
                    images.move(fromOffsets: from, toOffset: to)
                    updateOrder()
                }
            }
            .toolbar {
                EditButton()
            }
            .navigationTitle("순서 변경")
            
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 10,
                selectionBehavior: .ordered,
                matching: .images
            ) {
                Label("사진 추가", systemImage: "plus")
            }
            .padding()
        }
        .onChange(of: selectedItems) { _, _ in
            Task { await loadImages() }
        }
    }
    
    private func updateOrder() {
        for (index, _) in images.enumerated() {
            images[index].order = index + 1
        }
    }
    
    private func loadImages() async {
        images.removeAll()
        for (index, item) in selectedItems.enumerated() {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                let imageItem = ImageItem(
                    id: item.itemIdentifier ?? UUID().uuidString,
                    image: Image(uiImage: uiImage),
                    order: index + 1
                )
                images.append(imageItem)
            }
        }
    }
}

struct ImageItem: Identifiable {
    let id: String
    let image: Image
    var order: Int
}
