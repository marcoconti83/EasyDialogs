//
//  TextViewInput.swift
//  EasyDialogs
//
//  Created by Marco Conti on 18.07.17.
//  Copyright © 2017 com.marco83. All rights reserved.
//

import Foundation
import Cartography


public class TextViewInput: ValueInput<String, NSScrollView> {
    
    /// The scroll view wrapping an inner text view
    public let scrollView: NSScrollView
    
    /// The inner text view wrapped by a scroll view
    public let textView: NSTextView
    
    public init(label: String? = nil,
                value: String? = nil,
                minimumHeight: CGFloat = 100,
                validation: @escaping (String?)->(Bool) = { _ in true }
        )
    {
        self.textView = NSTextView.textViewForInput()
        self.scrollView = NSScrollView.verticalScrollView(for: self.textView)
        constrain(scrollView) { view in
            view.height >= minimumHeight
        }
        
        super.init(
            label: label,
            value: value,
            controlView: self.scrollView,
            centerControlWithLabel: false,
            valueExtraction: { container in
                guard let control = container.documentView as? NSTextView
                    else { return nil }
                return control.string

            },
            setValue: { container, value in
                guard let control = container.documentView as? NSTextView else { return }
                control.string = value
            },
            validation: validation
        )
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
}

extension NSTextView {
    
    fileprivate static func textViewForInput() -> NSTextView {
        let textView = NSTextView()
        textView.autoresizingMask = .viewWidthSizable
        textView.isVerticallyResizable = true
        textView.textContainer?.widthTracksTextView = true
        textView.isRichText = false
        return textView
    }
}

extension NSScrollView {
    
    static func verticalScrollView(for view: NSView) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .lineBorder
        scrollView.documentView = view
        return scrollView
    }
}
