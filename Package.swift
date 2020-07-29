// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "qamani",
    products: [
        Product.executable(
            name: "itemquulteki",
            targets: ["itemquulteki"]),
        Product.executable(
            name: "peghqiilta",
            targets: ["peghqiilta"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        Package.Dependency.package(
            name: "Foma",
            url: "https://github.com/dowobeha/Foma.git",
            from: "0.3.1"),
        Package.Dependency.package(
            name: "swift-argument-parser",
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "0.2.0"),
        Package.Dependency.package(
            name: "StreamReader",
            url: "https://github.com/hectr/swift-stream-reader.git",
            from: "0.3.0"),
        Package.Dependency.package(
            name: "Threading",
            url: "https://github.com/Miraion/Threading.git",
            from: "1.0.0"),
        Package.Dependency.package(
            name: "NgramLM",
            url: "https://github.com/dowobeha/NgramLM.git",
            from: "0.1.5"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        Target.target(
            name: "itemquulteki",
            dependencies: [
                Target.Dependency.target(
                    name: "Qamani"),
                Target.Dependency.product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"),
        ]),
        Target.target(
            name: "Nasuqun",
            dependencies: [
                Target.Dependency.target(
                    name: "Qamani"),
                Target.Dependency.product(
                    name: "Foma",
                    package: "Foma"),
                Target.Dependency.product(
                    name: "StreamReader",
                    package: "StreamReader"),
                Target.Dependency.product(
                    name: "Threading",
                    package: "Threading"),
                Target.Dependency.product(
                    name: "NgramLM",
                    package: "NgramLM")
        ]),
        Target.target(
            name: "peghqiilta",
            dependencies: [
                Target.Dependency.target(
                    name: "Nasuqun"),
                Target.Dependency.target(
                    name: "Qamani"),
                Target.Dependency.product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"),
        ]),
        Target.target(
            name: "Qamani",
            dependencies: [
                Target.Dependency.product(
                    name: "Foma",
                    package: "Foma"),
                Target.Dependency.product(
                    name: "StreamReader",
                    package: "StreamReader"),
                Target.Dependency.product(
                    name: "Threading",
                    package: "Threading")
            ]),
        Target.testTarget(
            name: "qamaniTests",
            dependencies: [
                Target.Dependency.target(name: "Qamani")
            ]),
    ]
)
