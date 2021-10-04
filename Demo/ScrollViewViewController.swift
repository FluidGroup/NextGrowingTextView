//
//  ScrollViewViewController.swift
//  Demo
//
//  Created by Antoine Marandon on 04/10/2021.
//  Copyright © 2021 muukii. All rights reserved.
//

import UIKit
import NextGrowingTextView

final class ScrollViewViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var growingTextView: NextGrowingTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        growingTextView.isScrollEnabled = false
        growingTextView.isAutomaticScrollToBottomEnabled = true
        growingTextView.maxNumberOfLines = 2000
        growingTextView.textView.isScrollEnabled = false
        growingTextView.delegates.didChangeHeight = { [weak self] _ in
            guard let self = self else { return }
            self.scrollView.flashScrollIndicators()
            if self.scrollView.contentSize.height > self.scrollView.frame.height {
                let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.contentInset.bottom)
                self.scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
}
