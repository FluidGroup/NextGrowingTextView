// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "NextGrowingTextView",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
  ],
  products: [
    .library(name: "NextGrowingTextView", targets: ["NextGrowingTextView"]),
    .library(name: "NextGrowingTextViewSwiftUI", targets: ["NextGrowingTextViewSwiftUI"]),
  ],
  targets: [
    .target(
      name: "NextGrowingTextView",
      path: "NextGrowingTextView"
    ),
    .target(
      name: "NextGrowingTextViewSwiftUI",
      path: "NextGrowingTextViewSwiftUI"
    ),
  ],
  swiftLanguageModes: [.v6]
)
