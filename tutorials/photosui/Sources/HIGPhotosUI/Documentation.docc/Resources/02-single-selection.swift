// 단일 선택을 위한 State 변수

import SwiftUI
import PhotosUI

struct SingleSelectionView: View {
    // Optional PhotosPickerItem - 선택 전에는 nil
    @State private var selectedItem: PhotosPickerItem?
    
    // 로딩된 이미지
    @State private var loadedImage: Image?
    
    // 로딩 상태
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            // 이미지 표시 영역
            if let image = loadedImage {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
            } else if isLoading {
                ProgressView("로딩 중...")
            } else {
                ContentUnavailableView(
                    "사진 없음",
                    systemImage: "photo",
                    description: Text("아래 버튼을 눌러 사진을 선택하세요")
                )
            }
            
            Spacer()
            
            // PhotosPicker
            PhotosPicker(
                selection: $selectedItem,  // 단일 항목 바인딩
                matching: .images
            ) {
                Label("사진 선택", systemImage: "photo.badge.plus")
                    .font(.headline)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }
}
