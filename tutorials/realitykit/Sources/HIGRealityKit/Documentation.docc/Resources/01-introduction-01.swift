import RealityKit
import ARKit

// MARK: - RealityKit 개요
// RealityKit은 Apple의 AR/3D 프레임워크입니다.

/*
 주요 특징:
 
 1. 사진 같은 렌더링 (PBR - 물리 기반 렌더링)
    - 실시간 환경 반사
    - 동적 조명 및 그림자
    - HDR 지원
 
 2. 물리 시뮬레이션
    - 중력, 충돌 감지
    - 힘과 토크 적용
    - 조인트 시스템
 
 3. 애니메이션
    - 스켈레탈 애니메이션
    - 트랜스폼 애니메이션
    - 커스텀 애니메이션
 
 4. 공간 오디오
    - 3D 위치 기반 사운드
    - 거리에 따른 감쇠
    - 환경 반향
 */

/// RealityKit 지원 플랫폼
enum SupportedPlatforms {
    case iOS       // iOS 13.0+
    case macOS     // macOS 10.15+
    case visionOS  // visionOS 1.0+
}
