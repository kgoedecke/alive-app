// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Alive",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Alive", targets: ["Alive"]),
        .library(name: "AliveCore", targets: ["AliveCore"])
    ],
    targets: [
        .target(
            name: "AliveCore",
            path: "Sources/AliveCore"
        ),
        .executableTarget(
            name: "Alive",
            dependencies: ["AliveCore"],
            path: "Sources/Alive",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("IOKit"),
                .linkedFramework("ServiceManagement")
            ]
        ),
        .testTarget(
            name: "AliveCoreTests",
            dependencies: ["AliveCore"],
            path: "Tests/AliveCoreTests"
        )
    ]
)
