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
        open var shouldChangeTextInRange: (_ range: NSRange, _ replacementText: String) -> Bool = { _ in true }
        open var shouldInteractWithURL: (_ URL: URL, _ inRange: NSRange) -> Bool = { _ in true }
        open var shouldInteractWithTextAttachment: (_ textAttachment: NSTextAttachment, _ inRange: NSRange) -> Bool = { _ in true }
        open var textViewDidBeginEditing: (NextGrowingTextView) -> Void = { _ in }
        open var textViewDidChangeSelection: (NextGrowingTextView) -> Void = { _ in }
        open var textViewDidEndEditing: (NextGrowingTextView) -> Void = { _ in }
        open var textViewShouldBeginEditing: (NextGrowingTextView) -> Bool = { _ in true }
        open var textViewShouldEndEditing: (NextGrowingTextView) -> Bool = { _ in true }
        open var textViewDidChange: (NextGrowingTextView) -> Void = { _ in }

        open var willChangeHeight: (CGFloat) -> Void = { _ in }
        open var didChangeHeight: (CGFloat) -> Void = { _ in }
    }

    open var delegates = Delegates()

    open var minNumberOfLines: Int {
        get {
            return self._minNumberOfLines
        }
        set {
            guard newValue > 1 else {
                self.minHeight = 1
                return
            }

            self.minHeight = self.simulateHeight(newValue)
            self._minNumberOfLines = newValue
        }
    }

    open var maxNumberOfLines: Int {
        get {
            return self._maxNumberOfLines
        }
        set {

            guard newValue > 1 else {
                self.maxHeight = 1
                return
            }

            self.maxHeight = self.simulateHeight(newValue)
            self._maxNumberOfLines = newValue
        }
    }

    open var disableAutomaticScrollToBottom = false

    public override init(frame: CGRect) {
        let textView = NextGrowingInternalTextView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        self.textView = textView
        self.previousFrame = frame

        super.init(frame: frame)

        self.setup()
    }

    public required init?(coder aDecoder: NSCoder) {

        let textView = NextGrowingInternalTextView(frame: CGRect.zero)
        self.textView = textView

        super.init(coder: aDecoder)

        textView.frame = self.bounds
        self.previousFrame = self.frame
        self.setup()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.previousFrame.width != self.bounds.width {
            self.previousFrame = self.frame
            self.fitToScrollView()
        }
    }

    // MARK: UIResponder

    open override var inputView: UIView? {
        get {
            return self.textView.inputView
        }
        set {
            self.textView.inputView = newValue
        }
    }

    open override var isFirstResponder: Bool {
        return self.textView.isFirstResponder
    }

    open override func becomeFirstResponder() -> Bool {
        return self.textView.becomeFirstResponder()
    }

    open override func resignFirstResponder() -> Bool {
        return self.textView.resignFirstResponder()
    }
    
    open override var intrinsicContentSize: CGSize {
        return self.measureFrame(self.measureTextViewSize()).size
    }

    // MARK: Private

    fileprivate let textView: NextGrowingInternalTextView

    fileprivate var _maxNumberOfLines: Int = 0
    fileprivate var _minNumberOfLines: Int = 0
    fileprivate var maxHeight: CGFloat = 0
    fileprivate var minHeight: CGFloat = 0

    fileprivate func setup() {

        self.textView.delegate = self
        self.textView.isScrollEnabled = false
        self.textView.font = UIFont.systemFont(ofSize: 16)
        self.textView.backgroundColor = UIColor.clear
        self.addSubview(textView)
        self.minHeight = simulateHeight(1)
        self.maxNumberOfLines = 3
    }

    fileprivate func measureTextViewSize() -> CGSize {
        return textView.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.infinity))
    }

    fileprivate func measureFrame(_ contentSize: CGSize) -> CGRect {

        let selfSize: CGSize

        if contentSize.height < self.minHeight || !self.textView.hasText {
            selfSize = CGSize(width: contentSize.width, height: self.minHeight)
        } else if self.maxHeight > 0 && contentSize.height > self.maxHeight {
            selfSize = CGSize(width: contentSize.width, height: self.maxHeight)
        } else {
            selfSize = contentSize
        }

        var frame = self.frame
        frame.size.height = selfSize.height
        return frame
    }

    fileprivate func fitToScrollView() {

        let scrollToBottom = self.contentOffset.y == self.contentSize.height - self.frame.height
        let actualTextViewSize = self.measureTextViewSize()
        let oldScrollViewFrame = self.frame

        var frame = self.bounds
        frame.origin = CGPoint.zero
        frame.size.height = actualTextViewSize.height
        self.textView.frame = frame
        self.contentSize = frame.size

        let newScrollViewFrame = self.measureFrame(actualTextViewSize)

        if oldScrollViewFrame.height != newScrollViewFrame.height && newScrollViewFrame.height <= self.maxHeight {
            self.flashScrollIndicators()
            self.delegates.willChangeHeight(newScrollViewFrame.height)
        }

        self.frame = newScrollViewFrame

        if scrollToBottom {
            self.scrollToBottom()
        }
        
        self.invalidateIntrinsicContentSize()
        self.delegates.didChangeHeight(self.frame.height)
    }

    fileprivate func scrollToBottom() {
        if !disableAutomaticScrollToBottom {
            let offset = self.contentOffset
            self.contentOffset = CGPoint(x: offset.x, y: self.contentSize.height - self.frame.height)
        }
    }
    
    fileprivate func updateMinimumAndMaximumHeight() {
        self.minHeight = simulateHeight(1)
        self.maxHeight = simulateHeight(self.maxNumberOfLines)
        self.fitToScrollView()
    }

    fileprivate func simulateHeight(_ line: Int) -> CGFloat {

        let saveText = self.textView.text
        var newText = "-"

        self.textView.delegate = nil
        self.textView.isHidden = true

        for _ in 0..<line-1 {
            newText += "\n|W|"
        }

        self.textView.text = newText

        let height = self.measureTextViewSize().height

        self.textView.text = saveText
        self.textView.isHidden = false
        self.textView.delegate = self

        return height
    }

    fileprivate var previousFrame: CGRect = CGRect.zero
}


