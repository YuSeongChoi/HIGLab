import RealityKit
import ARKit

// Raycast로 탭 위치에 앵커 배치
// =============================

func setupTapToPlace(_ arView: ARView) {
    let tapGesture = UITapGestureRecognizer(target: arView, action: nil)
    arView.addGestureRecognizer(tapGesture)
}

func handleTap(in arView: ARView, at point: CGPoint) {
    // Raycast로 평면 찾기
    let results = arView.raycast(
        from: point,
        allowing: .estimatedPlane,
        alignment: .horizontal
    )
    
    guard let firstResult = results.first else {
        print("평면을 찾을 수 없음")
        return
    }
    
    // 찾은 위치에 앵커 생성
    let anchor = AnchorEntity(raycastResult: firstResult)
    
    // 콘텐츠 추가
    let object = ModelEntity(
        mesh: .generateBox(size: 0.1),
        materials: [SimpleMaterial(color: .purple, isMetallic: true)]
    )
    anchor.addChild(object)
    
    arView.scene.addAnchor(anchor)
}
