import AVFoundation

// MARK: - AVPlayer 기본 사용

// URL에서 비디오 재생
let videoURL = URL(string: "https://example.com/video.mp4")!
let player = AVPlayer(url: videoURL)

// 재생 시작
player.play()

// 일시정지
player.pause()

// 현재 재생 시간
let currentTime = player.currentTime()

// 특정 시간으로 이동
player.seek(to: CMTime(seconds: 30, preferredTimescale: 1))

// MARK: - 재생 상태 관찰

import Combine

class PlayerObserver {
    var player: AVPlayer
    var cancellables = Set<AnyCancellable>()
    
    init(player: AVPlayer) {
        self.player = player
        
        // 재생/일시정지 상태 관찰
        player.publisher(for: \.timeControlStatus)
            .sink { status in
                switch status {
                case .paused:
                    print("일시정지")
                case .playing:
                    print("재생 중")
                case .waitingToPlayAtSpecifiedRate:
                    print("버퍼링 중")
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
