//
//  TextFieldInput.swift
//  EasyDialogs
//
//  Created by Marco Conti on 18.07.17.
//  Copyright © 2017 com.marco83. All rights reserved.
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

public class TextFieldInput<VALUE: StringInputConvertible>: ValueInput<VALUE, NSTextField> {

    public init(label: String = "",
                value: VALUE? = nil,
                validation: @escaping (VALUE?)->(Bool) = { _ in true }
                )
    {
        let textField = NSTextField()
        super.init(
            controlView: textField,
            valueExtraction: { control in
                let string = control.stringValue
                return VALUE(fromStringInput: string)
            },
            setValue: { control, value in
                let string = value?.toStringInput()
                control.stringValue = string ?? ""
            },
            validation: validation
        )
        self.label = label
        self.value = value
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
        self.init(input)!
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
