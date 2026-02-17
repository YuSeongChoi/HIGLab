import ARKit
import RealityKit

class ImageTrackingDelegate: NSObject, ARSessionDelegate {
    var arView: ARView!
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let imageAnchor = anchor as? ARImageAnchor else { continue }
            
            let imageName = imageAnchor.referenceImage.name ?? "unknown"
            print("이미지 감지됨: \(imageName)")
            
            // 이미지 위에 3D 모델 배치
            let anchorEntity = AnchorEntity(anchor: imageAnchor)
            
            let model = ModelEntity(
                mesh: .generateBox(size: 0.1),
                materials: [SimpleMaterial(color: .blue, isMetallic: true)]
            )
            model.position.y = 0.05 // 이미지 위로 살짝 띄우기
            
            anchorEntity.addChild(model)
            arView.scene.addAnchor(anchorEntity)
        }
    }
}
