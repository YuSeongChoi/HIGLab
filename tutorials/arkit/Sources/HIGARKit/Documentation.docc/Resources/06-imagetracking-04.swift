import ARKit
import RealityKit
import AVFoundation

func addVideoOverlay(to imageAnchor: ARImageAnchor) {
    let imageSize = imageAnchor.referenceImage.physicalSize
    
    // 비디오 플레이어 설정
    guard let videoURL = Bundle.main.url(forResource: "promo", withExtension: "mp4") else { return }
    let player = AVPlayer(url: videoURL)
    
    // VideoMaterial 생성
    let videoMaterial = VideoMaterial(avPlayer: player)
    
    // 비디오 평면 생성
    let videoPlane = ModelEntity(
        mesh: .generatePlane(
            width: Float(imageSize.width),
            depth: Float(imageSize.height)
        ),
        materials: [videoMaterial]
    )
    videoPlane.transform.rotation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
    videoPlane.position.y = 0.001 // 이미지 바로 위
    
    let anchorEntity = AnchorEntity(anchor: imageAnchor)
    anchorEntity.addChild(videoPlane)
    arView.scene.addAnchor(anchorEntity)
    
    // 비디오 재생
    player.play()
    
    // 루프 재생 설정
    NotificationCenter.default.addObserver(
        forName: .AVPlayerItemDidPlayToEndTime,
        object: player.currentItem,
        queue: .main
    ) { _ in
        player.seek(to: .zero)
        player.play()
    }
}
