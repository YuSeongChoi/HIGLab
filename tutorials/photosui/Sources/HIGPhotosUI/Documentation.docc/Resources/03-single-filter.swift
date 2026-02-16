// 단일 필터 적용

import SwiftUI
import PhotosUI

struct SingleFilterView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var currentFilter: PHPickerFilter = .images
    
    var body: some View {
        VStack(spacing: 20) {
            // 필터 선택 Picker
            Picker("미디어 타입", selection: $currentFilter) {
                Text("이미지").tag(PHPickerFilter.images)
                Text("비디오").tag(PHPickerFilter.videos)
                Text("라이브 포토").tag(PHPickerFilter.livePhotos)
                Text("스크린샷").tag(PHPickerFilter.screenshots)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // 현재 필터로 PhotosPicker 생성
            PhotosPicker(
                selection: $selectedItems,
                matching: currentFilter,  // 동적 필터
                photoLibrary: .shared()
            ) {
                Label("선택하기", systemImage: filterIcon)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            Text("선택됨: \(selectedItems.count)개")
        }
    }
    
    private var filterIcon: String {
        switch currentFilter {
        case .images: return "photo"
        case .videos: return "video"
        case .livePhotos: return "livephoto"
        case .screenshots: return "camera.viewfinder"
        default: return "photo.stack"
        }
    }
}
