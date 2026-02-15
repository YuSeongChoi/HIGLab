// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "HIGRealityKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "HIGRealityKit", targets: ["HIGRealityKit"])],
    dependencies: [.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")],
    targets: [.target(name: "HIGRealityKit")]
)
