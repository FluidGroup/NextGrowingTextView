
import StorybookKit
import NextGrowingTextView
import UIKit
import MondrianLayout

let book = Book(title: "NextGrowingTextView") {
  
  BookPush(title: "Flexible Width") {
    FlexibleWidthCenteringViewController()
  }
  
  BookPush(title: "Fixed Width") {
    FixedWidthViewController()
  }
  
}


func makeControlPanel(for growingTextView: NextGrowingTextView) -> UIView {

  let view = UIView()

  Mondrian.buildSubviews(on: view) {

    VGridBlock(columns: [
      .init(.flexible(), spacing: 10),
      .init(.flexible(), spacing: 10),
    ]) {
      
      UIButton.make(title: "Set text") {
        growingTextView.textView.text = BookGenerator.loremIpsum(length: 300)
      }
      
      UIButton.make(title: "Clear text") {
        growingTextView.textView.text = ""
      }
                  
      UIButton.make(title: "Max = 3") {
        growingTextView.configuration.maxLines = 3
      }
      
      UIButton.make(title: "Max = 10") {
        growingTextView.configuration.maxLines = 10
      }
      
      UIButton.make(title: "Min = 1") {
        growingTextView.configuration.minLines = 1
      }
      
      UIButton.make(title: "Min = 5") {
        growingTextView.configuration.minLines = 5
      }
    }

  }

  return view

}
