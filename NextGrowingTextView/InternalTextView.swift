// NextGrowingInternalTextView.swift
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

// MARK: - NextGrowingInternalTextView: UITextView

internal class InternalTextView: UITextView {
  
  enum Action {
    case didBeginEditing
    case didEndEditing
    case didChangeContent
    case didUpdateDepedenciesForHeight
  }

  // MARK: - Internal
  
  var actionHandler: (Action) -> Void = { _ in }

  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(InternalTextView.textDidChangeNotification(_:)),
      name: UITextView.textDidChangeNotification,
      object: self
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(InternalTextView.textDidBeginEditingNotification(_:)),
      name: UITextView.textDidBeginEditingNotification,
      object: self
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(InternalTextView.textDidEndEditingNotification(_:)),
      name: UITextView.textDidEndEditingNotification,
      object: self
    )
    
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override var text: String! {
    didSet {
      actionHandler(.didChangeContent)
    }
  }

  override var attributedText: NSAttributedString! {
    didSet {
      actionHandler(.didChangeContent)
    }
  }

  override var font: UIFont? {
    didSet {
      actionHandler(.didUpdateDepedenciesForHeight)
    }
  }

  override var textContainerInset: UIEdgeInsets {
    didSet {
    }
  }

  // MARK: Private

  @objc
  private dynamic func textDidChangeNotification(_ notification: Notification) {
    actionHandler(.didChangeContent)
  }
  
  @objc
  private dynamic func textDidBeginEditingNotification(_ notification: Notification) {
    actionHandler(.didBeginEditing)
  }
  
  @objc
  private dynamic func textDidEndEditingNotification(_ notification: Notification) {
    actionHandler(.didEndEditing)
  }

}
