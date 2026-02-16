// 필터 조합하기

import SwiftUI
import PhotosUI

struct CombinedFilterView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(spacing: 30) {
            // OR 조합: 이미지 또는 비디오
            PhotosPicker(
                selection: $selectedItems,
                matching: .any(of: [.images, .videos])  // 이미지 OR 비디오
            ) {
                Label("이미지 & 비디오", systemImage: "photo.on.rectangle.angled")
            }
            .buttonStyle(.borderedProminent)
            
            // OR 조합: 모든 미디어 타입
            PhotosPicker(
                selection: $selectedItems,
                matching: .any(of: [
                    .images,
                    .videos,
                    .livePhotos
                ])
            ) {
                Label("모든 미디어", systemImage: "square.stack.3d.up")
            }
            .buttonStyle(.borderedProminent)
            
            // AND 조합: 인물 사진이면서 라이브 포토
            PhotosPicker(
                selection: $selectedItems,
                matching: .all(of: [
                    .depthEffectPhotos,  // 인물 사진 (depth effect)
                    .livePhotos          // 라이브 포토
                ])
            ) {
                Label("인물 라이브 포토", systemImage: "person.fill.viewfinder")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

/*
 .any(of:) - OR 조합
 - 조건 중 하나라도 만족하면 선택 가능
 - 예: 이미지 또는 비디오
 
 .all(of:) - AND 조합
 - 모든 조건을 만족해야 선택 가능
 - 예: 인물 사진이면서 라이브 포토
 */
