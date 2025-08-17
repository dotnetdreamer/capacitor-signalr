// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorSignalr",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorSignalr",
            targets: ["CapacitorSignalRPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0"),
        .package(url: "https://github.com/moozzyk/SignalR-Client-Swift", from: "1.1.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2")
    ],
    targets: [
        .target(
            name: "CapacitorSignalRPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "SignalRClient", package: "SignalR-Client-Swift"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON")
            ],
            path: "ios/Sources/CapacitorSignalRPlugin"),
        .testTarget(
            name: "CapacitorSignalRPluginTests",
            dependencies: ["CapacitorSignalRPlugin"],
            path: "ios/Tests/CapacitorSignalRPluginTests")
    ]
)