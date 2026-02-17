import RealityKit
import ARKit

// MARK: - 환경 텍스처링

func setupEnvironmentTexturing(for arView: ARView) {
    
    let config = ARWorldTrackingConfiguration()
    
    // 환경 텍스처링 옵션
    // .none      - 비활성화
    // .manual    - 수동 (AREnvironmentProbeAnchor 사용)
    // .automatic - 자동 (권장)
    
    config.environmentTexturing = .automatic
    
    arView.session.run(config)
}

// MARK: - 환경 텍스처링 효과

/*
 환경 텍스처링이 활성화되면:
 
 1. 주변 환경이 실시간으로 캡처됨
 2. 금속성 객체에 환경이 반사됨
 3. PBR 재질이 더 현실감 있게 렌더링됨
 */

func createReflectiveObject() -> ModelEntity {
    // 반사가 잘 보이는 금속 재질
    var material = SimpleMaterial()
    material.color = .init(tint: .white, texture: nil)
    material.metallic = .init(floatLiteral: 1.0)  // 완전 금속
    material.roughness = .init(floatLiteral: 0.0) // 매끄러움
    
    let sphere = ModelEntity(
        mesh: .generateSphere(radius: 0.1),
        materials: [material]
    )
    
    return sphere
}
