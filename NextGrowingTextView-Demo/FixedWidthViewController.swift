import CompositionKit
import MondrianLayout
import NextGrowingTextView
import StorybookKit
import TypedTextAttributes
import UIKit
import Wrap

final class FixedWidthViewController: CodeBasedViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    let textView = NextGrowingTextView()&>.do {
      $0.configuration = .init(
        minLines: 1,
        maxLines: 10,
        isAutomaticScrollToBottomEnabled: true,
        isFlashScrollIndicatorsEnabled: true
      )
      $0.textView.font = UIFont.boldSystemFont(ofSize: 20)
      $0.textView.textColor = .label
      
      $0.placeholderLabel.font = $0.textView.font
      $0.placeholderLabel.textColor = .init(white: 0.5, alpha: 0.5)
      $0.placeholderLabel.text = "Placeholder"
    }

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {

        VStackBlock(spacing: 10) {

          textView
            .viewBlock
            .background(
              UIView()&>.do {
                $0.backgroundColor = .systemYellow.withAlphaComponent(0.2)
              }
            )
            .alignSelf(.fill)

          makeControlPanel(for: textView)
        }

        .alignSelf(.attach(.horizontal))

      }
      .padding(20)
      .container(respectingSafeAreaEdges: .all)

    }
  }

}
