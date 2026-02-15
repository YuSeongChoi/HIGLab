// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "HIGSpriteKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "HIGSpriteKit", targets: ["HIGSpriteKit"])],
    dependencies: [.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")],
    targets: [.target(name: "HIGSpriteKit")]
)
