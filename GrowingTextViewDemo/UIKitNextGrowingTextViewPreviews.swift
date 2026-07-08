import NextGrowingTextView
import UIKit

/// A UIKit preview controller that hosts `NextGrowingTextView` with small,
/// self-contained controls for the most important behaviors.
final class UIKitGrowingTextViewPreviewController: UIViewController {

  private let layout: UIKitGrowingTextViewPreviewLayout
  private let growingTextView = NextGrowingTextView()
  private let minLinesStepper = UIStepper()
  private let maxLinesStepper = UIStepper()
  private let minLinesLabel = UILabel()
  private let maxLinesLabel = UILabel()

  private var minLines = 1 {
    didSet {
      if maxLines < minLines {
        maxLines = minLines
      }
      applyConfiguration()
    }
  }

  private var maxLines = 10 {
    didSet {
      applyConfiguration()
    }
  }

  private var usesLongPlaceholder = false {
    didSet {
      updatePlaceholder()
    }
  }

  /// Creates a preview controller for one UIKit width behavior.
  init(layout: UIKitGrowingTextViewPreviewLayout) {
    self.layout = layout
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemGroupedBackground
    configureGrowingTextView()
    configureSteppers()
    buildLayout()
    applyConfiguration()
  }

  private func configureGrowingTextView() {
    growingTextView.textView.font = .boldSystemFont(ofSize: 20)
    growingTextView.textView.textColor = .label
    growingTextView.placeholderLabel.font = growingTextView.textView.font
    growingTextView.placeholderLabel.textColor = .placeholderText
    growingTextView.placeholderLabel.numberOfLines = 0
    updatePlaceholder()
  }

  private func configureSteppers() {
    minLinesStepper.minimumValue = 1
    minLinesStepper.maximumValue = 5
    minLinesStepper.value = Double(minLines)
    minLinesStepper.addAction(UIAction { [weak self] _ in
      self?.minLines = Int(self?.minLinesStepper.value ?? 1)
    }, for: .valueChanged)

    maxLinesStepper.minimumValue = 1
    maxLinesStepper.maximumValue = 10
    maxLinesStepper.value = Double(maxLines)
    maxLinesStepper.addAction(UIAction { [weak self] _ in
      self?.maxLines = Int(self?.maxLinesStepper.value ?? 1)
    }, for: .valueChanged)
  }

  private func buildLayout() {
    let rootStack = UIStackView(arrangedSubviews: [
      makeHeader(),
      makeEditorContainer(),
      makeControlPanel(),
    ])
    rootStack.axis = .vertical
    rootStack.alignment = .fill
    rootStack.spacing = 16
    rootStack.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(rootStack)

    NSLayoutConstraint.activate([
      rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    ])
  }

  private func makeHeader() -> UIView {
    let titleLabel = UILabel()
    titleLabel.text = "UIKit"
    titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
    titleLabel.adjustsFontForContentSizeCategory = true

    let subtitleLabel = UILabel()
    subtitleLabel.text = layout.subtitle
    subtitleLabel.font = .preferredFont(forTextStyle: .body)
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.numberOfLines = 0
    subtitleLabel.adjustsFontForContentSizeCategory = true

    let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    stack.axis = .vertical
    stack.spacing = 8
    return stack
  }

  private func makeEditorContainer() -> UIView {
    let container = UIView()
    container.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.2)
    container.layer.cornerRadius = 14
    container.translatesAutoresizingMaskIntoConstraints = false

    growingTextView.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(growingTextView)

    var constraints: [NSLayoutConstraint] = [
      growingTextView.topAnchor.constraint(equalTo: container.topAnchor),
      growingTextView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      growingTextView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
    ]

