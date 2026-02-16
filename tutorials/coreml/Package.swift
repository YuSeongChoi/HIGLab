// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HIGCoreML",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "HIGCoreML",
            targets: ["HIGCoreML"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin",
            from: "1.4.3"
        ),
    ],
    targets: [
        .target(name: "HIGCoreML"),
    ]
)
