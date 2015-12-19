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

public class NextGrowingTextView: UIScrollView {
    
    public class Delegates {
        public var shouldChangeTextInRange: (range: NSRange, replacementText: String) -> Bool = { _ in true }
        public var shouldInteractWithURL: (URL: NSURL, inRange: NSRange) -> Bool = { _ in true }
        public var shouldInteractWithTextAttachment: (textAttachment: NSTextAttachment, inRange: NSRange) -> Bool = { _ in true }
        public var textViewDidBeginEditing: (NextGrowingTextView) -> Void = { _ in }
        public var textViewDidChangeSelection: (NextGrowingTextView) -> Void = { _ in }
        public var textViewDidEndEditing: (NextGrowingTextView) -> Void = { _ in }
        public var textViewShouldBeginEditing: (NextGrowingTextView) -> Bool = { _ in true }
        public var textViewShouldEndEditing: (NextGrowingTextView) -> Bool = { _ in true }
        public var textViewDidChange: (NextGrowingTextView) -> Void = { _ in }
        
        public var willChangeHeight: (CGFloat) -> Void = { _ in }
        public var didChangeHeight: (CGFloat) -> Void = { _ in }
    }
    
    public let delegates = Delegates()
    
    public var minNumberOfLines: Int {
        get {
            return self._minNumberOfLines
        }
        set {
            guard newValue > 0 else {
                self.minHeight = 0
                return
            }
            
            self.minHeight = self.simulateHeight(newValue)
            self._minNumberOfLines = newValue
        }
    }
    
    public var maxNumberOfLines: Int {
        get {
            return self._maxNumberOfLines
        }
        set {
            
            guard newValue > 0 else {
                self.maxHeight = 0
                return
            }
            
            self.maxHeight = self.simulateHeight(newValue)
            self._maxNumberOfLines = newValue
        }
    }
    
    public override init(frame: CGRect) {
        let textView = NextGrowingInternalTextView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        self.textView = textView
        super.init(frame: frame)
        
        if #available(iOS 8.0, *) {
            self.layoutMargins = UIEdgeInsetsZero
        } else {
            // Fallback on earlier versions
        }
        
        self.textView.delegate = self
        self.textView.scrollEnabled = false
        self.textView.font = UIFont.systemFontOfSize(16)
        self.textView.backgroundColor = UIColor.clearColor()
        self.addSubview(textView)
        self.minHeight = frame.height
        self.maxNumberOfLines = 3
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: TextView
    
    public var placeholderAttributedText: NSAttributedString? {
        get {return self.textView.placeholderAttributedText }
        set {self.textView.placeholderAttributedText = newValue }
    }
    
    public var font: UIFont? {
        get { return self.textView.font }
        set { self.textView.font = newValue }
    }
    
    public var text: String! {
        get { return self.textView.text }
        set {
            self.textView.text = newValue
            self.fitToScrollView()
        }
    }
    
    // MARK: UIResponder
    
    public override func becomeFirstResponder() -> Bool {
        return self.textView.becomeFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        return self.textView.resignFirstResponder()
    }
    
    // MARK: Private
    
    private let textView: NextGrowingInternalTextView
    
    private var _maxNumberOfLines: Int = 0
    private var _minNumberOfLines: Int = 0
    private var maxHeight: CGFloat = 0
    private var minHeight: CGFloat = 0
    
    private func measureTextViewSize() -> CGSize {
        return textView.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.infinity))
    }
    
    private func fitToScrollView() {
        
        let followBottom = self.contentOffset.y == self.contentSize.height - self.frame.height
        
        var size = self.measureTextViewSize()
        size.width = self.frame.width
        size.height = max(self.minHeight, size.height)
        
        let oldSize = self.textView.frame.size
        
        if oldSize.height != size.height && self.maxHeight > 0 && self.maxHeight >= size.height {
            self.delegates.willChangeHeight(size.height)
        }
        
        var frame = self.textView.frame
        frame.size = size
        textView.frame = frame
        self.contentSize = size
        
        if followBottom {
            self.scrollToBottom()
        }
        
        if self.maxHeight >= size.height {
            var frame = self.frame
            frame.size.height = size.height
            self.frame = frame
        }
    }
    
    private func scrollToBottom() {
        let offset = self.contentOffset
        self.contentOffset = CGPoint(x: offset.x, y: self.contentSize.height - self.frame.height)
    }
    
    private func simulateHeight(line: Int) -> CGFloat {
        
        let saveText = self.textView.text
        var newText = "-"
        
        self.textView.delegate = nil
        self.textView.hidden = true
        
        for _ in 0..<line {
            newText += "\n|W|"
        }
        
        self.textView.text = newText
        
        let textViewMargin: CGFloat = 16
        let height = self.measureTextViewSize().height - (textViewMargin + self.textView.contentInset.top + self.textView.contentInset.bottom)
        
        self.textView.text = saveText
        self.textView.hidden = false
        self.textView.delegate = self
        
        return height
    }
}

extension NextGrowingTextView: UITextViewDelegate {
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return self.delegates.shouldChangeTextInRange(range: range, replacementText: text)
    }
    
    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return self.delegates.shouldInteractWithURL(URL: URL, inRange: characterRange)
    }
    
    public func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        return self.delegates.shouldInteractWithTextAttachment(textAttachment: textAttachment, inRange: characterRange)
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        self.delegates.textViewDidBeginEditing(self)
    }
    
    public func textViewDidChangeSelection(textView: UITextView) {
        self.delegates.textViewDidChangeSelection(self)
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        self.delegates.textViewDidEndEditing(self)
    }
    
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return self.delegates.textViewShouldBeginEditing(self)
    }
    
    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return self.delegates.textViewShouldEndEditing(self)
    }
    
    public func textViewDidChange(textView: UITextView) {
        
        self.delegates.textViewDidChange(self)
        
        self.fitToScrollView()
    }
}