// swift-tools-version:5.9
//
// UNSTUCK iOS — pure-Swift boundary as a Swift Package.
//
// The full SwiftUI app target requires Xcode + the iOS SDK. The pieces that can
// be type-checked and tested without Xcode (Configuration, Networking protocols,
// the Ranca analysis boundary, and their tests) live in this package so
// `swift test` validates the boundary wherever Swift is installed.
//
// The SwiftUI app shell (`UnstuckApp.swift`, `ContentView.swift`) is excluded
// from the package; it is added to an Xcode app target directly. Both the app
// target and this package reference the same boundary files.
import PackageDescription

let package = Package(
    name: "Unstuck",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "UnstuckBoundary", targets: ["UnstuckBoundary"]),
    ],
    targets: [
        .target(
            name: "UnstuckBoundary",
            path: "Unstuck",
            // The SwiftUI app shell + all SwiftUI View files live in the Xcode app
            // target only. The package target stays Foundation/Combine-only so the
            // boundary (contracts, networking, analysis, flow logic) is type-checked
            // and unit-tested wherever Swift is installed — no iOS SDK required.
            exclude: [
                "UnstuckApp.swift",
                "ContentView.swift",
                "Design",
                "Result",
                "Flow/UnstuckScreen.swift",
                "Flow/LaunchScreen.swift",
                "Flow/WhatsGoingOnScreen.swift",
                "Flow/SelectSituationScreen.swift",
                "Flow/TellScreen.swift",
                "Flow/ResultScreen.swift",
                "Flow/FlowContainerView.swift",
                "Flow/SituationPicker.swift",
            ]
        ),
        .testTarget(
            name: "UnstuckBoundaryTests",
            dependencies: ["UnstuckBoundary"],
            path: "UnstuckTests"
        ),
    ]
)
