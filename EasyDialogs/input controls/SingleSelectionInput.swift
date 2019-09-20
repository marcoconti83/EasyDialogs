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


import Cocoa
import Cartography

open class SingleSelectionInput<VALUE: Equatable>: ValueInput<VALUE, NSComboBox> {
    
    public init(label: String?,
                     values: [VALUE],
                     valueToDisplay: ((VALUE)->Any)? = nil,
                     value: VALUE? = nil,
                     validationRules: [AnyInputValidation<VALUE>] = [],
                     allowEmpty: Bool = false)
    {
        let combo = NSComboBox()
        combo.isEditable = false
        let possibleValues = (allowEmpty ? values.optionals : values)
        possibleValues.forEach {
            guard let value = $0 else {
                combo.addItem(withObjectValue: "")
                return
            }
            let itemToDisplay: Any
            if let valueToDisplay = valueToDisplay {
                itemToDisplay = valueToDisplay(value)
            } else {
                itemToDisplay = value
            }
            combo.addItem(withObjectValue: itemToDisplay)
        }
        
        // Default value
        let selectedValue: VALUE?
        if let value = value, possibleValues.contains(where: { $0 == value }) {
            selectedValue = value
        } else if !allowEmpty, let first = possibleValues.first {
                selectedValue = first
        } else {
            selectedValue = nil
        }
        
        super.init(
            label: label,
            value: selectedValue,
            controlView: combo,
            valueExtraction: { _, control in
                let index = control.indexOfSelectedItem
                guard index >= 0 else { return nil }
                return possibleValues[index]
            },
            setValue: { _, control, value in
                if let value = value, let index = values.firstIndex(of: value) {
                    control.selectItem(at: index + (allowEmpty ? 1 : 0))
                } else {
                    control.selectItem(at: 0)
                }
            },
            validationRules: validationRules
        )
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public var delegate: NSComboBoxDelegate? {
        get { return self.controlView.delegate }
        set { self.controlView.delegate = newValue }
    }
}

protocol IdentityEquatable: class, Equatable { }

extension IdentityEquatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
}

extension Array {
    
    fileprivate var optionals: [Element?] {
        return [Optional<Element>.none] + self
    }
}
