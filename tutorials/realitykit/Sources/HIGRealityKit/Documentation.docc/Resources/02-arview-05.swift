import RealityKit
import ARKit

// MARK: - 평면 감지 설정

func setupPlaneDetection(for arView: ARView) {
    
    let config = ARWorldTrackingConfiguration()
    
    // 수평면만 감지
    config.planeDetection = .horizontal
    
    // 수직면만 감지
    // config.planeDetection = .vertical
    
    // 수평면 + 수직면 모두 감지
    // config.planeDetection = [.horizontal, .vertical]
    
    // 평면 감지 비활성화
    // config.planeDetection = []
    
    arView.session.run(config)
}

// MARK: - 평면 앵커 사용

func addContentOnPlane(to arView: ARView) {
    
    // 감지된 수평면에 자동 고정되는 앵커
    let horizontalAnchor = AnchorEntity(plane: .horizontal)
    
    // 감지된 수직면에 고정
    let verticalAnchor = AnchorEntity(plane: .vertical)
    
    // 특정 높이의 수평면
    let tableAnchor = AnchorEntity(
        plane: .horizontal,
        minimumBounds: [0.3, 0.3]  // 최소 30cm x 30cm
    )
    
    // 박스 추가
    let box = ModelEntity(
        mesh: .generateBox(size: 0.1),
        materials: [SimpleMaterial(color: .green, isMetallic: false)]
    )
    horizontalAnchor.addChild(box)
    
    arView.scene.addAnchor(horizontalAnchor)
}
