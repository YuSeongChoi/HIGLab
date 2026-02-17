import RealityKit
import ARKit

// MARK: - ARView 디버그 옵션

func setupDebugOptions(_ arView: ARView) {
    
    #if DEBUG
    // 여러 디버그 옵션 조합
    arView.debugOptions = [
        .showFeaturePoints,    // 특징점 표시
        .showWorldOrigin,      // 월드 원점 좌표축
        .showAnchorOrigins,    // 앵커 원점 표시
        .showAnchorGeometry,   // 앵커 기하학 (평면 등)
        .showPhysics,          // 물리 바디 표시
        .showStatistics        // 통계 정보
    ]
    #endif
}

// MARK: - 디버그 옵션 설명

/*
 .showFeaturePoints
 - AR 추적에 사용되는 특징점을 노란색 점으로 표시
 - 추적 품질 확인에 유용
 
 .showWorldOrigin
 - 월드 좌표계의 원점(0,0,0)을 RGB 축으로 표시
 - 빨강=X, 초록=Y, 파랑=Z
 
 .showAnchorOrigins
 - 각 앵커의 로컬 좌표계 표시
 
 .showAnchorGeometry
 - 감지된 평면을 반투명 면으로 표시
 
 .showPhysics
 - 충돌 바운딩 박스 표시
 
 .showStatistics
 - FPS, 삼각형 수, 메모리 등 표시
 */
