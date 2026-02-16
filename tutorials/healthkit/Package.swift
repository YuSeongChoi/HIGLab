// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HIGHealthKit",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10)],
    products: [
        .library(
            name: "HIGHealthKit",
            targets: ["HIGHealthKit"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin",
            from: "1.4.3"
        ),
    ],
    targets: [
        .target(name: "HIGHealthKit"),
    ]
)
