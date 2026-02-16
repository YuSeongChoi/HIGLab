import SwiftUI
import AVKit
import GroupActivities

// ============================================
// SharePlay 지원 VideoPlayer View
// ============================================

struct SharePlayVideoPlayerView: View {
    let movie: Movie
    @StateObject private var viewModel = VideoPlayerViewModel()
    
    var body: some View {
        ZStack {
            // 비디오 플레이어
            VideoPlayer(player: viewModel.player)
                .ignoresSafeArea()
            
            // SharePlay 상태 오버레이
            if viewModel.isSharePlayActive {
                VStack {
                    HStack {
                        Image(systemName: "shareplay")
                        Text("\(viewModel.participantCount)명이 함께 보는 중")
                    }
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    
                    Spacer()
                }
                .padding()
            }
        }
        .task {
            await viewModel.startObserving(movie: movie)
        }
    }
}

@MainActor
class VideoPlayerViewModel: ObservableObject {
    let player = AVPlayer()
    @Published var isSharePlayActive = false
    @Published var participantCount = 0
    
    private var session: GroupSession<WatchTogetherActivity>?
    
    func startObserving(movie: Movie) async {
        // SharePlay 세션 관찰
        for await session in WatchTogetherActivity.sessions() {
            self.session = session
            configureSession(session, movie: movie)
        }
    }
    
    private func configureSession(_ session: GroupSession<WatchTogetherActivity>, movie: Movie) {
        // 영상 로드
        let item = AVPlayerItem(url: movie.videoURL)
        player.replaceCurrentItem(with: item)
        
        // SharePlay 연결
        player.playbackCoordinator.coordinateWithSession(session)
        
        // 상태 관찰
        Task {
            for await state in session.$state.values {
                isSharePlayActive = (state == .joined)
            }
        }
        
        Task {
            for await participants in session.$activeParticipants.values {
                participantCount = participants.count
            }
        }
        
        session.join()
        player.play()
    }
}
