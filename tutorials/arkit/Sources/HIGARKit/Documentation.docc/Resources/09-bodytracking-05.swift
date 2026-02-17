import ARKit
import RealityKit

class HandInteractionController: NSObject, ARSessionDelegate {
    var arView: ARView!
    var handSphere: ModelEntity?
    
    func setupHandMarker() {
        // 손 위치를 표시할 구체
        let sphere = ModelEntity(
            mesh: .generateSphere(radius: 0.05),
            materials: [SimpleMaterial(color: .cyan, isMetallic: true)]
        )
        handSphere = sphere
        
        let anchor = AnchorEntity(world: .zero)
        anchor.addChild(sphere)
        arView.scene.addAnchor(anchor)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            // 오른손 조인트 위치 추출
            guard let rightHandTransform = bodyAnchor.skeleton.modelTransform(for: .rightHand) else {
                continue
            }
            
            // 월드 좌표로 변환
            let worldTransform = bodyAnchor.transform * rightHandTransform
            let handPosition = SIMD3<Float>(
                worldTransform.columns.3.x,
                worldTransform.columns.3.y,
                worldTransform.columns.3.z
            )
            
            // 손 마커 위치 업데이트
            handSphere?.position = handPosition
            
            // 손 높이에 따른 상호작용
            if handPosition.y > 1.5 { // 손을 높이 들었을 때
                handSphere?.model?.materials = [SimpleMaterial(color: .green, isMetallic: true)]
                print("손 들기 감지!")
            } else {
                handSphere?.model?.materials = [SimpleMaterial(color: .cyan, isMetallic: true)]
            }
        }
    }
}
