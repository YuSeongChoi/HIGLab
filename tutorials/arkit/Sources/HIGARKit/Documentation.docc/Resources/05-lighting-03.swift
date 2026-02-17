import ARKit
import RealityKit

// 그림자를 받을 평면 생성
let shadowPlane = ModelEntity(
    mesh: .generatePlane(width: 5, depth: 5),
    materials: [OcclusionMaterial()] // 보이지 않지만 그림자는 받음
)
shadowPlane.generateCollisionShapes(recursive: false)

// 또는 SimpleMaterial로 그림자가 보이는 평면
let visiblePlane = ModelEntity(
    mesh: .generatePlane(width: 5, depth: 5),
    materials: [SimpleMaterial(color: .white.withAlphaComponent(0.3), isMetallic: false)]
)

// 그림자 캐스팅 설정
let furnitureModel = try! ModelEntity.loadModel(named: "chair")
furnitureModel.components.set(GroundingShadowComponent(castsShadow: true))

let anchor = AnchorEntity(plane: .horizontal)
anchor.addChild(shadowPlane)
anchor.addChild(furnitureModel)
arView.scene.addAnchor(anchor)
