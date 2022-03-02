import UIKit

final class SizingContainerView: UILabel /* To use `textRect` method */ {

  // MARK: - Unavailable
  @available(*, unavailable)
  override var text: String? {
    didSet {}
  }

  @available(*, unavailable)
  override var font: UIFont! {
    didSet {}
  }

  @available(*, unavailable)
  override var textColor: UIColor! {
    didSet {}
  }

  @available(*, unavailable)
  override var shadowColor: UIColor? {
    didSet {}
  }

  @available(*, unavailable)
  override var shadowOffset: CGSize {
    didSet {}
  }

  @available(*, unavailable)
  override var textAlignment: NSTextAlignment {
    didSet {}
  }

  @available(*, unavailable)
  override var lineBreakMode: NSLineBreakMode {
    didSet {}
  }

  @available(*, unavailable)
  override var attributedText: NSAttributedString? {
    didSet {}
  }

  @available(*, unavailable)
  override var highlightedTextColor: UIColor? {
    didSet {}
  }

  @available(*, unavailable)
  override var isHighlighted: Bool {
    didSet {}
  }

  @available(*, unavailable)
  override var isEnabled: Bool {
    didSet {}
  }

  @available(*, unavailable)
  override var numberOfLines: Int {
    didSet {}
  }

  @available(*, unavailable)
  override var adjustsFontSizeToFitWidth: Bool {
    didSet {}
  }

  @available(*, unavailable)
  override var baselineAdjustment: UIBaselineAdjustment {
    didSet {}
  }

  @available(*, unavailable)
  override var minimumScaleFactor: CGFloat {
    didSet {}
  }

  @available(*, unavailable)
  override var allowsDefaultTighteningForTruncation: Bool {
    didSet {}
  }

  @available(*, unavailable)
  override func drawText(in rect: CGRect) {
    super.drawText(in: rect)
  }

  @available(*, unavailable)
  override var preferredMaxLayoutWidth: CGFloat {
    didSet {}
  }

  // MARK: - Properties
  
  private let content: UIView
 
  // MARK: - Initializers
  init(
    content: UIView
  ) {
    
    self.content = content

    super.init(frame: .null)

    /// To call `textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int)`
    super.numberOfLines = 0
    isUserInteractionEnabled = true

    addSubview(content)
    
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
    
    let size = content.sizeThatFits(bounds.size)
    return CGRect(origin: .zero, size: size)
  }

  // MARK: - Functions
  override func layoutSubviews() {

    super.layoutSubviews()
    
    content.frame = bounds
  }
}


