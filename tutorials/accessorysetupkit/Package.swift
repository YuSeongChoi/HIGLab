// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "HIGAccessorySetupKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "HIGAccessorySetupKit", targets: ["HIGAccessorySetupKit"])],
    dependencies: [.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")],
    targets: [.target(name: "HIGAccessorySetupKit")]
)
