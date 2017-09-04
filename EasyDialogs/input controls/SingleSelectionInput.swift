//
//  SelectionInput.swift
//  EasyDialogs
//
//  Created by Marco Conti on 18.07.17.
//  Copyright © 2017 com.marco83. All rights reserved.
//

import Cocoa
import Cartography

public class SingleSelectionInput<VALUE>: ValueInput<VALUE, NSComboBox> {

    public init(label: String? = nil,
                values: [VALUE],
                value: VALUE? = nil,
                validation: @escaping (VALUE?)->(Bool) = { $0 != nil }
        )
    {
        let combo = NSComboBox()
        combo.isEditable = false
        values.forEach {
            combo.addItem(withObjectValue: $0)
        }

        
        super.init(
            label: label,
            value: value,
            controlView: combo,
            valueExtraction: { control in
                return control.objectValueOfSelectedItem as? VALUE
            },
            setValue: { control, value in
                control.selectItem(withObjectValue: value)
            }
        )

    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
}


