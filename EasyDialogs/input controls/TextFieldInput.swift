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

public protocol StringInputConvertible {
    
    /// Converts self to a string to be
    /// displayed in the input field to represent
    /// the self value
    func toStringInput() -> String?
    
    /// Initializes self from a string input from
    /// an input field
    init?(fromStringInput: String)
}

/// An input field for any value that can be represented with a one-line string
open class TextFieldInput<VALUE: StringInputConvertible>: ValueInput<VALUE, NSTextField> {

    public init(label: String? = nil,
                value: VALUE? = nil,
                validationRules: [AnyInputValidation<VALUE>] = []
                )
    {
        let textField = NSTextField()
        super.init(
            label: label,
            value: value,
            controlView: textField,
            valueExtraction: { _, control in
                let string = control.stringValue
                return VALUE(fromStringInput: string)
            },
            setValue: { _, control, value in
                let string = value?.toStringInput()
                control.stringValue = string ?? ""
            },
            validationRules: validationRules
        )
    }
    
    public var delegate: NSTextFieldDelegate? {
        get { return self.controlView.delegate }
        set { self.controlView.delegate = newValue }
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
}


extension String: StringInputConvertible {
    
    public func toStringInput() -> String? {
        return self
    }
    
    public init?(fromStringInput input: String) {
        self.init(input)
    }
    
}

extension Int: StringInputConvertible {
    
    public func toStringInput() -> String? {
        return String(describing: self)
    }
    
    public init?(fromStringInput input: String) {
        self.init(input)
    }
}

extension UInt: StringInputConvertible {
    
    public func toStringInput() -> String? {
        return String(describing: self)
    }
    
    public init?(fromStringInput input: String) {
        self.init(input)
    }
}

extension URL: StringInputConvertible {
    
    public func toStringInput() -> String? {
        return self.absoluteString
    }
    
    public init?(fromStringInput input: String) {
        self.init(string: input)
    }
}

