import CompositionKit
import MondrianLayout
import NextGrowingTextView
import TypedTextAttributes
import UIKit
import Wrap

final class CenteringViewController: CodeBasedViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {

        VStackBlock(spacing: 10) {
          NextGrowingTextView()&>.do {
            $0.configuration = .init(minLines: 1, maxLines: 10, isAutomaticScrollToBottomEnabled: true, isFlashScrollIndicatorsEnabled: true)
          }
            .viewBlock
            .width(.min(30))
            .background(
              UIView()&>.do {
                $0.backgroundColor = .systemYellow.withAlphaComponent(0.2)
              }
            )
            .alignSelf(.center)
          
          NextGrowingTextView()&>.do {
            $0.configuration = .init(minLines: 1, maxLines: 10, isAutomaticScrollToBottomEnabled: true, isFlashScrollIndicatorsEnabled: true)
          }
            .viewBlock
            .background(
              UIView()&>.do {
                $0.backgroundColor = .systemYellow.withAlphaComponent(0.2)
              }
            )
            .alignSelf(.fill)

        }
        
        .alignSelf(.attach(.horizontal))
        
      }
      .padding(20)
      .container(respectingSafeAreaEdges: .all)

    }
  }

}
