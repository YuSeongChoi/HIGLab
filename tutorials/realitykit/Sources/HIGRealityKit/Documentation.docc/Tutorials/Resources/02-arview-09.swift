import RealityKit

func configureStatistics(_ arView: ARView) {
    // 통계 정보 표시
    arView.debugOptions.insert(.showStatistics)
    
    // 표시되는 정보:
    // - FPS (초당 프레임)
    // - CPU 사용량
    // - GPU 사용량
    // - 메모리 사용량
    // - 트라이앵글 수
    // - 드로우 콜 수
    
    // 개발 중에만 사용하고, 릴리즈 빌드에서는 비활성화
    #if DEBUG
    arView.debugOptions.insert(.showStatistics)
    #endif
}
