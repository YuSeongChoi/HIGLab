import AVFoundation

// MARK: - AVPlayerItem

// URL에서 PlayerItem 생성
let url = URL(string: "https://example.com/video.mp4")!
let playerItem = AVPlayerItem(url: url)

// AVAsset에서 생성
let asset = AVURLAsset(url: url)
let itemFromAsset = AVPlayerItem(asset: asset)

// Player에 설정
let player = AVPlayer(playerItem: playerItem)

// MARK: - PlayerItem 속성

// 전체 길이
let duration = playerItem.duration
let seconds = CMTimeGetSeconds(duration)

// 현재 로드된 시간 범위
let loadedRanges = playerItem.loadedTimeRanges

// 재생 가능 여부
let isPlayable = playerItem.status == .readyToPlay

// MARK: - PlayerItem 교체

// 다른 미디어로 교체
let newURL = URL(string: "https://example.com/video2.mp4")!
let newItem = AVPlayerItem(url: newURL)
player.replaceCurrentItem(with: newItem)

// MARK: - 상태 관찰

import Combine

class ItemObserver {
    var cancellables = Set<AnyCancellable>()
    
    func observe(_ item: AVPlayerItem) {
        item.publisher(for: \.status)
            .sink { status in
                switch status {
                case .unknown:
                    print("상태 알 수 없음")
                case .readyToPlay:
                    print("재생 준비 완료")
                case .failed:
                    print("로드 실패: \(item.error?.localizedDescription ?? "")")
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
