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
         
        let stringInput = TextFieldInput<String>(label: "Input string", value: "foo bar")
        let stringOutput = TextFieldInput<String>(label: "Output string")
        
        let button = ClosureButton() { _ in
            stringOutput.value = stringInput.value
            stringInput.value = nil
        }
        button.title = "Copy value"
        
        [stringInput, stringOutput, button].forEach {
            self.stackView.addArrangedSubview($0)
        }
        
        constrain(button, button.superview!) { button, view in
            button.leading == view.leading
            button.trailing == view.trailing
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

