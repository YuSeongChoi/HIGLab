import ARKit
import RealityKit

class ObjectDetectionDelegate: NSObject, ARSessionDelegate {
    var arView: ARView!
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let objectAnchor = anchor as? ARObjectAnchor else { continue }
            
            let objectName = objectAnchor.referenceObject.name ?? "unknown"
            print("객체 감지됨: \(objectName)")
            
            // 감지된 객체의 위치와 크기
            let transform = objectAnchor.transform
            let extent = objectAnchor.referenceObject.extent
            print("크기: \(extent.x)m x \(extent.y)m x \(extent.z)m")
            
            // 객체 주변에 바운딩 박스 표시
            let boundingBox = ModelEntity(
                mesh: .generateBox(size: extent, cornerRadius: 0.01),
                materials: [SimpleMaterial(color: .green.withAlphaComponent(0.3), isMetallic: false)]
            )
            
            // 텍스트 레이블 추가
            let textMesh = MeshResource.generateText(
                objectName,
                extrusionDepth: 0.01,
                font: .systemFont(ofSize: 0.05)
            )
            let textEntity = ModelEntity(mesh: textMesh)
            textEntity.position.y = extent.y / 2 + 0.05
            
            let anchorEntity = AnchorEntity(anchor: objectAnchor)
            anchorEntity.addChild(boundingBox)
            anchorEntity.addChild(textEntity)
            arView.scene.addAnchor(anchorEntity)
        }
    }
}
