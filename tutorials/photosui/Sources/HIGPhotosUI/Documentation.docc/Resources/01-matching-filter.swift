// PHPickerFilter로 미디어 타입 필터링

import SwiftUI
import PhotosUI

struct FilterExamplesView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(spacing: 20) {
            // 이미지만
            PhotosPicker(selection: $selectedItems, matching: .images) {
                Text("이미지만")
            }
            
            // 비디오만
            PhotosPicker(selection: $selectedItems, matching: .videos) {
                Text("비디오만")
            }
            
            // 라이브 포토만
            PhotosPicker(selection: $selectedItems, matching: .livePhotos) {
                Text("라이브 포토만")
            }
            
            // 스크린샷만
            PhotosPicker(selection: $selectedItems, matching: .screenshots) {
                Text("스크린샷만")
            }
            
            // 인물 사진 (depth effect)
            PhotosPicker(selection: $selectedItems, matching: .depthEffectPhotos) {
                Text("인물 사진만")
            }
            
            // 이미지 + 비디오 (조합)
            PhotosPicker(
                selection: $selectedItems,
                matching: .any(of: [.images, .videos])
            ) {
                Text("이미지 또는 비디오")
            }
        }
    }
}
