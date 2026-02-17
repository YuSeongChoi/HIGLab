import ARKit
import RealityKit

class CharacterAnimator {
    var characterEntity: Entity!
    
    // BlendShapes를 캐릭터 애니메이션에 적용
    func updateCharacter(with faceAnchor: ARFaceAnchor) {
        let blendShapes = faceAnchor.blendShapes
        
        // 눈 애니메이션
        if let leftEye = characterEntity.findEntity(named: "left_eye"),
           let rightEye = characterEntity.findEntity(named: "right_eye") {
            
            let leftBlink = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            let rightBlink = blendShapes[.eyeBlinkRight]?.floatValue ?? 0
            
            leftEye.scale.y = 1.0 - (leftBlink * 0.9)
            rightEye.scale.y = 1.0 - (rightBlink * 0.9)
        }
        
        // 입 애니메이션
        if let mouth = characterEntity.findEntity(named: "mouth") {
            let jawOpen = blendShapes[.jawOpen]?.floatValue ?? 0
            mouth.scale.y = 1.0 + jawOpen
        }
        
        // 눈썹 애니메이션
        if let leftBrow = characterEntity.findEntity(named: "left_brow"),
           let rightBrow = characterEntity.findEntity(named: "right_brow") {
            
            let browUp = blendShapes[.browInnerUp]?.floatValue ?? 0
            let browDownL = blendShapes[.browDownLeft]?.floatValue ?? 0
            let browDownR = blendShapes[.browDownRight]?.floatValue ?? 0
            
            leftBrow.position.y = 0.1 + (browUp * 0.05) - (browDownL * 0.03)
            rightBrow.position.y = 0.1 + (browUp * 0.05) - (browDownR * 0.03)
        }
    }
}
