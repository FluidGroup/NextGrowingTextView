# NextGrowingTextView

[![CI Status](http://img.shields.io/travis/muukii/NextGrowingTextView.svg?style=flat)](https://travis-ci.org/muukii/NextGrowingTextView)
[![Version](https://img.shields.io/cocoapods/v/NextGrowingTextView.svg?style=flat)](http://cocoapods.org/pods/NextGrowingTextView)
[![License](https://img.shields.io/cocoapods/l/NextGrowingTextView.svg?style=flat)](http://cocoapods.org/pods/NextGrowingTextView)
[![Platform](https://img.shields.io/cocoapods/p/NextGrowingTextView.svg?style=flat)](http://cocoapods.org/pods/NextGrowingTextView)

The next in the generations of 'growing textviews' optimized for iOS 7 and above.

![example1](sample1.gif)

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

public let delegates: NextGrowingTextView.NextGrowingTextView.Delegates
public var minNumberOfLines: Int { get set }
public var maxNumberOfLines: Int { get set }
public override init(frame: CGRect)
```

## Requirements

iOS 7.0+

## Installation

NextGrowingTextView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NextGrowingTextView"
```

## Author

muukii, m@muukii.me

## License

NextGrowingTextView is available under the MIT license. See the LICENSE file for more info.
