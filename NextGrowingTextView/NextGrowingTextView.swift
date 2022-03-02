// NextGrowingTextView.swift
//
// Copyright (c) 2015 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit

open class NextGrowingTextView: UIView {

  public struct Configuration {

    public var minLines: Int
    public var maxLines: Int

    public var isAutomaticScrollToBottomEnabled: Bool = true
    public var isFlashScrollIndicatorsEnabled: Bool = false

    public init(
      minLines: Int = 1,
      maxLines: Int = 3,
      isAutomaticScrollToBottomEnabled: Bool = true,
      isFlashScrollIndicatorsEnabled: Bool = false
    ) {

      self.minLines = minLines
      self.maxLines = maxLines
      self.isAutomaticScrollToBottomEnabled = isAutomaticScrollToBottomEnabled
      self.isFlashScrollIndicatorsEnabled = isFlashScrollIndicatorsEnabled
    }
  }

  public enum Action {
    case willChangeHeight(newHeight: CGFloat)
    case didChangeHeight(newHeight: CGFloat)
  }

  public final var actionHandler: (Action) -> Void {
    get { scrollable.actionHandler }
    set { scrollable.actionHandler = newValue }
  }

  public final var textView: UITextView {
    scrollable.textView
  }

  public var configuration: Configuration {
    get { scrollable.configuration }
    set { scrollable.configuration = newValue }
  }

  private let scrollable: PlatterTextView

  private let sizingContainer: SizingContainerView

  public init() {
    self.scrollable = .init(frame: .null)
    self.sizingContainer = .init(content: self.scrollable)

    super.init(frame: .null)

    addSubview(sizingContainer)
    sizingContainer.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      sizingContainer.topAnchor.constraint(equalTo: topAnchor),
      sizingContainer.rightAnchor.constraint(equalTo: rightAnchor),
      sizingContainer.leftAnchor.constraint(equalTo: leftAnchor),
      sizingContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIResponder

  open override var inputView: UIView? {
    get { scrollable.inputView }
    set { scrollable.inputView = newValue }
  }

  open override var isFirstResponder: Bool {
    return scrollable.isFirstResponder
  }

  @discardableResult
  open override func becomeFirstResponder() -> Bool {
    return scrollable.becomeFirstResponder()
  }

  @discardableResult
  open override func resignFirstResponder() -> Bool {
    return scrollable.resignFirstResponder()
  }

  open override func reloadInputViews() {
    super.reloadInputViews()
    scrollable.reloadInputViews()
  }

}

final class PlatterTextView: UIScrollView {

  private struct State: Equatable {
    var previousFrame: CGRect = .null
    var isFixingMenuPosition = false

    var resolvedMinHeight: CGFloat = 0
    var resolvedMaxHeight: CGFloat = 0
  }

  // MARK: - Properties

  var configuration: NextGrowingTextView.Configuration = .init() {
    didSet {
      update(by: configuration)
    }
  }

  var actionHandler: (NextGrowingTextView.Action) -> Void = { _ in }

  var textView: UITextView {
    return _textView
  }

  //  @available(*, deprecated, message: "Use isAutomaticScrollToBottomEnabled")
  //  var disableAutomaticScrollToBottom: Bool {
  //    return !isAutomaticScrollToBottomEnabled
  //  }
  //
  //  var isAutomaticScrollToBottomEnabled = true
  //
  //  /// Use this to enable/disable flash scroll indicators while scroll height is less than max height
  //  var isFlashScrollIndicatorsEnabled = false
  //
  //  var placeholderAttributedText: NSAttributedString? {
  //    get { return _textView.placeholderAttributedText }
  //    set { _textView.placeholderAttributedText = newValue }
  //  }
  //
  //  /// true: Let the placeholder spans any number of lines. The view must be tall enough to contain it.
  //  /// false: placeholder will shring by up to 0.4 if it cannot fit one line.
  //  var isPlacholderMultiline: Bool {
  //    get { _textView.isPlaceHolderMultiLine }
  //    set { _textView.isPlaceHolderMultiLine = newValue }
  //  }

  private let _textView: InternalTextView

  private var state: State = .init() {
    didSet {
      guard oldValue != state else { return }
      update(by: state)
    }
  }

  // MARK: - Initializers

