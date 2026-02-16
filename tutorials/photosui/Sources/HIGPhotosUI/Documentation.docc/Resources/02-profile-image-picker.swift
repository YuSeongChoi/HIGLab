// 재사용 가능한 ProfileImagePicker 컴포넌트

import SwiftUI
import PhotosUI

struct ProfileImagePicker: View {
    @Binding var image: Image?
    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoading = false
    
    let size: CGFloat
    
    init(image: Binding<Image?>, size: CGFloat = 120) {
        self._image = image
        self.size = size
    }
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            profileImage
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                await loadImage(from: newItem)
            }
        }
    }
    
    @ViewBuilder
    private var profileImage: some View {
        ZStack {
            // 배경 원
            Circle()
                .fill(.gray.opacity(0.2))
                .frame(width: size, height: size)
            
            // 이미지 또는 placeholder
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(.gray)
            }
            
            // 로딩 오버레이
            if isLoading {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: size, height: size)
                ProgressView()
            }
            
            // 편집 아이콘
            if !isLoading {
                Circle()
                    .fill(.blue)
                    .frame(width: size * 0.3, height: size * 0.3)
                    .overlay {
                        Image(systemName: "camera.fill")
                            .font(.system(size: size * 0.12))
                            .foregroundStyle(.white)
                    }
                    .offset(x: size * 0.35, y: size * 0.35)
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            image = Image(uiImage: uiImage)
        }
    }
}
