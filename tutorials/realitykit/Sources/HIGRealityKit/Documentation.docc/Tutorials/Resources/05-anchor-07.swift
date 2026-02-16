import RealityKit

// 이미지 앵커
// ===========

func imageAnchor(_ arView: ARView) {
    // Assets에 AR Resource Group 추가 필요
    // 이미지 이름은 AR Resource Group에서 설정
    
    // 단일 이미지 인식
    let imageAnchor = AnchorEntity(.image(
        group: "AR Resources",     // Asset의 그룹 이름
        name: "poster_image"       // 이미지 이름
    ))
    
    // 인식된 이미지 위에 콘텐츠 배치
    let infoBox = ModelEntity(
        mesh: .generateBox(size: 0.1),
        materials: [SimpleMaterial(color: .blue, isMetallic: true)]
    )
    // 이미지 위 5cm 위에 배치
    infoBox.position.y = 0.05
    
    imageAnchor.addChild(infoBox)
    arView.scene.addAnchor(imageAnchor)
}
