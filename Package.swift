// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "NextGrowingTextView",    
    platforms: [
      .iOS(.v10)
    ],
    products: [        
        .library(name: "NextGrowingTextView", targets: ["NextGrowingTextView"]),
    ],
    targets: [     
        .target(name: "NextGrowingTextView", path: "NextGrowingTextView", exclude: ["NextGrowingTextView/Info.plist"]),
    ]
)