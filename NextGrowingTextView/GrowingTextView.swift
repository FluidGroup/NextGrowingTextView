//
//  GrowingTextView.swift
//  NextGrowingTextView
//
//  Created by muukii on 8/21/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import Foundation

open class GrowingTextView : UITextView {

  open var isAutomaticScrollToBottomEnabled = true

  open override var textContainerInset: UIEdgeInsets {
    didSet {
      updateLayout()
    }
  }

  open var minNumberOfLines: Int {
    get {
      return _minNumberOfLines
    }
    set {
      guard newValue > 1 else {
        _minNumberOfLines = 1
        return
      }

      _minNumberOfLines = newValue
    }
  }

  open var maxNumberOfLines: Int {
    get {
      return _maxNumberOfLines
    }
    set {
      guard newValue > 1 else {
        _maxNumberOfLines = 1
        return
      }

      _maxNumberOfLines = newValue
    }
  }

  private var _previousFrame: CGRect = CGRect.zero

  private var _maxNumberOfLines: Int = 3 {
    didSet {
      updateLayout()
    }
  }

  private var _minNumberOfLines: Int = 1 {
    didSet {
      updateLayout()
    }
  }

  private var _maxHeight: CGFloat = 0
  private var _minHeight: CGFloat = 0

  open var placeholderAttributedText: NSAttributedString? {
    didSet {
      setNeedsDisplay()
    }
  }

  open override var intrinsicContentSize: CGSize {
    return CGSize(
      width: UIViewNoIntrinsicMetric,
      height: min(max(measureTextViewSize().height, _minHeight), _maxHeight)
    )
  }

  // MARK: - Initializers

  public override init(frame: CGRect, textContainer: NSTextContainer?) {

    _previousFrame = frame
    super.init(frame: frame, textContainer: textContainer)
    setup()
  }

  public required init?(coder aDecoder: NSCoder) {

    super.init(coder: aDecoder)
    _previousFrame = frame
    setup()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - Functions

  private func setup() {

    contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    contentMode = .redraw
    font = .preferredFont(forTextStyle: .body)
    isScrollEnabled = false
    backgroundColor = .clear

    updateLayout()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(textDidChangeNotification(_ :)),
      name: .UITextViewTextDidChange,
      object: self
    )
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    if _previousFrame.size != frame.size {
      _previousFrame = frame
      setNeedsDisplay()
    }

  }

  private func simulateHeight(numberOflines: Int) -> CGFloat {

    isHidden = true

    textStorage.beginEditing()

    let currentText = textStorage.copy() as! NSAttributedString

    var newText = "-"

    for _ in 0..<numberOflines-1 {
      newText += "\n|W|"
    }

    textStorage.setAttributedString(
      .init(
        string: newText,
        attributes: [.font : font as Any]
      )
    )

    textStorage.endEditing()

    let height = measureTextViewSize().height

    textStorage.beginEditing()
    textStorage.setAttributedString(currentText)
    textStorage.endEditing()

    isHidden = false

    return height
  }

  private func measureTextViewSize() -> CGSize {
    return sizeThatFits(
      CGSize(
        width: bounds.width,
        height: .infinity
      )
    )
  }

  @objc
  private dynamic func textDidChangeNotification(_ notification: Notification) {

    invalidateIntrinsicContentSize()
    setNeedsLayout()
    layoutIfNeeded()

    let height = measureTextViewSize().height
    print(bounds.size.height, height)
    if bounds.size.height >= height {
      isScrollEnabled = false
    } else {
      isScrollEnabled = true
    }

    updatePlaceholder()
    scrollToBottom()
  }

  open override func draw(_ rect: CGRect) {
    super.draw(rect)

    guard displayPlaceholder else { return }

    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = textAlignment

    let targetRect = CGRect(
      x: 5 + textContainerInset.left,
      y: textContainerInset.top,
      width: frame.size.width - (textContainerInset.left + textContainerInset.right),
      height: frame.size.height - (textContainerInset.top + textContainerInset.bottom)
    )

    let attributedString = placeholderAttributedText
    attributedString?.draw(in: targetRect)
  }


  private var displayPlaceholder: Bool = true {
    didSet {
      if oldValue != displayPlaceholder {
        setNeedsDisplay()
      }
    }
  }

  private func updatePlaceholder() {
    displayPlaceholder = text.isEmpty
  }

  private func scrollToBottom() {
    guard isAutomaticScrollToBottomEnabled else { return }

    if bounds.size.height > contentSize.height {
      contentOffset.y = contentSize.height - frame.height
    }
  }

  private func updateLayout() {

    _minHeight = simulateHeight(numberOflines: 1)
    _maxHeight = simulateHeight(numberOflines: maxNumberOfLines)
    invalidateIntrinsicContentSize()
  }
}
