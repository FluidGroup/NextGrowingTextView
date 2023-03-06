// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "NextGrowingTextView",
  platforms: [
    .iOS(.v14),
    .macOS(.v11)
  ],
  products: [
    .library(name: "NextGrowingTextView", targets: ["NextGrowingTextView"])
  ],
  targets: [
    .target(
      name: "NextGrowingTextView",
      path: "NextGrowingTextView"
    )
  ]
)
