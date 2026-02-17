import ARKit
import RealityKit

class BodyTrackedCharacterController {
    var arView: ARView!
    var character: BodyTrackedEntity?
    var characterAnchor: AnchorEntity?
    
    func setupCharacter() async {
        // 캐릭터 로드
        guard let loadedCharacter = try? await BodyTrackedEntity.loadCharacter(named: "robot") else {
            print("캐릭터 로드 실패")
            return
        }
        
        character = loadedCharacter
        
        // 바디 앵커에 연결
        let bodyAnchor = AnchorEntity(.body)
        bodyAnchor.addChild(loadedCharacter)
        
        characterAnchor = bodyAnchor
        arView.scene.addAnchor(bodyAnchor)
        
        print("캐릭터가 바디 트래킹에 연결됨")
    }
    
    // 캐릭터가 자동으로 바디 포즈를 따라감
    // ARKit이 ARBodyAnchor를 업데이트하면 BodyTrackedEntity가 자동 동기화됨
}
