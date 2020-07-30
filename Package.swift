// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppboosterSDK",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "AppboosterSDK",
            targets: ["AppboosterSDK"]
        ),
    ],
    targets: [
        .target(
            name: "AppboosterSDK",
            path: "AppboosterSDK"
        ),
    ]
)
