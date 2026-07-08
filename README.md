# NextGrowingTextView <sub> <br/>(An Essential UI component for input text)</sub>

<p align="center">
  <img width="320" alt="Example" src="https://github.com/user-attachments/assets/77c5d921-07b2-449e-bb0a-0fa5374ec50a" />
</p>

> 💡  
**Displaying the user-interface on top of the keyboard**  
[muukii/Bureau](https://github.com/muukii/Bureau) enables you to show your user-interface on top of the keyboard in the easiest way.

### SwiftUI

The Swift Package product `NextGrowingTextViewSwiftUI` provides a pure SwiftUI
implementation for iOS 16 and later. It measures a hidden `TextEditor` with the
same font, line spacing, and padding as the visible editor, then applies the
measured height to the visible editor.

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

## Author

[muukii](https://github.com/muukii)

## License

NextGrowingTextView is available under the MIT license. See the LICENSE file for more info.
