# NextGrowingTextView <sub> <br/>(An Essential UI component for input text)</sub>

|flexible width | fixed width |
|---|---|
|<img width=200px src="https://user-images.githubusercontent.com/1888355/156420538-76b2d75b-ca50-46f0-b95f-056d2ef30953.gif" />|<img width=200px src="https://user-images.githubusercontent.com/1888355/156420669-f1a8003e-cd43-41c3-b482-7a5baf9d5561.gif" />|

> 💡  
**Displaying the user-interface on top of the keyboard**  
[muukii/Bureau](https://github.com/muukii/Bureau) enables you to show your user-interface on top of the keyboard in the easiest way.


## How to use

1. Create an instance
2. Add subview with layout

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

**Accessing actual UITextView to apply settings**
```swift
growingTextView.textView
```

**Accessing UILabel for displaying placeholder**

```swift
growingTextView.placeholderLabel
```

### SwiftUI

The Swift Package product `NextGrowingTextViewSwiftUI` provides a pure SwiftUI
implementation for iOS 16 and later. It measures a hidden `TextEditor` with the
same font, line spacing, and padding as the visible editor, then applies the
measured height to the visible editor.

<p align="center">
  <img width="320" alt="Messages-style SwiftUI GrowingTextEditor preview" src="https://github.com/user-attachments/assets/350effb0-5f12-4bc8-ad44-da256d82c400" />
</p>

```swift
import NextGrowingTextViewSwiftUI

@State private var text = ""

GrowingTextEditor(
  text: $text,
  placeholder: "Write something...",
  configuration: GrowingTextEditorConfiguration(
    minLines: 1,
    maxLines: 6,
    horizontalPadding: 8,
    verticalPadding: 4,
    lineSpacing: 3
  ),
  font: .body
)
```

`GrowingTextView` is also available as a typealias when call sites prefer the
TextView naming.

## Requirements

- UIKit API: iOS 9.0+ Swift 5.5+
- Swift Package Manager products: iOS 16.0+
- SwiftUI `GrowingTextEditor` API: iOS 16.0+

## Installation

Swift Package Manager is the supported installation method.

## Author

[muukii](https://github.com/muukii)

## License

NextGrowingTextView is available under the MIT license. See the LICENSE file for more info.

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmuukii%2FNextGrowingTextView.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmuukii%2FNextGrowingTextView?ref=badge_large)
