import ARKit
import RealityKit

func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    for anchor in anchors {
        guard let imageAnchor = anchor as? ARImageAnchor else { continue }
        
        // 참조 이미지의 실제 크기 (미터 단위)
        let imageSize = imageAnchor.referenceImage.physicalSize
        print("이미지 크기: \(imageSize.width)m x \(imageSize.height)m")
        
        // 이미지 크기에 맞춘 평면 오버레이
        let overlayPlane = ModelEntity(
            mesh: .generatePlane(
                width: Float(imageSize.width),
                depth: Float(imageSize.height)
            ),
            materials: [SimpleMaterial(color: .green.withAlphaComponent(0.5), isMetallic: false)]
        )
        overlayPlane.transform.rotation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
        
        let anchorEntity = AnchorEntity(anchor: imageAnchor)
        anchorEntity.addChild(overlayPlane)
        arView.scene.addAnchor(anchorEntity)
    }
}
