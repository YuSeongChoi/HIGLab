import ARKit
import RealityKit

class FaceTrackingDelegate: NSObject, ARSessionDelegate {
    var arView: ARView!
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let faceAnchor = anchor as? ARFaceAnchor else { continue }
            
            // 얼굴 메시 지오메트리 정보
            let faceGeometry = faceAnchor.geometry
            print("정점 수: \(faceGeometry.vertices.count)")
            print("삼각형 수: \(faceGeometry.triangleCount)")
            
            // RealityKit에서 얼굴 앵커 사용
            let faceAnchorEntity = AnchorEntity(anchor: faceAnchor)
            
            // 얼굴 위에 간단한 마커 배치
            let noseTip = ModelEntity(
                mesh: .generateSphere(radius: 0.01),
                materials: [SimpleMaterial(color: .red, isMetallic: false)]
            )
            
            faceAnchorEntity.addChild(noseTip)
            arView.scene.addAnchor(faceAnchorEntity)
        }
    }
}