  override init(frame: CGRect) {

    _textView = InternalTextView(frame: CGRect(origin: CGPoint.zero, size: frame.size))

    super.init(frame: frame)

    state.previousFrame = frame

    setup()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIResponder

  override var inputView: UIView? {
    get { _textView.inputView }
    set { _textView.inputView = newValue }
  }

  override var isFirstResponder: Bool {
    return _textView.isFirstResponder
  }

  @discardableResult
  override func becomeFirstResponder() -> Bool {
    return _textView.becomeFirstResponder()
  }

  @discardableResult
  override func resignFirstResponder() -> Bool {
    return _textView.resignFirstResponder()
  }

  override func reloadInputViews() {
    super.reloadInputViews()
    _textView.reloadInputViews()
  }

  // MARK: - UIView

  override func layoutSubviews() {

    super.layoutSubviews()

    guard state.previousFrame.width != bounds.width else { return }

    state.previousFrame = frame
    fitToScrollView()
  }

  // MARK: - Functions

  private func setup() {

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(willShowMenu(_:)),
      name: UIMenuController.willShowMenuNotification,
      object: nil
    )

    _textView.textContainerInset = .init(top: 4, left: 0, bottom: 4, right: 0)
    _textView.isScrollEnabled = false
    _textView.font = UIFont.systemFont(ofSize: 16)
    _textView.backgroundColor = UIColor.clear
    addSubview(_textView)

    _textView.didChangeContent = { [weak self] in
      self?.fitToScrollView()
    }
    _textView.didUpdateHeightDependencies = { [weak self] in
      guard let self = self else { return }
      self.update(by: self.configuration)
    }

    update(by: configuration)
  }

  /**
   Fixing rect to display UIMenu to provide function copy or paste.
   */
  @objc private func willShowMenu(_ notification: Notification) {

    guard
      let menuController = notification.object as? UIMenuController,
      let superview = superview,
      state.isFixingMenuPosition == false,
      _textView.isFirstResponder,
      !menuController.menuFrame.intersects(superview.convert(frame, to: nil))
    else {
      return
    }

    menuController.setMenuVisible(false, animated: false)
    menuController.setTargetRect(frame, in: superview)
    state.isFixingMenuPosition = true
    menuController.setMenuVisible(true, animated: true)
    state.isFixingMenuPosition = false
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let calculatedSize = _textView.sizeThatFits(size)
    return .init(
      width: calculatedSize.width,
      height: min(max(calculatedSize.height, state.resolvedMinHeight), state.resolvedMaxHeight)
    )
  }

  private func update(by configuration: NextGrowingTextView.Configuration) {

    state.resolvedMaxHeight = simulateHeight(configuration.maxLines)
    state.resolvedMinHeight = simulateHeight(configuration.minLines)

    fitToScrollView()
  }

  private func update(by state: State) {

  }

  private func fitToScrollView() {

    func measureFrame(actualTextViewSize: CGSize) -> CGRect {

      let containerSize: CGSize

      if actualTextViewSize.height < state.resolvedMinHeight || !_textView.hasText {
        containerSize = CGSize(width: actualTextViewSize.width, height: state.resolvedMinHeight)
      } else if state.resolvedMaxHeight > 0 && actualTextViewSize.height > state.resolvedMaxHeight {
        containerSize = CGSize(width: actualTextViewSize.width, height: state.resolvedMinHeight)
      } else {
        containerSize = actualTextViewSize
      }

      var _frame = frame
      _frame.size.height = containerSize.height
      return _frame
    }

    func measureTextViewSizeInCurrentBounds() -> CGSize {
      let size = _textView.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.infinity))
      return .init(width: size.width, height: max(size.height, state.resolvedMinHeight))
    }

    let shouldScrollToBottom = contentOffset.y == contentSize.height - frame.height
    let actualTextViewSize = measureTextViewSizeInCurrentBounds()
    let oldScrollViewFrame = frame

    var _frame = bounds
    _frame.origin = CGPoint.zero
    _frame.size.height = actualTextViewSize.height
    _textView.frame = _frame
    contentSize = _frame.size

    let newScrollViewFrame = measureFrame(actualTextViewSize: actualTextViewSize)

    if oldScrollViewFrame.height != newScrollViewFrame.height {
      actionHandler(.willChangeHeight(newHeight: newScrollViewFrame.height))

      if configuration.isFlashScrollIndicatorsEnabled,
        newScrollViewFrame.height <= state.resolvedMaxHeight
      {
        flashScrollIndicators()
      }
    }

    frame = newScrollViewFrame

    if configuration.isAutomaticScrollToBottomEnabled == true, shouldScrollToBottom {
      contentOffset.y = contentSize.height - frame.height
    }

    invalidateIntrinsicContentSize()
    superview?.invalidateIntrinsicContentSize()
    actionHandler(.didChangeHeight(newHeight: frame.height))
  }

  private func simulateHeight(_ line: Int) -> CGFloat {

    func measureTextViewHeight() -> CGFloat {
      let size = _textView.sizeThatFits(CGSize(width: 1000, height: CGFloat.infinity))
      return size.height
    }

    let savedText = _textView.attributedText
    var newText = "-"

    _textView.isHidden = true

    for _ in 0..<line - 1 {
      newText += "\n|W|"
    }

    _textView.text = newText

    let height = measureTextViewHeight()

    _textView.attributedText = savedText
    _textView.isHidden = false

    return height
  }
}
