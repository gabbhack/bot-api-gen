// swift-tools-version:5.4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "bot-api-gen",
    dependencies: [
        // TODO move to main after https://github.com/stencilproject/Stencil/pull/287
        .package(name: "Stencil", url: "https://github.com/stencilproject/Stencil.git", .branch("trim_whitespace")),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
        .package(url: "https://github.com/qiuzhifei/swift-commands", from: "0.5.0"),

    ],
    targets: [
        .executableTarget(
            name: "bot-api-gen",
            dependencies: [
                "Stencil", 
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "Commands", package: "swift-commands"),
            ]),
    ]
)
