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
import BrightFutures
import Cartography
import ClosureControls

/// A field that is, by default, not edited by interacting with a control
/// but by invoking a function that allows for custom behavior
open class CustomEditorInput<VALUE>: ValueInput<VALUE, NSView> {
    
    private var lastValue: VALUE? {
        didSet {
            self.textField.stringValue = self.valueToString(self.lastValue)
        }
    }
    private let editor: (CustomEditorInput<VALUE>, VALUE?) -> Future<VALUE, AbortedError>
    private let valueToString: (VALUE?) -> String
    private let textField: NSTextField
    
    public init(label: String? = nil,
                value: VALUE? = nil,
                buttonIcon: NSImage? = nil,
                validationRules: [AnyInputValidation<VALUE>] = [],
                editor: @escaping (CustomEditorInput<VALUE>, VALUE?) -> Future<VALUE, AbortedError>,
                valueToString: ((VALUE?) -> String)? = nil
        )
    {
        self.lastValue = value
        self.editor = editor
        self.valueToString = valueToString ?? { $0.map { String(describing: $0) } ?? ""}
        
        let textField = NSTextField()
        textField.isEditable = false
        textField.stringValue = self.valueToString(self.lastValue)
        self.textField = textField
        
        let button = ClosureButton(closure: { _ in })
        button.image = buttonIcon ?? Images.get(name: "pencil.png")
        
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(textField)
        container.addSubview(button)
        
        constrain(container, button, textField) { container, button, textField in
            button.trailing == container.trailing
            button.width == 20
            button.height == 20
            button.leading == textField.trailing + 2
            button.centerY == textField.centerY
            textField.leading == container.leading
            textField.top == container.top
            textField.bottom == container.bottom
            textField.height >= button.height
            textField.width >= 100
        }
        
        super.init(
            label: label,
            value: value,
            controlView: container,
            
            valueExtraction: { input, _ in
                guard let input = input as? CustomEditorInput<VALUE> else { return nil }
                return input.lastValue
        },
            setValue: { input, _, value in
                guard let input = input as? CustomEditorInput<VALUE> else { return }
                input.lastValue = value
        },
            validationRules: validationRules
        )
        
        button.closure = { [weak self] _ in
            self?.startEditor()
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    private func startEditor() {
        self.editor(self, self.lastValue).onSuccess { [weak self] v in
            self?.lastValue = v
        }
    }
}

