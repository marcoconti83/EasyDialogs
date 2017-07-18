//
//  ViewController.swift
//  EasyDialogsExample
//
//  Created by Marco Conti on 13.07.17.
//  Copyright © 2017 com.marco83. All rights reserved.
//

import Cocoa
import EasyDialogs
import Cartography

class ViewController: NSViewController {

    @IBOutlet weak var stackView: NSStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
         
        let stringInput = TextFieldInput<String>(label: "Input string", value: "foo")
        let repetitionsInput = TextFieldInput<Int>(label: "Repetitions", value: 2, validation: {
            guard let value = $0 else { return false }
            return value >= 0 && value < 100
        })
        let stringOutput = TextFieldInput<String>(label: "Output string")
        
        let button = ClosureButton() { _ in
            guard repetitionsInput.hasValidValue, let repetitions = repetitionsInput.value else {
                stringOutput.value = "ERROR: Repetitions is not a valid number"
                return
            }
            stringOutput.value = String.init(repeating: stringInput.value ?? "", count: repetitions)
        }
        button.title = "Copy value"
        
        [stringInput, stringOutput, repetitionsInput, button].forEach {
            self.stackView.addArrangedSubview($0)
        }
        
        constrain(button, button.superview!) { button, view in
            button.leading == view.leading
            button.trailing == view.trailing
        }
    }
}

