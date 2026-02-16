import RealityKit

// RealityKit 지원 플랫폼
// ======================

// iOS 13.0+ : iPhone, iPad AR 앱
// iPadOS 13.0+ : iPad AR 앱
// macOS 10.15+ : Mac 3D 앱
// visionOS 1.0+ : Apple Vision Pro 공간 컴퓨팅 앱

// 플랫폼별 조건부 컴파일
#if os(iOS)
// iOS 전용 코드
import ARKit
#elseif os(visionOS)
// visionOS 전용 코드
#elseif os(macOS)
// macOS 전용 코드
#endif
