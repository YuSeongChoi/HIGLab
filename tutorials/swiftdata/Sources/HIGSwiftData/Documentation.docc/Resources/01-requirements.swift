import Foundation

// SwiftData 시스템 요구사항

/*
 ┌─────────────────────────────────────────────────────────┐
 │                  SwiftData Requirements                  │
 ├─────────────────────────────────────────────────────────┤
 │  Platform       │  Minimum Version                      │
 ├─────────────────────────────────────────────────────────┤
 │  iOS            │  17.0+                                │
 │  iPadOS         │  17.0+                                │
 │  macOS          │  14.0+ (Sonoma)                       │
 │  watchOS        │  10.0+                                │
 │  tvOS           │  17.0+                                │
 │  visionOS       │  1.0+                                 │
 ├─────────────────────────────────────────────────────────┤
 │  Xcode          │  15.0+                                │
 │  Swift          │  5.9+                                 │
 └─────────────────────────────────────────────────────────┘
*/

// Package.swift 예시
/*
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TaskMaster",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "TaskMaster"
        )
    ]
)
*/

// ⚠️ 이전 버전 지원이 필요하다면?
// - iOS 16 이하: Core Data 사용
// - 하이브리드 접근: @available로 분기
/*
if #available(iOS 17, *) {
    // SwiftData 사용
} else {
    // Core Data 폴백
}
*/
