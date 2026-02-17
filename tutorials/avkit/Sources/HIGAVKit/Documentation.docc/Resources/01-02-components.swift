import AVKit
import AVFoundation

// MARK: - AVKit 주요 구성요소

/*
 1. AVPlayerViewController (iOS/tvOS)
    - 전체화면 비디오 플레이어
    - 시스템 재생 컨트롤 포함
    - PiP, AirPlay 자동 지원
 
 2. AVPlayerView (macOS)
    - macOS 네이티브 비디오 뷰
    - 커스텀 컨트롤 가능
 
 3. AVRoutePickerView
    - AirPlay 기기 선택 버튼
    - 출력 기기 변경
 
 4. AVPictureInPictureController
    - Picture-in-Picture 제어
    - 백그라운드 재생 지원
 */

// iOS에서 비디오 플레이어 사용
#if os(iOS)
import UIKit

class VideoPlayerViewController: UIViewController {
    private var playerVC: AVPlayerViewController?
    
    func setupPlayer(with url: URL) {
        let player = AVPlayer(url: url)
        
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        
        // 뷰에 추가
        addChild(playerVC)
        view.addSubview(playerVC.view)
        playerVC.view.frame = view.bounds
        playerVC.didMove(toParent: self)
        
        self.playerVC = playerVC
    }
}
#endif
