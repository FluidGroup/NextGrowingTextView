# NextGrowingTextView - An Essential UI component for input text

![](https://img.shields.io/badge/Swift-5.1-blue.svg?style=flat)
[![Version](https://img.shields.io/cocoapods/v/NextGrowingTextView.svg?style=flat)](http://cocoapods.org/pods/NextGrowingTextView)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/NextGrowingTextView.svg?style=flat)](http://cocoapods.org/pods/NextGrowingTextView)
[![Platform](https://img.shields.io/cocoapods/p/NextGrowingTextView.svg?style=flat)](http://cocoapods.org/pods/NextGrowingTextView)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmuukii%2FNextGrowingTextView.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmuukii%2FNextGrowingTextView?ref=badge_shield)

|flexible width | fixed width |
|---|---|
|<img width=200px src="https://user-images.githubusercontent.com/1888355/156420538-76b2d75b-ca50-46f0-b95f-056d2ef30953.gif" />|<img width=200px src="https://user-images.githubusercontent.com/1888355/156420669-f1a8003e-cd43-41c3-b482-7a5baf9d5561.gif" />|

> 💡  
**You want also to need to display a user-interface on top of the keyboard?**  
[muukii/Bureau](https://github.com/muukii/Bureau) enables you to show your user-interface on top of the keyboard in the easiest way.


## How to use

**Create an instance, then adding subview with layout**

It supports AutoLayout completely.

```swift
let growingTextView = NextGrowingTextView()
```

**Setting up with configuration**

```swift
growingTextView.configuration = .init(
  minLines: 1,
  maxLines: 10,
  isAutomaticScrollToBottomEnabled: true,
  isFlashScrollIndicatorsEnabled: true
)
```

**Accessing actual UITextView to apply settings in there**
```swift
growingTextView.textView
```

**Accessing UILabel for displaying placeholder**

```swift
growingTextView.placeholderLabel
```

## Requirements

iOS 9.0+ Swift 5.5+

## Installation

- Supports followings:
  - CocoaPods
  - Swift Package Manager

## Author

[muukii](https://github.com/muukii)

## License

NextGrowingTextView is available under the MIT license. See the LICENSE file for more info.

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmuukii%2FNextGrowingTextView.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmuukii%2FNextGrowingTextView?ref=badge_large)
