import SwiftUI
import ImagePlayground

// MARK: - ContentView
// 앱의 메인 컨텐츠 뷰
// 탭 기반 네비게이션으로 이미지 생성과 갤러리 기능 제공

/// 메인 컨텐츠 뷰
struct ContentView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject private var storageManager: ImageStorageManager
    @EnvironmentObject private var viewModel: ImageMakerViewModel
    
    // MARK: - State
    
    /// 현재 선택된 탭
    @State private var selectedTab: Tab = .create
    
    /// 온보딩 표시 여부
    @State private var showOnboarding = false
    
    // MARK: - Tab Enum
    
    enum Tab: String, CaseIterable {
        case create = "만들기"
        case gallery = "갤러리"
        case settings = "설정"
        
        var icon: String {
            switch self {
            case .create: return "wand.and.stars"
            case .gallery: return "photo.stack"
            case .settings: return "gearshape"
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 이미지 생성 탭
            ImageGeneratorView()
                .tabItem {
                    Label(Tab.create.rawValue, systemImage: Tab.create.icon)
                }
                .tag(Tab.create)
            
            // 갤러리 탭
            HistoryGalleryView()
                .tabItem {
                    Label(Tab.gallery.rawValue, systemImage: Tab.gallery.icon)
                }
                .tag(Tab.gallery)
            
            // 설정 탭
            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(AppTheme.accentColor)
        .sheet(item: $viewModel.selectedImageForDetail) { image in
            ImageDetailView(image: image)
        }
        .alert("오류", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("확인", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .overlay {
            // 성공 토스트
            if let successMessage = viewModel.successMessage {
                successToast(message: successMessage)
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 성공 토스트 메시지
    @ViewBuilder
    private func successToast(message: String) -> some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(message)
                    .font(.subheadline)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 10)
            .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(duration: 0.4), value: viewModel.successMessage)
        .onAppear {
            // 2초 후 자동으로 사라짐
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                viewModel.clearSuccess()
            }
        }
    }
}

// MARK: - SettingsView
// 설정 화면

/// 설정 뷰
struct SettingsView: View {
    
    @EnvironmentObject private var storageManager: ImageStorageManager
    
    /// 모든 이미지 삭제 확인 표시
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                // 앱 정보 섹션
                Section {
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .font(.largeTitle)
                            .foregroundStyle(AppTheme.primaryGradient)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(AppConstants.appName)
                                .font(.headline)
                            Text(AppConstants.appDescription)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("앱 정보")
                }
                
                // 저장소 섹션
                Section {
                    // 저장된 이미지 수
                    HStack {
                        Label("저장된 이미지", systemImage: "photo.fill")
                        Spacer()
                        Text("\(storageManager.totalCount)개")
                            .foregroundStyle(.secondary)
                    }
                    
                    // 저장소 사용량
                    HStack {
                        Label("저장 공간 사용", systemImage: "internaldrive")
                        Spacer()
                        Text(storageManager.formattedStorageUsage)
                            .foregroundStyle(.secondary)
                    }
                    
                    // 스타일별 통계
                    ForEach(ImageStyle.allCases) { style in
                        HStack {
                            Label(style.displayName, systemImage: style.iconName)
                                .foregroundStyle(style.themeColor)
                            Spacer()
                            Text("\(storageManager.countByStyle[style] ?? 0)개")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("저장소")
                }
                
                // 위험 영역
                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("모든 이미지 삭제", systemImage: "trash")
                    }
                    .disabled(storageManager.totalCount == 0)
                } header: {
                    Text("데이터 관리")
                } footer: {
                    Text("삭제된 이미지는 복구할 수 없습니다.")
                }
                
                // Image Playground 정보
                Section {
                    if #available(iOS 26.0, *) {
                        HStack {
                            Label("Image Playground", systemImage: "sparkles")
                            Spacer()
                            if ImagePlaygroundViewController.isAvailable {
                                Text("사용 가능")
                                    .foregroundStyle(.green)
                            } else {
                                Text("사용 불가")
                                    .foregroundStyle(.red)
                            }
                        }
                    } else {
                        HStack {
                            Label("Image Playground", systemImage: "sparkles")
                            Spacer()
                            Text("iOS 26 필요")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("시스템")
                } footer: {
                    Text("Image Playground는 iOS 26 이상에서 지원되며, Apple Intelligence가 활성화된 기기에서 사용할 수 있습니다.")
                }
            }
            .navigationTitle("설정")
            .confirmationDialog(
                "모든 이미지 삭제",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("모두 삭제", role: .destructive) {
                    storageManager.deleteAllImages()
                    HapticFeedback.success()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("저장된 모든 이미지(\(storageManager.totalCount)개)가 삭제됩니다. 이 작업은 되돌릴 수 없습니다.")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(ImageStorageManager.shared)
        .environmentObject(ImageMakerViewModel())
}
