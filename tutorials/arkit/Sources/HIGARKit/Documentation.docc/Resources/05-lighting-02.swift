import ARKit
import RealityKit

// DirectionalLight 설정
let directionalLight = DirectionalLight()
directionalLight.light.color = .white
directionalLight.light.intensity = 1000
directionalLight.shadow = DirectionalLightComponent.Shadow(
    maximumDistance: 5,
    depthBias: 0.5
)
directionalLight.look(at: [0, 0, 0], from: [2, 4, 2], relativeTo: nil)

// PointLight 설정
let pointLight = PointLight()
pointLight.light.color = .yellow
pointLight.light.intensity = 5000
pointLight.light.attenuationRadius = 2.0
pointLight.position = [0, 1, 0]

// 앵커에 조명 추가
let anchor = AnchorEntity(plane: .horizontal)
anchor.addChild(directionalLight)
anchor.addChild(pointLight)
arView.scene.addAnchor(anchor)
