// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "HIGBluetooth",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "HIGBluetooth", targets: ["HIGBluetooth"])],
    dependencies: [.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")],
    targets: [.target(name: "HIGBluetooth")]
)
