// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-darwin",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(
            name: "Darwin Primitives",
            targets: ["Darwin Primitives"]
        ),
        .library(
            name: "Darwin Kernel",
            targets: ["Darwin Kernel"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/swift-kernel-primitives.git", from: "0.1.0"),
        .package(url: "https://github.com/coenttb/swift-posix.git", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-standards.git", from: "0.29.0")
    ],
    targets: [
        .target(
            name: "Darwin Primitives",
            dependencies: []
        ),
        .target(
            name: "CDarwinKernelShim",
            dependencies: []
        ),
        .target(
            name: "Darwin Kernel",
            dependencies: [
                .target(name: "Darwin Primitives"),
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
                .product(name: "POSIX Kernel", package: "swift-posix"),
                .target(name: "CDarwinKernelShim"),
            ]
        ),
        .testTarget(
            name: "Darwin Kernel Tests",
            dependencies: [
                "Darwin Kernel",
                .product(name: "Kernel Primitives Test Support", package: "swift-kernel-primitives"),
                .product(name: "StandardsTestSupport", package: "swift-standards")
            ],
            path: "Tests/Darwin Kernel Tests"
        ),
    ]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
