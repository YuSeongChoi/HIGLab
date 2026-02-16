import RealityKit

// 여러 이미지 트래킹
// ==================

func multipleImageAnchors(_ arView: ARView) {
    // 이미지 목록
    let imageNames = ["card_a", "card_b", "card_c"]
    
    for imageName in imageNames {
        let anchor = AnchorEntity(.image(
            group: "AR Resources",
            name: imageName
        ))
        
        // 각 이미지에 다른 콘텐츠
        let label = createLabel(for: imageName)
        anchor.addChild(label)
        
        arView.scene.addAnchor(anchor)
    }
}

func createLabel(for name: String) -> ModelEntity {
    // 간단한 색상 박스로 구분
    let color: UIColor = switch name {
        case "card_a": .red
        case "card_b": .green
        default: .blue
    }
    
    return ModelEntity(
        mesh: .generatePlane(width: 0.05, depth: 0.05),
        materials: [SimpleMaterial(color: color, isMetallic: false)]
    )
}
