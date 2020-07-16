// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "qamani",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        Package.Dependency.package(url: "https://github.com/dowobeha/Foma.git", from: "0.3.1"),
        Package.Dependency.package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.2.0"),
        Package.Dependency.package(url: "https://github.com/hectr/swift-stream-reader.git", from: "0.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        Target.target(
            name: "qamani",
            dependencies: ["Foma", "ArgumentParser", "StreamReader"]),
        Target.testTarget(
            name: "qamaniTests",
            dependencies: ["qamani"]),
    ]
)
