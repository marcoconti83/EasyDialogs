//
// Copyright (c) 2017 Marco Conti
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//


import Foundation
import Cartography


open class TextViewInput: ValueInput<String, NSView> {
    
    /// The scroll view wrapping an inner text view
    public let scrollView: NSScrollView
    
    /// The inner text view wrapped by a scroll view
    public let textView: NSTextView
    
    public init(label: String? = nil,
                value: String? = nil,
                minimumHeight: CGFloat = 100,
                validationRules: [AnyInputValidation<String>] = []
        )
    {
        let textView = NSTextView.textViewForInput()
        self.textView = textView
        self.scrollView = NSScrollView.verticalScrollView(for: self.textView)
        constrain(scrollView) { view in
            view.height >= minimumHeight
        }
        
        let contentView = NSBox()
        contentView.contentViewMargins = NSSize(width: 0, height: 0)
        contentView.borderColor = .controlShadowColor
        contentView.borderType = .lineBorder
        contentView.boxType = .custom
        contentView.addSubview(scrollView)
        constrain(self.scrollView, contentView) { scroll, content in
            scroll.edges == content.edges
        }
        
        super.init(
            label: label,
            inlineLabel: false,
            value: value,
            controlView: contentView,
            valueExtraction: { _, _ in
                return textView.string

            },
            setValue: { _, _, value in
                textView.string = value ?? ""
            },
            validationRules: validationRules
        )
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    public var delegate: NSTextViewDelegate? {
        get { return self.textView.delegate }
        set { self.textView.delegate = newValue }
    }
}

extension NSTextView {
    
    fileprivate static func textViewForInput() -> NSTextView {
        let textView = NSTextView()
        textView.autoresizingMask = NSView.AutoresizingMask.width
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
        scrollView.documentView = view
        return scrollView
    }
}