// MARK: - TextView Properties

extension NextGrowingTextView {

    // MARK: TextView Extension

    public var placeholderAttributedText: NSAttributedString? {
        get {return self.textView.placeholderAttributedText }
        set {self.textView.placeholderAttributedText = newValue }
    }

    // MARK: TextView

    public var returnKeyType: UIReturnKeyType {
        get { return self.textView.returnKeyType }
        set { self.textView.returnKeyType = newValue }
    }

    public var text: String! {
        get { return self.textView.text }
        set {
            self.textView.text = newValue
            self.fitToScrollView()
        }
    }

    public var font: UIFont? {
        get { return self.textView.font }
        set {
            self.textView.font = newValue
            self.updateMinimumAndMaximumHeight()
        }
    }

    public var textColor: UIColor? {
        get { return self.textView.textColor }
        set { self.textView.textColor = newValue }
    }

    public var textAlignment: NSTextAlignment {
        get { return self.textView.textAlignment }
        set { self.textView.textAlignment = newValue }
    }

    public var selectedRange: NSRange {
        get { return self.textView.selectedRange }
        set { self.textView.selectedRange = newValue }
    }

    public var dataDetectorTypes: UIDataDetectorTypes {
        get { return self.textView.dataDetectorTypes }
        set { self.textView.dataDetectorTypes = newValue }
    }

    public var selectable: Bool {
        get { return self.textView.isSelectable }
        set { self.textView.isSelectable = newValue }
    }

    public var allowsEditingTextAttributes: Bool {
        get { return self.allowsEditingTextAttributes }
        set { self.allowsEditingTextAttributes = newValue }
    }

    public var attributedText: NSAttributedString! {
        get { return self.textView.attributedText }
        set {
            self.textView.attributedText = newValue
            self.fitToScrollView()
        }
    }

    public var typingAttributes: [String : AnyObject] {
        get { return self.textView.typingAttributes as [String : AnyObject] }
        set { self.textView.typingAttributes = newValue }
    }

    public func scrollRangeToVisible(_ range: NSRange) {
        self.textView.scrollRangeToVisible(range)
    }

    public var textViewInputView: UIView? {
        get { return self.textView.inputView }
        set { self.textView.inputView = newValue }
    }

    public var textViewInputAccessoryView: UIView? {
        get { return self.textView.inputAccessoryView }
        set { self.textView.inputAccessoryView = newValue }
    }

    public var clearsOnInsertion: Bool {
        get { return self.textView.clearsOnInsertion }
        set { self.textView.clearsOnInsertion = newValue }
    }

    public var textContainer: NSTextContainer {
        return self.textView.textContainer
    }

    public var textContainerInset: UIEdgeInsets {
        get { return self.textView.textContainerInset }
        set {
            self.textView.textContainerInset = newValue
            self.updateMinimumAndMaximumHeight()
        }
    }

    public var layoutManger: NSLayoutManager {
        return self.textView.layoutManager
    }

    public var textStorage: NSTextStorage {
        return self.textView.textStorage
    }

    public var linkTextAttributes: [String : AnyObject]! {
        get { return self.textView.linkTextAttributes as [String : AnyObject]! }
        set { self.textView.linkTextAttributes = newValue }
    }
}

// MARK: - UIScrollView Properties

extension NextGrowingTextView {

    override open var indicatorStyle: UIScrollViewIndicatorStyle {
        get { return self.textView.indicatorStyle }
        set { self.textView.indicatorStyle = newValue }
    }

    override open var showsHorizontalScrollIndicator: Bool {
        get { return self.textView.showsHorizontalScrollIndicator }
        set { self.textView.showsHorizontalScrollIndicator = newValue }
    }

    override open var showsVerticalScrollIndicator: Bool {
        get { return self.textView.showsVerticalScrollIndicator }
        set { self.textView.showsVerticalScrollIndicator = newValue }
    }

}

extension NextGrowingTextView: UITextViewDelegate {

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return self.delegates.shouldChangeTextInRange(range, text)
    }

    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return self.delegates.shouldInteractWithURL(URL, characterRange)
    }

    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        return self.delegates.shouldInteractWithTextAttachment(textAttachment, characterRange)
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegates.textViewDidBeginEditing(self)
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        self.delegates.textViewDidChangeSelection(self)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        self.delegates.textViewDidEndEditing(self)
    }

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return self.delegates.textViewShouldBeginEditing(self)
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return self.delegates.textViewShouldEndEditing(self)
    }

    public func textViewDidChange(_ textView: UITextView) {

        self.delegates.textViewDidChange(self)

        self.fitToScrollView()
    }
}
