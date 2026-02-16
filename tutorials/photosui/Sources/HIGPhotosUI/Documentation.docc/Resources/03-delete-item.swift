// 개별 항목 삭제 기능

import SwiftUI
import PhotosUI

struct DeleteItemView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var images: [(id: String, image: Image)] = []
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(images.indices, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            images[index].image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            // 삭제 버튼
                            Button {
                                deleteItem(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white, .red)
                                    .shadow(radius: 2)
                            }
                            .offset(x: 6, y: -6)
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                Text("\(images.count)장")
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // 전체 삭제
                if !images.isEmpty {
                    Button("전체 삭제", role: .destructive) {
                        withAnimation {
                            selectedItems.removeAll()
                            images.removeAll()
                        }
                    }
                }
                
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 20,
                    matching: .images
                ) {
                    Label("추가", systemImage: "plus")
                }
            }
            .padding()
        }
        .onChange(of: selectedItems) { _, _ in
            Task { await loadImages() }
        }
    }
    
    private func deleteItem(at index: Int) {
        withAnimation {
            selectedItems.remove(at: index)
            images.remove(at: index)
        }
    }
    
    private func loadImages() async {
        images.removeAll()
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                let id = item.itemIdentifier ?? UUID().uuidString
                images.append((id: id, image: Image(uiImage: uiImage)))
            }
        }
    }
}
