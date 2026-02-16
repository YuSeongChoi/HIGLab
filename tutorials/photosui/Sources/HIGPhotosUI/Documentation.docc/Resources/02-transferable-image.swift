// Transferable을 구현한 이미지 타입

import SwiftUI
import PhotosUI

// SwiftUI Image를 Transferable로 만드는 래퍼
struct TransferableImage: Transferable {
    let image: Image
    let uiImage: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            let image = Image(uiImage: uiImage)
            return TransferableImage(image: image, uiImage: uiImage)
        }
    }
    
    enum TransferError: Error {
        case importFailed
    }
}

// 사용 예시
struct TransferableImageView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var transferableImage: TransferableImage?
    
    var body: some View {
        VStack {
            if let transferable = transferableImage {
                transferable.image
                    .resizable()
                    .scaledToFit()
            }
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("사진 선택")
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                // TransferableImage 타입으로 직접 로딩
                transferableImage = try? await newItem?.loadTransferable(
                    type: TransferableImage.self
                )
            }
        }
    }
}
