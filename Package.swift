// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Package version: 1.5.10

import PackageDescription

let package = Package(
    name: "AINetworkCalls",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "AINetworkCalls",
            targets: ["AINetworkCalls"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(url: "https://github.com/relatedcode/ProgressHUD.git", from: "13.0.0"),
        .package(url: "https://github.com/google/promises.git", from: "2.3.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "AINetworkCalls",
            dependencies: ["Alamofire",
                           "SwiftyJSON",
                           .product(name: "ProgressHUD", package: "ProgressHUD"),
                           .product(name: "Promises", package: "promises")]
        ),
        .testTarget(
            name: "AINetworkCallsTests",
            dependencies: ["AINetworkCalls"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
