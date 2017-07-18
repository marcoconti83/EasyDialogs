//
//  ValueInput.swift
//  EasyDialogs
//
//  Created by Marco Conti on 13.07.17.
//  Copyright © 2017 com.marco83. All rights reserved.
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
    
    public init(controlView: CONTROL,
         valueExtraction: @escaping (CONTROL)->VALUE?,
         setValue: @escaping (CONTROL, VALUE?)->() = { _ in },
         validation: @escaping (VALUE?)->(Bool) = { _ in true }
         )
    {
        self.controlView = controlView
        self.labelView = NSTextField.createLabel()
        self.valueExtraction = valueExtraction
        self.setValue = setValue
        self.validation = validation
        super.init(frame: NSRect(x: 0, y: 0, width: 100, height: 50))
        
        self.addSubview(self.labelView)
        self.addSubview(self.controlView)
        
        let padding: CGFloat = 5
        
        constrain(self, self.labelView, self.controlView) { view, label, control in
            label.leading == view.leading + padding
            label.top == view.top  + padding
            label.bottom == view.bottom - padding
            control.trailing == view.trailing - padding
            control.centerY == label.centerY
            control.leading == label.trailing + padding
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
