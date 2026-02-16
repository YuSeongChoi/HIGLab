// PhotosPickerItem 이해하기

import SwiftUI
import PhotosUI

struct PickerItemView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var loadedImage: Image?
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedItem) {
                Text("사진 선택")
            }
            
            // selectedItem은 참조(레퍼런스)입니다.
            // 실제 이미지 데이터가 아닙니다!
            
            if let image = loadedImage {
                image
                    .resizable()
                    .scaledToFit()
            }
        }
        .onChange(of: selectedItem) { oldItem, newItem in
            // 선택이 변경되면 실제 데이터를 로딩합니다.
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    loadedImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}
