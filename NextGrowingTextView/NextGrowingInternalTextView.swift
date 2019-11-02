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

internal class NextGrowingInternalTextView: UITextView {

  // MARK: - Internal

  var didChange: () -> Void = {}
  var didUpdateHeightDependencies: () -> Void = {}
  
  private lazy var placeholderDisplayLabel = UILabel()

  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)

    NotificationCenter.default.addObserver(self, selector: #selector(NextGrowingInternalTextView.textDidChangeNotification(_ :)), name: UITextView.textDidChangeNotification, object: self)
    
    placeholderDisplayLabel.numberOfLines = 0
    placeholderDisplayLabel.adjustsFontSizeToFitWidth = true
    placeholderDisplayLabel.minimumScaleFactor = 0.4
    addSubview(placeholderDisplayLabel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override var text: String! {
    didSet {
      didChange()
      updatePlaceholder()
    }
  }
  
  override var attributedText: NSAttributedString! {
    didSet {
      didChange()
      updatePlaceholder()
    }
  }
    
  override var font: UIFont? {
    didSet {
      didUpdateHeightDependencies()
    }
  }
    
  override var textContainerInset: UIEdgeInsets {
    didSet {
      didUpdateHeightDependencies()
    }
  }
  
  var placeholderAttributedText: NSAttributedString? {
    get {
      placeholderDisplayLabel.attributedText
    }
    set {
      placeholderDisplayLabel.attributedText = newValue
      setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    
    let maxSize = bounds.inset(by: textContainerInset).size
    
    var size = placeholderDisplayLabel.sizeThatFits(maxSize)
    size.height = min(size.height, maxSize.height)
    
    placeholderDisplayLabel.frame = CGRect(
      origin: .init(
        x: 5 + textContainerInset.left,
        y: textContainerInset.top
      ),
      size: size
    )
    
  }

  // MARK: Private

  @objc
  private dynamic func textDidChangeNotification(_ notification: Notification) {
    updatePlaceholder()
    didChange()
  }

  private func updatePlaceholder() {
    placeholderDisplayLabel.isHidden = !text.isEmpty
  }
}
