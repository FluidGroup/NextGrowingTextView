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

open class NextGrowingTextView: UIScrollView {
  
  // MARK: - Nested types
  
  open class Delegates {
    open var willChangeHeight: (CGFloat) -> Void = { _ in }
    open var didChangeHeight: (CGFloat) -> Void = { _ in }
  }

  // MARK: - Properties

  open var delegates = Delegates()

  open var textView: UITextView {
    return _textView
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

  @available(*, deprecated, message: "Use isAutomaticScrollToBottomEnabled")
  open var disableAutomaticScrollToBottom: Bool {
    return !isAutomaticScrollToBottomEnabled
  }

  open var isAutomaticScrollToBottomEnabled = true
  
  open var placeholderAttributedText: NSAttributedString? {
    get { return _textView.placeholderAttributedText }
    set { _textView.placeholderAttributedText = newValue }
  }
  
  open override var inputView: UIView? {
    get {
      return _textView.inputView
    }
    set {
      _textView.inputView = newValue
    }
  }
  
  open override var isFirstResponder: Bool {
    return _textView.isFirstResponder
  }
  
  open override func becomeFirstResponder() -> Bool {
    return _textView.becomeFirstResponder()
  }
  
  open override func resignFirstResponder() -> Bool {
    return _textView.resignFirstResponder()
  }
  
  open override var intrinsicContentSize: CGSize {
    return measureFrame(measureTextViewSize()).size
  }
  
  private let _textView: NextGrowingInternalTextView

  private var _maxNumberOfLines: Int = 3 {
    didSet {
      _maxHeight = simulateHeight(_maxNumberOfLines)
    }
  }

  private var _minNumberOfLines: Int = 1 {
    didSet {
      _minHeight = simulateHeight(_minNumberOfLines)
    }
  }

  private var _maxHeight: CGFloat = 0
  private var _minHeight: CGFloat = 0
  private var _previousFrame: CGRect = CGRect.zero

  // MARK: - Initializers

  public override init(frame: CGRect) {
    
    _textView = NextGrowingInternalTextView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
    _previousFrame = frame

    super.init(frame: frame)

    setup()
  }

  public required init?(coder aDecoder: NSCoder) {

    _textView = NextGrowingInternalTextView(frame: CGRect.zero)

    super.init(coder: aDecoder)

    _textView.frame = bounds
    _previousFrame = frame
    setup()
  }
  
  // MARK: - Functions

  open override func layoutSubviews() {
    super.layoutSubviews()
    guard _previousFrame.width != bounds.width else { return }
    _previousFrame = frame
    fitToScrollView()
  }

  // MARK: UIResponder
 
  open override func reloadInputViews() {
    super.reloadInputViews()
    _textView.reloadInputViews()
  }

  private func setup() {

    _textView.textContainerInset = .init(top: 4, left: 0, bottom: 4, right: 0)
    _textView.isScrollEnabled = false
    _textView.font = UIFont.systemFont(ofSize: 16)
    _textView.backgroundColor = UIColor.clear
    addSubview(_textView)

    updateMinimumAndMaximumHeight()

    _textView.didChange = { [weak self] in
      self?.fitToScrollView()
    }
    _textView.didUpdateHeightDependencies = { [weak self] in
      self?.updateMinimumAndMaximumHeight()
    }
  }

  private func measureTextViewSize() -> CGSize {
    let size = _textView.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.infinity))
    return .init(width: size.width, height: max(size.height, _minHeight))
  }

  private func measureFrame(_ contentSize: CGSize) -> CGRect {

    let selfSize: CGSize

    if contentSize.height < _minHeight || !_textView.hasText {
      selfSize = CGSize(width: contentSize.width, height: _minHeight)
    } else if _maxHeight > 0 && contentSize.height > _maxHeight {
      selfSize = CGSize(width: contentSize.width, height: _maxHeight)
    } else {
      selfSize = contentSize
    }

    var _frame = frame
    _frame.size.height = selfSize.height
    return _frame
  }

  private func fitToScrollView() {

    let shouldScrollToBottom = contentOffset.y == contentSize.height - frame.height
    let actualTextViewSize = measureTextViewSize()
    let oldScrollViewFrame = frame

    var _frame = bounds
    _frame.origin = CGPoint.zero
    _frame.size.height = actualTextViewSize.height
    _textView.frame = _frame
    contentSize = _frame.size

    let newScrollViewFrame = measureFrame(actualTextViewSize)

    if oldScrollViewFrame.height != newScrollViewFrame.height && newScrollViewFrame.height <= _maxHeight {
      flashScrollIndicators()
      delegates.willChangeHeight(newScrollViewFrame.height)
    }

    frame = newScrollViewFrame

    if shouldScrollToBottom {
      scrollToBottom()
    }

    invalidateIntrinsicContentSize()
    delegates.didChangeHeight(frame.height)
  }

  private func scrollToBottom() {
    guard !isAutomaticScrollToBottomEnabled else { return }
    contentOffset.y = contentSize.height - frame.height
  }

  private func updateMinimumAndMaximumHeight() {
    _minHeight = simulateHeight(minNumberOfLines)
    _maxHeight = simulateHeight(maxNumberOfLines)
    fitToScrollView()
  }

  private func simulateHeight(_ line: Int) -> CGFloat {

    let saveText = _textView.text
    var newText = "-"

    _textView.isHidden = true

    for _ in 0..<line-1 {
      newText += "\n|W|"
    }

    _textView.text = newText

    let height = measureTextViewSize().height

    _textView.text = saveText
    _textView.isHidden = false

    return height
  }
}
