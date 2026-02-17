import ARKit
import RealityKit
import SceneKit

// ARSCNView를 사용한 얼굴 메시 텍스처링
class FaceMaskRenderer: NSObject, ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
        
        // ARSCNFaceGeometry로 얼굴 메시 생성
        guard let device = renderer.device,
              let faceGeometry = ARSCNFaceGeometry(device: device) else { return nil }
        
        let node = SCNNode(geometry: faceGeometry)
        
        // 커스텀 텍스처 적용
        let material = node.geometry?.firstMaterial
        material?.diffuse.contents = UIImage(named: "face_mask_texture")
        material?.lightingModel = .physicallyBased
        
        // 또는 반투명 오버레이
        material?.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)
        material?.fillMode = .fill
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        
        // 얼굴 움직임에 따라 메시 업데이트
        faceGeometry.update(from: faceAnchor.geometry)
    }
}
