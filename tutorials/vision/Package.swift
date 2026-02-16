// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HIGVision",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "HIGVision",
            targets: ["HIGVision"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin",
            from: "1.4.3"
        ),
    ],
    targets: [
        .target(name: "HIGVision"),
    ]
)
