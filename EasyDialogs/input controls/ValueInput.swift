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

open class InputView: NSView {
    
    /// Whether the input has a valid value
    public var hasValidValue: Bool {
        return false
    }
    
    /// Name of the field
    public var name: String
    
    init(name: String) {
        self.name = name
        super.init(frame: NSRect(x: 0, y: 0, width: 100, height: 90))
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
}

public protocol InputViewForValue: class {
   
    associatedtype InputValue
    
    /// The value represented by the current input
    var value: InputValue? { get set }
}

/// A view with a label and an input control to enter a value.
/// It parses and validates the input
open class ValueInput<VALUE, CONTROL: NSView>: InputView, InputViewForValue {
    
    public typealias InputValue = VALUE
    
    /// Control label
    public let labelView: NSTextField
    
    /// Extracts the value from the control
    fileprivate let valueExtraction: (ValueInput<VALUE, CONTROL>, CONTROL)->VALUE?
    
    /// Validation rules for the parsed input
    var validationRules: [AnyInputValidation<VALUE>]
    
    /// Control that holds the value
    public let controlView: CONTROL!
    
    /// Sets the value on the control
    fileprivate let setValue: (ValueInput<VALUE, CONTROL>, CONTROL, VALUE?)->()
    
    public init(
        label: String? = nil,
        inlineLabel: Bool = true,
        value: VALUE? = nil,
        controlView: CONTROL,
        valueExtraction: @escaping (ValueInput<VALUE, CONTROL>, CONTROL)->VALUE?,
        setValue: @escaping (ValueInput<VALUE, CONTROL>, CONTROL, VALUE?)->() = { _,_,_  in },
        validationRules: [AnyInputValidation<VALUE>] = [])
    {
        self.controlView = controlView

        self.labelView = NSTextField.createLabel()
        if inlineLabel {
            self.labelView.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 501), for: .horizontal)
        }
        self.valueExtraction = valueExtraction
        self.setValue = setValue
        self.validationRules = validationRules
        super.init(name: label ?? "")
        
        self.addSubview(self.labelView)
        self.addSubview(self.controlView)
        
        
        let padding: CGFloat = 2
        let labelPadding: CGFloat = 5
        
        constrain(self, self.labelView, self.controlView) { view, label, control in
            control.trailing == view.trailing - padding
            control.bottom == view.bottom - padding
        }
        
        if inlineLabel {
            constrain(self, self.labelView, self.controlView) { view, label, control in
                control.top == label.top
                control.top == view.top + padding
                label.leading == view.leading + padding
                control.leading == label.trailing + labelPadding
            }
        } else {
            constrain(self, self.labelView, self.controlView) { view, label, control in
                control.top == label.bottom + padding
                label.top == view.top + padding
                label.leading == view.leading + padding
                control.leading == view.leading + padding
            }
        }
        
        if let label = label {
            self.label = label
        }
        if let value = value {
            self.value = value
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var hasValidValue: Bool {
        let value = self.valueExtraction(self, self.controlView)
        for validation in self.validationRules {
            if !validation.validate(value) {
                return false
            }
        }
        return true
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
            let value = self.valueExtraction(self, self.controlView)
            return self.hasValidValue ? value : nil
        }
        set {
            self.setValue(self, self.controlView, newValue)
        }
    }
}
