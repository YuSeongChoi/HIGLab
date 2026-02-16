import RealityKit
import ARKit

// 평면 분류 (Classification)
// ==========================

// 사용 가능한 분류:
// .wall         - 벽
// .floor        - 바닥
// .ceiling      - 천장
// .table        - 테이블
// .seat         - 의자/소파
// .window       - 창문
// .door         - 문

func classifiedAnchors(_ arView: ARView) {
    // 테이블 위에만 앵커링
    let tableAnchor = AnchorEntity(
        plane: .horizontal,
        classification: .table
    )
    
    // 의자에만 앵커링
    let seatAnchor = AnchorEntity(
        plane: .horizontal,
        classification: .seat
    )
    
    // 문에 앵커링
    let doorAnchor = AnchorEntity(
        plane: .vertical,
        classification: .door
    )
    
    // 정확한 분류를 위해 LiDAR 센서가 필요할 수 있음
}
