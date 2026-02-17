import ARKit
import RealityKit

// BodyTrackedEntity 로딩 (USDZ 캐릭터)
func loadBodyTrackedCharacter() async throws -> BodyTrackedEntity {
    // 캐릭터 USDZ는 ARKit 바디 스켈레톤과 호환되어야 함
    let character = try await BodyTrackedEntity.loadCharacter(named: "robot_character")
    
    print("캐릭터 로드됨: \(character.name)")
    
    // 스케일 조정 (선택적)
    character.scale = [1.0, 1.0, 1.0]
    
    return character
}

// 또는 동기 로딩 (iOS 14 이하 호환)
func loadCharacterSync() -> BodyTrackedEntity? {
    do {
        let character = try BodyTrackedEntity.loadCharacter(named: "robot")
        return character
    } catch {
        print("캐릭터 로딩 실패: \(error)")
        return nil
    }
}
