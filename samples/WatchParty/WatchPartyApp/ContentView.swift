import SwiftUI
import GroupActivities

// MARK: - 메인 콘텐츠 뷰
// 앱의 메인 화면으로 탭 기반 네비게이션 제공

struct ContentView: View {
    @EnvironmentObject var sharePlayManager: SharePlayManager
    @EnvironmentObject var groupStateObserver: GroupStateObserver
    
    /// 현재 선택된 탭
    @State private var selectedTab = 0
    
    /// 선택된 비디오 (재생용)
    @State private var selectedVideo: Video?
    
    /// 비디오 플레이어 표시 여부
    @State private var showingPlayer = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 홈 탭 - 비디오 라이브러리
            NavigationStack {
                VideoLibraryView(
                    selectedVideo: $selectedVideo,
                    showingPlayer: $showingPlayer
                )
            }
            .tabItem {
                Label("홈", systemImage: "house.fill")
            }
            .tag(0)
            
            // 참여자 탭
            NavigationStack {
                ParticipantsView()
            }
            .tabItem {
                Label("참여자", systemImage: "person.2.fill")
            }
            .tag(1)
            
            // 설정 탭
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("설정", systemImage: "gear")
            }
            .tag(2)
        }
        .tint(AppTheme.primaryColor)
        // 비디오 플레이어 전체 화면 표시
        .fullScreenCover(isPresented: $showingPlayer) {
            if let video = selectedVideo {
                VideoPlayerView(video: video)
            }
        }
        // 세션 상태에 따른 오버레이
        .overlay(alignment: .top) {
            if sharePlayManager.sessionState.isActive {
                SharePlayBanner()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        // 에러 알림
        .alert("오류", isPresented: .init(
            get: { sharePlayManager.errorMessage != nil },
            set: { if !$0 { sharePlayManager.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            if let error = sharePlayManager.errorMessage {
                Text(error)
            }
        }
        .animation(.easeInOut, value: sharePlayManager.sessionState.isActive)
    }
}

// MARK: - SharePlay 배너
/// 세션 활성화 시 상단에 표시되는 배너
struct SharePlayBanner: View {
    @EnvironmentObject var sharePlayManager: SharePlayManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "shareplay")
                .font(.title3)
                .foregroundStyle(.white)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("SharePlay 활성화됨")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(sharePlayManager.sessionState.description)
                    .font(.caption)
                    .opacity(0.8)
            }
            .foregroundStyle(.white)
            
            Spacer()
            
            Button {
                sharePlayManager.endSession()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding()
        .background(AppTheme.gradient)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .padding(.horizontal)
        .padding(.top, 8)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}

// MARK: - 설정 뷰
struct SettingsView: View {
    @EnvironmentObject var sharePlayManager: SharePlayManager
    @EnvironmentObject var groupStateObserver: GroupStateObserver
    
    var body: some View {
        List {
            // SharePlay 상태 섹션
            Section {
                HStack {
                    Image(systemName: groupStateObserver.statusIcon)
                        .font(.title2)
                        .foregroundStyle(groupStateObserver.isSharePlayAvailable ? .green : .gray)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading) {
                        Text("SharePlay 상태")
                            .font(.headline)
                        Text(groupStateObserver.statusDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if sharePlayManager.sessionState.isActive {
                    Button(role: .destructive) {
                        sharePlayManager.endSession()
                    } label: {
                        Label("세션 종료", systemImage: "xmark.circle")
                    }
                }
            } header: {
                Text("SharePlay")
            }
            
            // 세션 설정 섹션
            Section {
                Toggle("모든 참여자 제어 허용", isOn: $sharePlayManager.configuration.everyoneCanControl)
                Toggle("자동 동기화", isOn: $sharePlayManager.configuration.autoSync)
                Toggle("반응 표시", isOn: $sharePlayManager.configuration.showReactions)
                Toggle("채팅 활성화", isOn: $sharePlayManager.configuration.chatEnabled)
            } header: {
                Text("세션 설정")
            }
            
            // 앱 정보 섹션
            Section {
                HStack {
                    Text("버전")
                    Spacer()
                    Text(AppConstants.version)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("최대 참여자")
                    Spacer()
                    Text("\(AppConstants.maxParticipants)명")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("앱 정보")
            } footer: {
                Text("WatchParty는 FaceTime SharePlay를 사용하여 친구들과 함께 비디오를 시청할 수 있습니다.")
            }
        }
        .navigationTitle("설정")
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(SharePlayManager())
        .environmentObject(GroupStateObserver())
}
