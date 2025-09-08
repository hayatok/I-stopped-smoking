// swift-tools-version: 5.6
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "I-stopped-smoking",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "I-stopped-smoking",
            targets: ["App"],
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.cyan),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "App",
            path: "Sources"
        )
    ]
)
