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


// MARK: - NextGrowingTextView: UIScrollView

open class NextGrowingTextView: UIScrollView {

  // MARK: - Public

  open class Delegates {
    open var willChangeHeight: (CGFloat) -> Void = { _ in }
    open var didChangeHeight: (CGFloat) -> Void = { _ in }
  }

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
        minHeight = 1
        return
      }

      minHeight = simulateHeight(newValue)
      _minNumberOfLines = newValue
    }
  }

  open var maxNumberOfLines: Int {
    get {
      return _maxNumberOfLines
    }
    set {

      guard newValue > 1 else {
        maxHeight = 1
        return
      }

      maxHeight = simulateHeight(newValue)
      _maxNumberOfLines = newValue
    }
  }

  open var disableAutomaticScrollToBottom = false

  public override init(frame: CGRect) {
    _textView = NextGrowingInternalTextView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
    previousFrame = frame

    super.init(frame: frame)

    setup()
  }

  public required init?(coder aDecoder: NSCoder) {

    _textView = NextGrowingInternalTextView(frame: CGRect.zero)

    super.init(coder: aDecoder)

    _textView.frame = bounds
    previousFrame = frame
    setup()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    if previousFrame.width != bounds.width {
      previousFrame = frame
      fitToScrollView()
    }
  }

  // MARK: UIResponder

  open override var inputView: UIView? {
    get {
      return _textView.inputView
    }
    set {
      _textView.inputView = newValue
    }
  }

  open override var isFirstResponder: Bool {
    return self._textView.isFirstResponder
  }

  open override func becomeFirstResponder() -> Bool {
    return self._textView.becomeFirstResponder()
  }

  open override func resignFirstResponder() -> Bool {
    return self._textView.resignFirstResponder()
  }

  open override var intrinsicContentSize: CGSize {
    return self.measureFrame(self.measureTextViewSize()).size
  }

  open override func reloadInputViews() {
    super.reloadInputViews()
    _textView.reloadInputViews()
  }

  // MARK: Private

  fileprivate let _textView: NextGrowingInternalTextView

  fileprivate var _maxNumberOfLines: Int = 0
  fileprivate var _minNumberOfLines: Int = 0
  fileprivate var maxHeight: CGFloat = 0
  fileprivate var minHeight: CGFloat = 0

  fileprivate func setup() {

    self._textView.isScrollEnabled = false
    self._textView.font = UIFont.systemFont(ofSize: 16)
    self._textView.backgroundColor = UIColor.clear
    self.addSubview(_textView)
    self.minHeight = simulateHeight(1)
    self.maxNumberOfLines = 3

    _textView.didChange = { [weak self] in
      self?.fitToScrollView()
    }
  }

  fileprivate func measureTextViewSize() -> CGSize {
    return _textView.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.infinity))
  }

  fileprivate func measureFrame(_ contentSize: CGSize) -> CGRect {

    let selfSize: CGSize

    if contentSize.height < self.minHeight || !self._textView.hasText {
      selfSize = CGSize(width: contentSize.width, height: self.minHeight)
    } else if self.maxHeight > 0 && contentSize.height > self.maxHeight {
      selfSize = CGSize(width: contentSize.width, height: self.maxHeight)
    } else {
      selfSize = contentSize
    }

    var _frame = frame
    _frame.size.height = selfSize.height
    return _frame
  }

  fileprivate func fitToScrollView() {

    let shouldScrollToBottom = contentOffset.y == contentSize.height - frame.height
    let actualTextViewSize = measureTextViewSize()
    let oldScrollViewFrame = frame

    var _frame = bounds
    _frame.origin = CGPoint.zero
    _frame.size.height = actualTextViewSize.height
    _textView.frame = _frame
    contentSize = _frame.size

    let newScrollViewFrame = measureFrame(actualTextViewSize)

    if oldScrollViewFrame.height != newScrollViewFrame.height && newScrollViewFrame.height <= maxHeight {
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

  fileprivate func scrollToBottom() {
    if !disableAutomaticScrollToBottom {
      let offset = contentOffset
      contentOffset = CGPoint(x: offset.x, y: contentSize.height - frame.height)
    }
  }

  fileprivate func updateMinimumAndMaximumHeight() {
    self.minHeight = simulateHeight(1)
    self.maxHeight = simulateHeight(self.maxNumberOfLines)
    self.fitToScrollView()
  }

  fileprivate func simulateHeight(_ line: Int) -> CGFloat {

    let saveText = _textView.text
    var newText = "-"

    self._textView.isHidden = true

    for _ in 0..<line-1 {
      newText += "\n|W|"
    }

    _textView.text = newText

    let height = measureTextViewSize().height

    self._textView.text = saveText
    self._textView.isHidden = false

    return height
  }

  fileprivate var previousFrame: CGRect = CGRect.zero
}

extension NextGrowingTextView {
  public var placeholderAttributedText: NSAttributedString? {
    get { return _textView.placeholderAttributedText }
    set { _textView.placeholderAttributedText = newValue }
  }
}