    switch layout {
    case .flexibleWidth:
      constraints.append(growingTextView.widthAnchor.constraint(equalToConstant: 220))
      constraints.append(growingTextView.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor))
      constraints.append(growingTextView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor))
    case .fixedWidth:
      constraints.append(growingTextView.leadingAnchor.constraint(equalTo: container.leadingAnchor))
      constraints.append(growingTextView.trailingAnchor.constraint(equalTo: container.trailingAnchor))
    }

    NSLayoutConstraint.activate(constraints)
    return container
  }

  private func makeControlPanel() -> UIView {
    let textButtonsStack = UIStackView(arrangedSubviews: [
      makeButton(title: "Set text") { [weak self] in
        self?.setLongText()
      },
      makeButton(title: "Clear text") { [weak self] in
        self?.setText("")
      },
    ])
    textButtonsStack.axis = .horizontal
    textButtonsStack.spacing = 8
    textButtonsStack.distribution = .fillEqually

    let buttonsStack = UIStackView(arrangedSubviews: [
      textButtonsStack,
      makeButton(title: "Toggle placeholder") { [weak self] in
        self?.usesLongPlaceholder.toggle()
      },
    ])
    buttonsStack.axis = .vertical
    buttonsStack.spacing = 8

    let stack = UIStackView(arrangedSubviews: [
      buttonsStack,
      makeStepperRow(titleLabel: minLinesLabel, stepper: minLinesStepper),
      makeStepperRow(titleLabel: maxLinesLabel, stepper: maxLinesStepper),
    ])
    stack.axis = .vertical
    stack.spacing = 12
    return stack
  }

  private func makeButton(
    title: String,
    action: @escaping () -> Void
  ) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    button.addAction(UIAction { _ in action() }, for: .touchUpInside)
    return button
  }

  private func makeStepperRow(
    titleLabel: UILabel,
    stepper: UIStepper
  ) -> UIView {
    titleLabel.font = .preferredFont(forTextStyle: .body)
    titleLabel.adjustsFontForContentSizeCategory = true

    let row = UIStackView(arrangedSubviews: [titleLabel, stepper])
    row.axis = .horizontal
    row.alignment = .center
    row.spacing = 12
    return row
  }

  private func applyConfiguration() {
    growingTextView.configuration = .init(
      placeholderHorizontalLayout: layout.placeholderHorizontalLayout,
      minLines: minLines,
      maxLines: maxLines,
      isAutomaticScrollToBottomEnabled: true,
      isFlashScrollIndicatorsEnabled: true
    )

    minLinesStepper.value = Double(minLines)
    maxLinesStepper.minimumValue = Double(minLines)
    maxLinesStepper.value = Double(maxLines)
    minLinesLabel.text = "Min lines: \(minLines)"
    maxLinesLabel.text = "Max lines: \(maxLines)"
  }

  private func updatePlaceholder() {
    if usesLongPlaceholder {
      growingTextView.placeholderLabel.text = "Placeholder, Placeholder, Placeholder, "
    } else {
      growingTextView.placeholderLabel.text = "Placeholder"
    }
  }

  private func setLongText() {
    setText(UIKitGrowingTextViewPreviewText.longMessage)
  }

  private func setText(_ text: String) {
    growingTextView.textView.text = text
    growingTextView.textView.delegate?.textViewDidChange?(growingTextView.textView)
  }
}

/// Width behavior for UIKit `NextGrowingTextView` previews.
enum UIKitGrowingTextViewPreviewLayout {

  /// The editor is centered with a fixed preview width.
  case flexibleWidth

  /// The editor fills the preview container horizontally.
  case fixedWidth

  var subtitle: String {
    switch self {
    case .flexibleWidth:
      "NextGrowingTextView preview: flexible width"
    case .fixedWidth:
      "NextGrowingTextView preview: fixed width"
    }
  }

  var placeholderHorizontalLayout: NextGrowingTextView.Configuration.PlaceholderHorizontalLayout {
    switch self {
    case .flexibleWidth:
      .leading
    case .fixedWidth:
      .center
    }
  }
}

/// Shared sample strings used by the UIKit previews.
private enum UIKitGrowingTextViewPreviewText {

  static let longMessage = """
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere lectus sed arcu facilisis, at bibendum orci interdum. Integer non luctus lorem. Try editing this text and watch the container grow until it reaches the configured maximum line count.
  """
}

#Preview("UIKit / Flexible width") {
  UIKitGrowingTextViewPreviewController(layout: .flexibleWidth)
}

#Preview("UIKit / Fixed width") {
  UIKitGrowingTextViewPreviewController(layout: .fixedWidth)
}
