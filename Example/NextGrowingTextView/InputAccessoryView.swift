// InputAccessoryView.swift
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
import NextGrowingTextView

class InputAccessoryView: UIView {
    
    class Handlers {
        var didBeginTextEditing: () -> Void = {}
        var tapSendButton: () -> Void = { _ in }
    }
    
    let handlers = Handlers()
    
    convenience init() {
        self.init(frame: CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: UIScreen.mainScreen().bounds.width, height: 44))
        )
        self.setup()
    }
    
    var sendButton: UIButton?
    
    func setup() {
        
        self.autoresizingMask = [.FlexibleHeight]
        self.backgroundColor = UIColor.whiteColor()
        self.layer.addSublayer(self.topBorderLayer)
        
        // setup SendButton
        
        let sendButton = UIButton(type: .System)
        let buttonWidth: CGFloat = 50
        let buttonRight: CGFloat = 10
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
        sendButton.frame = CGRect(x: self.bounds.width - buttonWidth - buttonRight, y: 0, width: buttonWidth, height: self.bounds.height)
        sendButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleTopMargin]
        sendButton.addTarget(self, action: "handleSendButton:", forControlEvents: .TouchUpInside)
        self.addSubview(sendButton)
        self.sendButton = sendButton
        
        // setup GrowingTextView
        let view = NextGrowingTextView(frame: CGRect(
            x: 4,
            y: 4,
            width: self.bounds.width - buttonWidth - buttonRight - 10,
            height: self.bounds.height - 8)
        )
        view.placeholderAttributedText = NSAttributedString(string: "Type a message...", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: UIColor(white: 0.8, alpha: 1)])
        view.maxNumberOfLines = 3
        
        view.delegates.willChangeHeight = { [weak self] height in
            
            guard let _self = self, let growingTextView = _self.growingTextView else {
                return
            }
            
            let diff = growingTextView.frame.size.height - height
            var frame = _self.frame
            frame.size.height -= diff
            frame.origin.y += diff
            _self.frame = frame
            
            _self.superview?.constraints.forEach { constraint in
                if constraint.firstAttribute == .Height && constraint.firstItem as! NSObject == _self {
                    constraint.constant = frame.size.height
                }
            }
        }
        
        view.delegates.didChangeHeight = { height in
            
        }
        
        view.delegates.textViewDidBeginEditing = { [weak self] _ in
            self?.handlers.didBeginTextEditing()
        }
        
        view.delegates.textViewDidChange = { [weak self] textView in
            
        }
        
        view.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1)
        view.layer.cornerRadius = 4
        self.addSubview(view)
        self.growingTextView = view
    }
    
    var growingTextView: NextGrowingTextView?
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        
        let width = 1 / UIScreen.mainScreen().scale
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: width / 2))
        path.addLineToPoint(CGPoint(x: layer.frame.maxX, y: width / 2))
        
        self.topBorderLayer.strokeColor = UIColor(white: 0, alpha: 0.3).CGColor
        self.topBorderLayer.lineWidth = width
        self.topBorderLayer.path = path.CGPath
    }
    
    private let topBorderLayer = CAShapeLayer()
    
    @objc private dynamic func handleSendButton(button: UIButton) {
        
        self.handlers.tapSendButton()
        self.growingTextView?.text = nil
    }
}