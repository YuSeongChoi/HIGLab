import RealityKit

// Entity Transform 제어
// =====================

let entity = Entity()

// 위치 (미터 단위)
entity.position = SIMD3<Float>(0.5, 0, -1)  // x, y, z
// 또는
entity.transform.translation = [0.5, 0, -1]

// 회전 (쿼터니언)
entity.orientation = simd_quatf(
    angle: .pi / 4,                    // 45도
    axis: SIMD3<Float>(0, 1, 0)        // Y축 기준
)

// 크기 (배율)
entity.scale = SIMD3<Float>(2, 2, 2)   // 2배 확대
// 균일한 스케일
entity.scale = .one * 0.5              // 절반 크기

// Transform 직접 설정
entity.transform = Transform(
    scale: [1, 1, 1],
    rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
    translation: [0, 0.5, 0]
)
