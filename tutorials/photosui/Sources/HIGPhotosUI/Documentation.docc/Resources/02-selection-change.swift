// 선택 변화 감지 및 이미지 로딩

import SwiftUI
import PhotosUI

struct SelectionChangeView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            // 이미지 표시
            ZStack {
                if let image = selectedImage {
                    image
                        .resizable()
                        .scaledToFit()
                }
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
            .frame(height: 300)
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("사진 선택")
            }
        }
        // 방법 1: onChange 사용
        .onChange(of: selectedItem) { oldItem, newItem in
            Task {
                isLoading = true
                defer { isLoading = false }
                
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = Image(uiImage: uiImage)
                }
            }
        }
        
        // 방법 2: task(id:) 사용 (더 간결)
        // .task(id: selectedItem) {
        //     if let data = try? await selectedItem?.loadTransferable(type: Data.self),
        //        let uiImage = UIImage(data: data) {
        //         selectedImage = Image(uiImage: uiImage)
        //     }
        // }
    }
}
