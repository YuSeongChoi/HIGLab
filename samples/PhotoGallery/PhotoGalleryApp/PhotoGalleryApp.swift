import SwiftUI
import Photos

// MARK: - 앱 진입점
/// PhotoGallery 앱의 메인 진입점
/// Photos Framework를 활용한 완전한 갤러리 앱
@main
struct PhotoGalleryApp: App {
    
    // MARK: - 상태 객체
    
    /// 사진 라이브러리 뷰모델 (앱 전역 공유)
    @StateObject private var photoLibraryViewModel = PhotoLibraryViewModel()
    
    /// 앨범 뷰모델
    @StateObject private var albumViewModel = AlbumViewModel()
    
    // MARK: - 앱 씬
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(photoLibraryViewModel)
                .environmentObject(albumViewModel)
                .onAppear {
                    // 앱 시작 시 권한 요청 및 초기 데이터 로드
                    Task {
                        await photoLibraryViewModel.requestAuthorization()
                    }
                }
        }
    }
}
