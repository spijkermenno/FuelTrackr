// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [
        .iOS("17.6")
    ],
    products: [
        .library(
            name: "Data",
            targets: ["Data"]
        ),
    ],
    dependencies: [
        .package(path: "../Domain"),
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
            ]
        )
    ]
)
