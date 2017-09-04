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

public class ValueInput<VALUE, CONTROL: NSView>: NSView {
    
    /// Control label
    public let labelView: NSTextField
    
    /// Extracts the value from the control
    fileprivate let valueExtraction: (CONTROL)->VALUE?
    
    /// Validate the parsed input
    var validation: (VALUE?)->(Bool)
    
    /// Control that holds the value
    public let controlView: CONTROL!
    
    /// Sets the value on the control
    fileprivate let setValue: (CONTROL, VALUE?)->()
    
    public init(
        label: String? = nil,
        value: VALUE? = nil,
        controlView: CONTROL,
        centerControlWithLabel: Bool = true,
        valueExtraction: @escaping (CONTROL)->VALUE?,
        setValue: @escaping (CONTROL, VALUE?)->() = { _ in },
        validation: @escaping (VALUE?)->(Bool) = { _ in true })
    {
        self.controlView = controlView
        self.labelView = NSTextField.createLabel()
        self.labelView.setContentHuggingPriority(501, for: .horizontal)
        self.valueExtraction = valueExtraction
        self.setValue = setValue
        self.validation = validation
        super.init(frame: NSRect(x: 0, y: 0, width: 100, height: 90))
        
        self.addSubview(self.labelView)
        self.addSubview(self.controlView)
        
        let padding: CGFloat = 5
        
        constrain(self, self.labelView, self.controlView) { view, label, control in

            control.trailing == view.trailing - padding
            if centerControlWithLabel {
                control.centerY == label.centerY
            } else {
                control.top == label.top
            }
            control.leading == label.trailing + padding
            control.top == view.top  + padding
            control.bottom == view.bottom - padding
            label.leading == view.leading + padding
        }
        
        if let label = label {
            self.label = label
        }
        if let value = value {
            self.value = value
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
}

extension ValueInput {
    
    /// The label for the input control
    public var label: String {
        get {
            return self.labelView.stringValue
        }
        set {
            self.labelView.stringValue = newValue
        }
    }
    
    /// The value represented by the current input
    public var value: VALUE? {
        get {
            let value = self.valueExtraction(self.controlView)
            if self.validation(value) {
                return value
            } else {
                return nil
            }
        }
        set {
            self.setValue(self.controlView, newValue)
        }
    }
    
    /// Whether the input contains a valid value
    public var hasValue: Bool {
        return self.value != nil
    }
}

extension NSTextField {
    
    fileprivate static func createLabel() -> NSTextField {
        let view = NSTextField()
        view.isBezeled = false
        view.drawsBackground = false
        view.isEditable = false
        view.isSelectable = false
        return view
    }
}
