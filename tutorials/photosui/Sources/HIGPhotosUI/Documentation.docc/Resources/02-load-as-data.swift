// Data 타입으로 이미지 로딩

import SwiftUI
import PhotosUI

struct LoadAsDataView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var displayImage: Image?
    
    var body: some View {
        VStack {
            if let image = displayImage {
                image
                    .resizable()
                    .scaledToFit()
            }
            
            if let data = imageData {
                Text("데이터 크기: \(data.count / 1024) KB")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("사진 선택")
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                await loadAsData(from: newItem)
            }
        }
    }
    
    private func loadAsData(from item: PhotosPickerItem?) async {
        guard let item else {
            imageData = nil
            displayImage = nil
            return
        }
        
        do {
            // Data 타입으로 로딩
            if let data = try await item.loadTransferable(type: Data.self) {
                imageData = data
                
                // Data -> UIImage -> SwiftUI Image
                if let uiImage = UIImage(data: data) {
                    displayImage = Image(uiImage: uiImage)
                }
            }
        } catch {
            print("로딩 실패: \(error)")
            imageData = nil
            displayImage = nil
        }
    }
}
