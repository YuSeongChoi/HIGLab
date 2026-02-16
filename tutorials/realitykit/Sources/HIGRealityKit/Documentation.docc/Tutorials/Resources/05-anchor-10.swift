import RealityKit

// 신체 앵커
// =========

func bodyAnchor(_ arView: ARView) {
    // 신체 트래킹 (A12 이상 칩 필요)
    // 후면 카메라 사용
    
    // 신체 앵커 생성
    let bodyAnchor = AnchorEntity(.body)
    
    // 신체에 부착할 콘텐츠
    // 예: 가상 의상, 갑옷 등
    
    arView.scene.addAnchor(bodyAnchor)
}

// 신체 조인트에 접근하려면 ARBodyTrackingConfiguration 사용
// 각 관절(joints)의 위치와 회전을 가져올 수 있음

// 지원되는 관절:
// - head, neck
// - leftShoulder, rightShoulder
// - leftElbow, rightElbow
// - leftWrist, rightWrist
// - spine, hips
// - leftKnee, rightKnee
// - leftAnkle, rightAnkle
