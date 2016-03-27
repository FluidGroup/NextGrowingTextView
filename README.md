# NextGrowingTextView

[![CI Status](http://img.shields.io/travis/muukii/NextGrowingTextView.svg?style=flat)](https://travis-ci.org/muukii/NextGrowingTextView)
[![Version](https://img.shields.io/cocoapods/v/NextGrowingTextView.svg?style=flat)](http://cocoapods.org/pods/NextGrowingTextView)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/NextGrowingTextView.svg?style=flat)](http://cocoapods.org/pods/NextGrowingTextView)
[![Platform](https://img.shields.io/cocoapods/p/NextGrowingTextView.svg?style=flat)](http://cocoapods.org/pods/NextGrowingTextView)

The next in the generations of 'growing textviews' optimized for iOS 7 and above.

![example1](sample1.gif)

As a successor to [HPGrowingTextView](https://github.com/HansPinckaers/GrowingTextView), NextGrowingTextView was redesigned from scratch to provide the most elegant architecture for iOS 7 and above.

Most autoresizing textviews are implemented with UITextView subclasses. The problem with that approach is that each iOS version changed UITextView's layout behavior, and so most of the implementations are laden with iOS version-specific workarounds to fix bugs and errant behavior. With NextGrowingTextView, the battle with the framework is now over.

NextGrowingTextView approaches the problem differently by wrapping UITextView within a UIScrollView and aligning the textView to the scrollView's contentSize.
```
- public NextGrowingTextView: UIScrollView
    - internal NextGrowingInternalTextView: UITextView
```

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Properties

```swift
public class Delegates {
    public var shouldChangeTextInRange: (range: NSRange, replacementText: String) -> Bool
    public var shouldInteractWithURL: (URL: NSURL, inRange: NSRange) -> Bool
    public var shouldInteractWithTextAttachment: (textAttachment: NSTextAttachment, inRange: NSRange) -> Bool
    public var textViewDidBeginEditing: (NextGrowingTextView) -> Void
    public var textViewDidChangeSelection: (NextGrowingTextView) -> Void
    public var textViewDidEndEditing: (NextGrowingTextView) -> Void
    public var textViewShouldBeginEditing: (NextGrowingTextView) -> Bool
    public var textViewShouldEndEditing: (NextGrowingTextView) -> Bool
    public var textViewDidChange: (NextGrowingTextView) -> Void

    public var willChangeHeight: (CGFloat) -> Void
    public var didChangeHeight: (CGFloat) -> Void
}

public var delegates: Delegates
public var minNumberOfLines: Int { get set }
public var maxNumberOfLines: Int { get set }
public override init(frame: CGRect)
```

## Delegates

```
let growingTextView: NextGrowingTextView

growingTextView.delegates.textViewDidChange = { (growingTextView: NextGrowingTextView) in
    // Do something
}
     
```

## Requirements

iOS 7.0+

## Installation
### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 0.39.0+ is required to build NextGrowingTextView

To integrate NextGrowingTextView into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'NextGrowingTextView'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate NextGrowingTextView into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "muukii/NextGrowingTextView"
```

Run `carthage update` to build the framework and drag the built `NextGrowingTextView.framework` into your Xcode project.


## Author

muukii, m@muukii.me

## License

NextGrowingTextView is available under the MIT license. See the LICENSE file for more info.
