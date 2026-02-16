// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HIGCoreImage",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "HIGCoreImage", targets: ["HIGCoreImage"]),
    ],
    targets: [
        .target(name: "HIGCoreImage"),
    ]
)
