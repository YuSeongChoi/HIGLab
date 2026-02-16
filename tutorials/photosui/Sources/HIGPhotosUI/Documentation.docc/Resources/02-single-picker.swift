// PhotosPicker 단일 선택 구현

import SwiftUI
import PhotosUI

struct SinglePickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    
    var body: some View {
        VStack(spacing: 20) {
            // 선택된 이미지 표시
            Group {
                if let image = selectedImage {
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .frame(height: 250)
            .padding()
            
            // PhotosPicker - selection에 단일 항목 바인딩
            PhotosPicker(
                selection: $selectedItem,       // PhotosPickerItem?
                matching: .images,              // 이미지만
                photoLibrary: .shared()         // 기본 사진 라이브러리
            ) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text(selectedImage == nil ? "사진 선택" : "다른 사진 선택")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                await loadImage(from: newItem)
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item else { return }
        
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            selectedImage = Image(uiImage: uiImage)
        }
    }
}
