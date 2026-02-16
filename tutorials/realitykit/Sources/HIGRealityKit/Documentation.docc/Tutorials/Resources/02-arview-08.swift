import RealityKit

func configureDebugOptions(_ arView: ARView) {
    // 디버그 옵션 설정
    arView.debugOptions = [
        // 물리 디버그 (충돌 모양 표시)
        .showPhysics,
        
        // 앵커 원점 표시
        .showAnchorOrigins,
        
        // 앵커 지오메트리 표시
        .showAnchorGeometry,
        
        // 월드 원점 표시
        .showWorldOrigin,
        
        // 피쳐 포인트 표시
        .showFeaturePoints
    ]
    
    // 모든 디버그 옵션 끄기
    // arView.debugOptions = []
}
