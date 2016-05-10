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
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NextGrowingInternalTextView.textDidChangeNotification(_ :)), name: UITextViewTextDidChangeNotification, object: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override var text: String! {
        didSet {
            self.updatePlaceholder()
        }
    }
    
    var placeholderAttributedText: NSAttributedString? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        
        super.drawRect(rect)
        
        guard self.displayPlaceholder == true else {
            return
        }
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        
        let targetRect = CGRect(x: 5 + self.textContainerInset.left,
                                y: self.textContainerInset.top,
                                width: self.frame.size.width - (self.textContainerInset.left + self.textContainerInset.right),
                                height: self.frame.size.height - (self.textContainerInset.top + self.textContainerInset.bottom))
        
        let attributedString = self.placeholderAttributedText
        attributedString?.drawInRect(targetRect)
    }
    
    // MARK: Private
    
    private var displayPlaceholder: Bool = true {
        didSet {
            if oldValue != self.displayPlaceholder {
                self.setNeedsDisplay()
            }
        }
    }
    
    private dynamic func textDidChangeNotification(notification: NSNotification) {
        
        self.updatePlaceholder()
    }
    
    private func updatePlaceholder() {
        self.displayPlaceholder = self.text.characters.count == 0
    }
}
