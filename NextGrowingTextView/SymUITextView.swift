//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 3/6/23.
//
#if os(iOS)
import UIKit
import SwiftUI
import UniformTypeIdentifiers




public class SymUITextView: UITextView {
    
    //pasteItemsCallback returns true if ALL items were handled
    public var pasteItemsCallback: (([NSItemProvider]) -> Bool)? = nil
    
    public var dropCallback: (([NSItemProvider]) -> Bool)? = nil
    
    /**
     The interaction types that are supported by drag & drop.
     */
    public var supportedDropInteractionTypes: [UTType] = [.image, .text, .plainText, .utf8PlainText, .utf16PlainText] {
        didSet {
            addInteraction(dropInteraction)
        }
    }
    
    
    /**
     Check whether or not a certain action can be performed.
     */
    open override func canPerformAction(
        _ action: Selector,
        withSender sender: Any?
    ) -> Bool {
        
        let isPaste = action == #selector(paste(_:))
        if isPaste {
            return true
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    
    /**
     Paste the current content of the general pasteboard.
     */
    open override func paste(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        
        if let delResp = self.pasteItemsCallback?(pasteboard.itemProviders) {
            print("[SymUITextView] pasteItemsCallback resp: \(delResp)")
        }
        
        super.paste(sender)
    }
    
    /**
     Move the text cursor to a certain input index.

     This will use `safeRange(for:)` to cap the index to the
     available rich text range.
     */
    func moveInputCursor(to index: Int) {
        let newRange = NSRange(location: index, length: 0)
        let safeRange = safeRange(for: newRange)
        setSelectedRange(safeRange)
    }
    /**
     Set the selected range in the text view.

     - Parameters:
       - range: The range to set.
     */
    open func setSelectedRange(_ range: NSRange) {
        selectedRange = range
    }
    
    
    /**
     Set the rich text in the text view.

     - Parameters:
       - text: The rich text to set.
     */
    open func setRichText(_ text: NSAttributedString) {
        attributedString = text
    }
    
    
    // MARK: - UIDropInteractionDelegate

    /**
     The image drop interaction to use when dropping images.
     */
    lazy var dropInteraction: UIDropInteraction = {
        UIDropInteraction(delegate: self)
    }()

    /**
     Whether or not the view can handle a drop session.
     */
    open func dropInteraction(
        _ interaction: UIDropInteraction,
        canHandle session: UIDropSession
    ) -> Bool {
        let identifiers = supportedDropInteractionTypes.map { $0.identifier }
        return session.hasItemsConforming(toTypeIdentifiers: identifiers)
    }

    /**
     Handle an updated drop session.

     - Parameters:
       - interaction: The drop interaction to handle.
       - sessionDidUpdate: The drop session to handle.
     */
    open func dropInteraction(
        _ interaction: UIDropInteraction,
        sessionDidUpdate session: UIDropSession
    ) -> UIDropProposal {
        let operation = dropInteractionOperation(for: session)
        return UIDropProposal(operation: operation)
    }

    /**
     The drop interaction operation for the provided session.

     - Parameters:
       - session: The drop session to handle.
     */
    open func dropInteractionOperation(
        for session: UIDropSession
    ) -> UIDropOperation {
        guard self.canAcceptDropSession(session) else { return .forbidden }

        let location = session.location(in: self)
        return frame.contains(location) ? .copy : .cancel
    }

    /**
     Handle a performed drop session.

     In this function, we reverse the item collection, since
     each item will be pasted at the drop point, which would
     result in a revese result.
     */
    open func dropInteraction(
        _ interaction: UIDropInteraction,
        performDrop session: UIDropSession
    ) {
        guard self.canAcceptDropSession(session) else { return }
        
        let location = session.location(in: self)
        guard let range = self.range(at: location) else { return }
        
        
//        performImageDrop(with: session, at: range)
        performTextDrop(with: session, at: range)
    
        let items = session.items.map { $0.itemProvider }
        let _ = self.dropCallback?(items)
        
    }
    
    func canAcceptDropSession(_ session: UIDropSession) -> Bool {
        let identifiers = supportedDropInteractionTypes.map { $0.identifier }
        return session.hasItemsConforming(toTypeIdentifiers: identifiers)
    }


    // MARK: - Drop Interaction Support

    

    /**
     Perform a text drop session.

     We reverse the item collection, since each item will be
     pasted at the original drop point.
     */
    open func performTextDrop(with session: UIDropSession, at range: NSRange) {
//        if session.hasImage { return }
        _ = session.loadObjects(ofClass: String.self) { items in
            let strings = items.reversed()
            strings.forEach { self.pasteText($0, at: range.location) }
        }
    }
    
    /**
     Get the text range at a certain point.

     - Parameters:
       - index: The text index to get the range from.
     */
    open func range(at index: CGPoint) -> NSRange? {
        guard let range = characterRange(at: index) else { return nil }
        let location = offset(from: beginningOfDocument, to: range.start)
        let length = offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }
}


extension SymUITextView: UIDropInteractionDelegate { }

private extension UIDropSession {

    var hasDroppableContent: Bool {
        hasImage || hasText
    }

    var hasImage: Bool {
        canLoadObjects(ofClass: UIImage.self)
    }

    var hasText: Bool {
        canLoadObjects(ofClass: String.self)
    }
}


extension SymUITextView: RichTextAttributeReader { }

extension SymUITextView: RichTextAttributeWriter {
    /**
     Get the mutable rich text that is managed by the view.
     */
    public var mutableAttributedString: NSMutableAttributedString? {
        textStorage
    }
}



extension SymUITextView {
    
    /**
     Get the rich text that is managed by the text view.
     */
    public var attributedString: NSAttributedString {
        get { self.attributedText ?? NSAttributedString(string: "") }
        set { attributedText = newValue }
    }
    
    /**
     Paste text into the text view, at a certain index.

     - Parameters:
       - text: The text to paste.
       - index: The text index to paste at.
       - moveCursorToPastedContent: Whether or not to move the cursor to the end of the pasted content, by default `false`.
     */
    func pasteText(
        _ text: String,
        at index: Int,
        moveCursorToPastedContent: Bool = false
    ) {
        let content = NSMutableAttributedString(attributedString: attributedString)
        let insertString = NSMutableAttributedString(string: text)
        let insertRange = NSRange(location: index, length: 0)
        let safeInsertRange = safeRange(for: insertRange)
        let safeMoveIndex = safeInsertRange.location + insertString.length
        let attributes = content.richTextAttributes(at: safeInsertRange)
        let attributeRange = NSRange(location: 0, length: insertString.length)
        let safeAttributeRange = safeRange(for: attributeRange)
        insertString.setRichTextAttributes(attributes, at: safeAttributeRange)
        content.insert(insertString, at: index)
        setRichText(content)
        if moveCursorToPastedContent {
            moveInputCursor(to: safeMoveIndex)
        }
    }
    
}


#endif



/**
 This protocol can be implemented any types that can provide
 a rich text string.

 The protocol is implemented by `NSAttributedString` as well
 as other types in the library.
 */
public protocol RichTextReader {

    /**
     The attributed string to use as rich text.
     */
    var attributedString: NSAttributedString { get }
}

extension NSAttributedString: RichTextReader {

    /**
     This type returns itself as the attributed string.
     */
    public var attributedString: NSAttributedString { self }
}

public extension RichTextReader {

    /**
     The rich text to use.

     This is a convenience name alias for ``attributedString``
     to provide this type with a property that uses the rich
     text naming convention.
     */
    var richText: NSAttributedString {
        attributedString
    }

    /**
     Get the range of the entire ``richText``.

     This uses ``safeRange(for:)`` to return a range that is
     always valid for the current rich text.
     */
    var richTextRange: NSRange {
        let range = NSRange(location: 0, length: richText.length)
        let safeRange = safeRange(for: range)
        return safeRange
    }

    /**
     Get the rich text at a certain range.

     Since this function uses ``safeRange(for:)`` to account
     for invalid ranges, always use this function instead of
     the unsafe `attributedSubstring` rich text function.

     - Parameters:
       - range: The range for which to get the rich text.
     */
    func richText(at range: NSRange) -> NSAttributedString {
        let range = safeRange(for: range)
        return attributedString.attributedSubstring(from: range)
    }

    /**
     Get a safe range for the provided range.

     A safe range is limited to the bounds of the attributed
     string and helps protecting against range overflow.

     - Parameters:
       - range: The range for which to get a safe range.
     */
    func safeRange(for range: NSRange) -> NSRange {
        let length = attributedString.length
        return NSRange(
            location: max(0, min(length-1, range.location)),
            length: min(range.length, max(0, length - range.location)))
    }
}


/**
 This protocol extends ``RichTextReader`` and is implemented
 by types that can provide a writable rich text string.

 This protocol is implemented by `NSMutableAttributedString`
 as well as other types in the library.
 */
public protocol RichTextWriter: RichTextReader {

    /**
     Get the writable attributed string provided by the type.
     */
    var mutableAttributedString: NSMutableAttributedString? { get }
}

extension NSMutableAttributedString: RichTextWriter {

    /**
     This type returns itself as mutable attributed string.
     */
    public var mutableAttributedString: NSMutableAttributedString? {
        self
    }
}

public extension RichTextWriter {

    /**
     Get the writable rich text provided by the implementing
     type.

     This is an alias for ``mutableAttributedString`` and is
     used to get a property that uses the rich text naming.
     */
    var mutableRichText: NSMutableAttributedString? {
        mutableAttributedString
    }

    /**
     Replace the text in a certain range with a new string.

     - Parameters:
       - range: The range to replace text in.
       - string: The string to replace the current text with.
     */
    func replaceText(in range: NSRange, with string: String) {
        mutableRichText?.replaceCharacters(in: range, with: string)
    }

    /**
     Replace the text in a certain range with a new string.

     - Parameters:
       - range: The range to replace text in.
       - string: The string to replace the current text with.
     */
    func replaceText(in range: NSRange, with string: NSAttributedString) {
        mutableRichText?.replaceCharacters(in: range, with: string)
    }
}


/**
 This protocol extends ``RichTextWriter`` with functionality
 for writing rich text attributes to the current rich text.

 This protocol is implemented by `NSMutableAttributedString`
 as well as other types in the library.
 */
public protocol RichTextAttributeWriter: RichTextWriter {}

extension NSMutableAttributedString: RichTextAttributeWriter {}

public extension RichTextAttributeWriter {

    /**
     Set a certain rich text attribute to a certain value at
     a certain range.

     The function uses `safeRange(for:)` to handle incorrect
     ranges, which is not handled by the native functions.

     - Parameters:
       - attribute: The attribute to set.
       - newValue: The new value to set the attribute to.
       - range: The range for which to set the attribute.
     */
    func setRichTextAttribute(
        _ attribute: NSAttributedString.Key,
        to newValue: Any,
        at range: NSRange
    ) {
        setRichTextAttributes([attribute: newValue], at: range)
    }

    /**
     Set a set of rich text attributes at a certain range.

     The function uses `safeRange(for:)` to handle incorrect
     ranges, which is not handled by the native functions.

     - Parameters:
       - attributes: The attributes to set.
       - range: The range for which to set the attributes.
     */
    func setRichTextAttributes(
        _ attributes: [NSAttributedString.Key: Any],
        at range: NSRange
    ) {
        let range = safeRange(for: range)
        guard let string = mutableRichText else { return }
        string.beginEditing()
        attributes.forEach { attribute, newValue in
            string.enumerateAttribute(attribute, in: range, options: .init()) { _, range, _ in
                string.removeAttribute(attribute, range: range)
                string.addAttribute(attribute, value: newValue, range: range)
                string.fixAttributes(in: range)
            }
        }
        string.endEditing()
    }
}


/**
 This protocol extends ``RichTextReader`` with functionality
 for reading rich text attributes for the current rich text.

 The protocol is implemented by `NSAttributedString` as well
 as other types in the library.
 */
public protocol RichTextAttributeReader: RichTextReader {}

extension NSAttributedString: RichTextAttributeReader {}

public extension RichTextAttributeReader {

    /**
     Get all rich text attributes at the provided range.

     The function uses `safeRange(for:)` to handle incorrect
     ranges, which is not handled by the native functions.

     This function returns an empty attributes dictionary if
     the rich text is empty, since this check will otherwise
     cause the application to crash.

     - Parameters:
       - range: The range to get attributes from.
     */
    func richTextAttributes(
        at range: NSRange
    ) -> [NSAttributedString.Key: Any] {
        if richText.length == 0 { return [:] }
        let range = safeRange(for: range)
        return richText.attributes(at: range.location, effectiveRange: nil)
    }
}
