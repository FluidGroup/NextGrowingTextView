import StorybookKit
import StorybookUI
import UIKit

final class RootContainerViewController: UIViewController {

  init() {
    super.init(nibName: nil, bundle: nil)

    let child = StorybookViewController(
      book: book,
      dismissHandler: nil
    )

    addChild(child)
    view.addSubview(child.view)
    child.view.frame = view.bounds
    child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
