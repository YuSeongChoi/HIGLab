import RealityKit
import ARKit  // AR 기능 사용 시
import Combine  // 반응형 프로그래밍

// MARK: - RealityKit 프로젝트 설정

/*
 1. Xcode에서 새 프로젝트 생성
 2. "Augmented Reality App" 템플릿 선택
 3. Content Technology: "RealityKit" 선택
 4. Interface: "SwiftUI" 또는 "UIKit" 선택
 */

// 필수 Capabilities (Signing & Capabilities):
// - Camera Usage Description (Info.plist)
// - AR Kit (Augmented Reality App인 경우)

/*
 Info.plist 설정:
 
 <key>NSCameraUsageDescription</key>
 <string>AR 경험을 위해 카메라 접근이 필요합니다.</string>
 
 <key>UIRequiredDeviceCapabilities</key>
 <array>
     <string>arkit</string>
 </array>
 */

// Reality Composer Pro (visionOS / macOS 전용):
// - .reality 파일 편집
// - 3D 씬 구성
// - 애니메이션 및 오디오 추가
