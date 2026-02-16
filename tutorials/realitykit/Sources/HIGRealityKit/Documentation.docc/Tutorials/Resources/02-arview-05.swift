import RealityKit
import ARKit

func configurePlaneDetection(_ arView: ARView) {
    let config = ARWorldTrackingConfiguration()
    
    // 평면 감지 설정
    
    // 수평면만 감지 (바닥, 테이블)
    config.planeDetection = [.horizontal]
    
    // 수직면만 감지 (벽)
    // config.planeDetection = [.vertical]
    
    // 수평면과 수직면 모두 감지
    // config.planeDetection = [.horizontal, .vertical]
    
    // 평면 감지 비활성화
    // config.planeDetection = []
    
    arView.session.run(config)
}
