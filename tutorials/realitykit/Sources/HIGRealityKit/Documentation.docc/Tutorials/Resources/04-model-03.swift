import RealityKit

// 로드된 모델 조정
// ================

func adjustModel(_ entity: Entity) {
    // 크기 조절 (USDZ는 실제 크기로 저장되어 있을 수 있음)
    entity.scale = SIMD3<Float>(0.01, 0.01, 0.01)  // 100배 축소
    
    // 균일한 스케일
    entity.scale = .one * 0.5  // 절반 크기
    
    // 위치 조정
    entity.position = SIMD3<Float>(0, 0, 0)  // 원점에 배치
    
    // Y축 회전
    entity.orientation = simd_quatf(
        angle: .pi / 2,  // 90도
        axis: SIMD3<Float>(0, 1, 0)
    )
    
    // 바닥에 맞추기 (피벗이 중앙에 있을 경우)
    if let modelEntity = entity as? ModelEntity,
       let bounds = modelEntity.model?.mesh.bounds {
        entity.position.y = -bounds.min.y * entity.scale.y
    }
}
