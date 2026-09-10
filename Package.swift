// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JobsMonitor",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "JobsMonitorModels",
            targets: ["JobsMonitorModels"]
        ),
        .library(
            name: "JobsMonitorScrapers",
            targets: ["JobsMonitorScrapers"]
        ),
        .library(
            name: "JobsMonitorUI",
            targets: ["JobsMonitorUI"]
        ),
        .library(
            name: "JobsMonitorUtils",
            targets: ["JobsMonitorUtils"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "JobsMonitorModels",
            dependencies: [],
            path: "JobsMonitorModels"
        ),
        .target(
            name: "JobsMonitorScrapers",
            dependencies: ["JobsMonitorModels"],
            path: "JobsMonitorScrapers"
        ),
        .target(
            name: "JobsMonitorUI",
            dependencies: ["JobsMonitorModels", "JobsMonitorScrapers"],
            path: "JobsMonitorUI"
        ),
        .target(
            name: "JobsMonitorUtils",
            dependencies: [],
            path: "JobsMonitorUtils"
        ),
        .executableTarget(
            name: "JobsMonitorApp",
            dependencies: ["JobsMonitorUI"],
            path: "JobsMonitor",
            exclude: ["Info.plist", "JobsMonitor-Bridging-Header.h"]
        ),
        .testTarget(
            name: "JobsMonitorTests",
            dependencies: [
                "JobsMonitorModels",
                "JobsMonitorScrapers",
                "JobsMonitorUI"
            ],
            path: "JobsMonitorTests"
        )
    ]
)
