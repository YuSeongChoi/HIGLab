// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "HIGImagePlayground",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "HIGImagePlayground", targets: ["HIGImagePlayground"])],
    dependencies: [.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")],
    targets: [.target(name: "HIGImagePlayground")]
)
