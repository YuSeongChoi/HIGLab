// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "HIGCoreImage",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "HIGCoreImage", targets: ["HIGCoreImage"])],
    dependencies: [.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")],
    targets: [.target(name: "HIGCoreImage")]
)
