
import MondrianLayout
import CompositionKit
import NextGrowingTextView

final class CenteringViewController: CodeBasedViewController  {
  
  private let nextGrowingTextView = NextGrowingTextView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    nextGrowingTextView.minNumberOfLines = 1
    nextGrowingTextView.maxNumberOfLines = 5
    nextGrowingTextView.placeholderAttributedText =
    
    Mondrian.buildSubviews(on: view) {
      
      VStackBlock {
        nextGrowingTextView
          .viewBlock
          .alignSelf(.fill)
      }
      .padding(20)
      .container(respectingSafeAreaEdges: .all)
      
    }
  }
  
}
