import SwiftUI
import Photos
import PhotosUI

// MARK: - 메인 콘텐츠 뷰
/// 앱의 메인 탭 네비게이션 구조
/// 사진 그리드, 앨범, 검색, 설정 탭으로 구성
struct ContentView: View {
    
    // MARK: - 환경 객체
    
    @EnvironmentObject private var photoLibraryViewModel: PhotoLibraryViewModel
    @EnvironmentObject private var albumViewModel: AlbumViewModel
    
    // MARK: - 상태
    
    /// 현재 선택된 탭
    @State private var selectedTab: Tab = .photos
    
    /// 권한 거부 알림 표시 여부
    @State private var showPermissionAlert = false
    
    // MARK: - 탭 열거형
    
    enum Tab: String, CaseIterable {
        case photos = "사진"
        case albums = "앨범"
        case favorites = "즐겨찾기"
        case search = "검색"
        
        var iconName: String {
            switch self {
            case .photos: return "photo.on.rectangle.angled"
            case .albums: return "rectangle.stack"
            case .favorites: return "heart"
            case .search: return "magnifyingglass"
            }
        }
    }
    
    // MARK: - 뷰 바디
    
    var body: some View {
        Group {
            switch photoLibraryViewModel.authorizationStatus {
            case .authorized, .limited:
                // 권한 있음 - 메인 콘텐츠 표시
                mainTabView
                
            case .denied, .restricted:
                // 권한 거부됨 - 설정 안내
                permissionDeniedView
                
            case .notDetermined:
                // 권한 미결정 - 요청 대기 중
                requestingPermissionView
                
            @unknown default:
                EmptyView()
            }
        }
        .task {
            // 초기 권한 확인 및 앨범 로드
            if photoLibraryViewModel.authorizationStatus == .authorized ||
               photoLibraryViewModel.authorizationStatus == .limited {
                await albumViewModel.loadAlbums()
            }
        }
    }
    
    // MARK: - 메인 탭 뷰
    
    /// 메인 탭바 인터페이스
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            // 사진 탭
            PhotoGridView()
                .tabItem {
                    Label(Tab.photos.rawValue, systemImage: Tab.photos.iconName)
                }
                .tag(Tab.photos)
            
            // 앨범 탭
            AlbumListView()
                .tabItem {
                    Label(Tab.albums.rawValue, systemImage: Tab.albums.iconName)
                }
                .tag(Tab.albums)
            
            // 즐겨찾기 탭
            FavoritesView()
                .tabItem {
                    Label(Tab.favorites.rawValue, systemImage: Tab.favorites.iconName)
                }
                .tag(Tab.favorites)
            
            // 검색 탭
            SearchView()
                .tabItem {
                    Label(Tab.search.rawValue, systemImage: Tab.search.iconName)
                }
                .tag(Tab.search)
        }
    }
    
    // MARK: - 권한 거부 뷰
    
    /// 권한 거부 시 표시되는 안내 뷰
    private var permissionDeniedView: some View {
        ContentUnavailableView {
            Label("사진 접근 권한 필요", systemImage: "photo.badge.exclamationmark")
        } description: {
            Text("사진 앱을 사용하려면 사진 라이브러리에 대한 접근 권한이 필요합니다.\n설정에서 권한을 허용해주세요.")
                .multilineTextAlignment(.center)
        } actions: {
            Button("설정 열기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - 권한 요청 대기 뷰
    
    /// 권한 요청 중 표시되는 뷰
    private var requestingPermissionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("사진 라이브러리 접근 중...")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            ProgressView()
        }
    }
}

// MARK: - 즐겨찾기 뷰
/// 즐겨찾기한 사진만 표시하는 뷰
struct FavoritesView: View {
    
    @EnvironmentObject private var viewModel: PhotoLibraryViewModel
    
    var body: some View {
        NavigationStack {
            PhotoGridView(filterType: .favorites)
                .navigationTitle("즐겨찾기")
        }
    }
}

// MARK: - 검색 뷰
/// 사진 검색 인터페이스
struct SearchView: View {
    
    @EnvironmentObject private var viewModel: PhotoLibraryViewModel
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if searchText.isEmpty {
                    // 검색 전 상태
                    searchPromptView
                } else {
                    // 검색 결과
                    PhotoGridView()
                }
            }
            .navigationTitle("검색")
            .searchable(text: $searchText, prompt: "파일명으로 검색")
            .onChange(of: searchText) { _, newValue in
                viewModel.searchQuery = newValue
            }
        }
    }
    
    /// 검색 안내 뷰
    private var searchPromptView: some View {
        ContentUnavailableView {
            Label("사진 검색", systemImage: "magnifyingglass")
        } description: {
            Text("파일명으로 사진을 검색할 수 있습니다")
        }
    }
}

// MARK: - 프리뷰
#Preview {
    ContentView()
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(AlbumViewModel())
}
