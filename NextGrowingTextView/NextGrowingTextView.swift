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
        textView = NextGrowingInternalTextView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        previousFrame = frame

        super.init(frame: frame)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {

        textView = NextGrowingInternalTextView(frame: CGRect.zero)

        super.init(coder: aDecoder)

        textView.frame = bounds
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
            return textView.inputView
        }
        set {
            textView.inputView = newValue
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
    
    open override func reloadInputViews() {
        super.reloadInputViews()
        textView.reloadInputViews()
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
        textView.frame = _frame
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

        let saveText = textView.text
        var newText = "-"

        self.textView.delegate = nil
        self.textView.isHidden = true

        for _ in 0..<line-1 {
            newText += "\n|W|"
        }

        textView.text = newText

        let height = measureTextViewSize().height

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
        get {return textView.placeholderAttributedText }
        set {textView.placeholderAttributedText = newValue }
    }

    // MARK: TextView

    public var returnKeyType: UIReturnKeyType {
        get { return textView.returnKeyType }
        set { textView.returnKeyType = newValue }
    }
    
    public var spellCheckingType: UITextSpellCheckingType {
        get { return textView.spellCheckingType }
        set { textView.spellCheckingType = newValue }
    }
    
    public var autocorrectionType: UITextAutocorrectionType {
        get { return textView.autocorrectionType }
        set { textView.autocorrectionType = newValue }
    }
    
    public var autocapitalizationType: UITextAutocapitalizationType {
        get { return textView.autocapitalizationType }
        set { textView.autocapitalizationType = newValue }
    }

    public var text: String! {
        get { return textView.text }
        set {
            textView.text = newValue
            fitToScrollView()
        }
    }

    public var font: UIFont? {
        get { return textView.font }
        set {
            textView.font = newValue
            updateMinimumAndMaximumHeight()
        }
    }

    public var textColor: UIColor? {
        get { return textView.textColor }
        set { textView.textColor = newValue }
    }

    public var textAlignment: NSTextAlignment {
        get { return textView.textAlignment }
        set { textView.textAlignment = newValue }
    }

    public var selectedRange: NSRange {
        get { return textView.selectedRange }
        set { textView.selectedRange = newValue }
    }

    public var dataDetectorTypes: UIDataDetectorTypes {
        get { return textView.dataDetectorTypes }
        set { textView.dataDetectorTypes = newValue }
    }

    public var selectable: Bool {
        get { return self.textView.isSelectable }
        set { self.textView.isSelectable = newValue }
    }

    public var allowsEditingTextAttributes: Bool {
        get { return textView.allowsEditingTextAttributes }
        set { textView.allowsEditingTextAttributes = newValue }
    }

    public var attributedText: NSAttributedString! {
        get { return textView.attributedText }
        set {
            textView.attributedText = newValue
            fitToScrollView()
        }
    }

    public var typingAttributes: [String : Any] {
        get { return self.textView.typingAttributes }
        set { self.textView.typingAttributes = newValue }
    }

    public func scrollRangeToVisible(_ range: NSRange) {
        self.textView.scrollRangeToVisible(range)
    }

    public var textViewInputView: UIView? {
        get { return textView.inputView }
        set { textView.inputView = newValue }
    }
    
    public var keyboardType: UIKeyboardType {
        get { return textView.keyboardType }
        set { textView.keyboardType = newValue }
    }

    public var textViewInputAccessoryView: UIView? {
        get { return textView.inputAccessoryView }
        set { textView.inputAccessoryView = newValue }
    }

    public var clearsOnInsertion: Bool {
        get { return textView.clearsOnInsertion }
        set { textView.clearsOnInsertion = newValue }
    }

    public var textContainer: NSTextContainer {
        return textView.textContainer
    }

    public var textContainerInset: UIEdgeInsets {
        get { return textView.textContainerInset }
        set {
            textView.textContainerInset = newValue
            updateMinimumAndMaximumHeight()
        }
    }

    public var layoutManger: NSLayoutManager {
        return textView.layoutManager
    }

    public var textStorage: NSTextStorage {
        return textView.textStorage
    }

    public var linkTextAttributes: [String : Any]! {
        get { return self.textView.linkTextAttributes}
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

        delegates.textViewDidChange(self)

        fitToScrollView()
    }
}
