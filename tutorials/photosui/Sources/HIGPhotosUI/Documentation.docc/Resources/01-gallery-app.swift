// GalleryApp 프로젝트 설정

import SwiftUI
import PhotosUI  // PhotosPicker 사용을 위해 import

@main
struct GalleryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Info.plist에 권한 설정이 필요 없습니다!
// PhotosPicker는 사용자가 선택한 사진만 접근하므로
// 별도의 권한 요청 없이 바로 사용 가능합니다.
