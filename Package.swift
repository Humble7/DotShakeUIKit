// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DotShakeUIKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DotShakeUIKit",
            targets: ["DotShakeUIKit"]),
        
        .library(
            name: "DotShakeKnob",
            targets: ["DotShakeKnob"]),
        
        .library(
            name: "DotShakeToolbar",
            targets: ["DotShakeToolbar"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Humble7/FoundationKit", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "DotShakeUIKit",
            dependencies: [
                "DotShakeKnob",
                "DotShakeToolbar",
                .product(
                    name: "FoundationKit",
                    package: "FoundationKit"
                )
            ]
        ),
        
        .target(
            name: "DotShakeKnob",
        ),
        
        .target(
            name: "DotShakeToolbar",
        ),
    
        .testTarget(
            name: "DotShakeUIKitTests",
            dependencies: ["DotShakeUIKit"]
        ),
    ]
)
