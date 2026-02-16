// 필터 제외하기

import SwiftUI
import PhotosUI

struct ExcludeFilterView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(spacing: 30) {
            // 스크린샷 제외한 이미지
            PhotosPicker(
                selection: $selectedItems,
                matching: .all(of: [
                    .images,
                    .not(.screenshots)  // 스크린샷 제외
                ])
            ) {
                Label("이미지 (스크린샷 제외)", systemImage: "photo")
            }
            .buttonStyle(.borderedProminent)
            
            // 라이브 포토 제외한 모든 사진
            PhotosPicker(
                selection: $selectedItems,
                matching: .all(of: [
                    .images,
                    .not(.livePhotos)
                ])
            ) {
                Label("정지 이미지만", systemImage: "photo.fill")
            }
            .buttonStyle(.borderedProminent)
            
            // 복잡한 조합
            PhotosPicker(
                selection: $selectedItems,
                matching: .all(of: [
                    .any(of: [.images, .videos]),  // 이미지 또는 비디오
                    .not(.screenshots),             // 스크린샷 제외
                    .not(.screenRecordings)         // 화면 녹화 제외
                ])
            ) {
                Label("진짜 미디어만", systemImage: "camera.fill")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

/*
 .not(_:) - 특정 타입 제외
 
 유용한 조합 예시:
 - 스크린샷 제외 이미지: .all(of: [.images, .not(.screenshots)])
 - 화면 녹화 제외 비디오: .all(of: [.videos, .not(.screenRecordings)])
 - 진짜 카메라 사진만: .all(of: [.images, .not(.screenshots), .not(.livePhotos)])
 */
