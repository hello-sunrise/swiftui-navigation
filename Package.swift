// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftNav",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftNav",
            targets: ["SwiftNav"]),
    ],
    dependencies: [
        .package(url: "https://github.com/dfed/swift-async-queue", from: "0.5.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftNav",
            dependencies: [.product(name: "AsyncQueue", package: "swift-async-queue")],
            path: "Sources"
        )
    ]
)
