//
//  SelectionInput.swift
//  EasyDialogs
//
//  Created by Marco Conti on 18.07.17.
//  Copyright © 2017 com.marco83. All rights reserved.
//

import Cocoa
import Cartography

public class SelectionInput<VALUE>: ValueInput<VALUE, NSComboBox> {

    public init(label: String? = nil,
                values: [VALUE],
                selectedValue: VALUE? = nil,
                validation: @escaping (VALUE?)->(Bool) = { $0 != nil }
        )
    {
        let combo = NSComboBox()
        combo.isEditable = false
        values.forEach {
            combo.addItem(withObjectValue: $0)
        }
        if let selectedValue = selectedValue {
            combo.selectItem(withObjectValue: selectedValue)
        }
        
        super.init(
            controlView: combo,
            valueExtraction: { control in
                return control.objectValueOfSelectedItem as? VALUE
            },
           setValue: { control, value in
                control.selectItem(withObjectValue: value)
            }
        )
        if let label = label {
            self.label = label
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
}


