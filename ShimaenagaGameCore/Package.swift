// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShimaenagaGameCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ShimaenagaGameCore",
            targets: ["ShimaenagaGameCore"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ShimaenagaGameCore",
            dependencies: []
        ),
        .testTarget(
            name: "ShimaenagaGameCoreTests",
            dependencies: ["ShimaenagaGameCore"]
        ),
    ]
)