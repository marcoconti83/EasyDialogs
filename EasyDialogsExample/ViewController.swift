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

    private var outputField: TextFieldInput<String>!

    
    @IBOutlet weak var stackView: NSStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.outputField = TextFieldInput<String>(label: "Output")
         
        let stringInput = TextFieldInput<String>(label: "Input string", value: "foo")
        let repetitionsInput = TextFieldInput<Int>(label: "Repetitions", value: 2, validation: {
            $0 != nil && $0! >= 0 && $0! < 100
        })
        let copyStringButton = ClosureButton(label: "Copy value") { _ in
            guard let repetitions = repetitionsInput.value else {
                self.log("ERROR: Repetitions is not a valid number")
                return
            }
            self.outputField.value = String.init(repeating: stringInput.value ?? "", count: repetitions)
        }
        

        let urlInput = TextFieldInput<URL>(label: "Website URL", value: URL(string: "https://www.w3.org/")!)
        let fetchURLButton = ClosureButton(label: "Fetch website") { _ in
            guard let value = urlInput.value else { return }
            URLSession.shared.dataTask(with: value, completionHandler: { (_, response, _) in
                DispatchQueue.main.async {
                    guard let response = response as? HTTPURLResponse else {
                        self.log("Network error")
                        return
                    }
                    self.log("Response status: \(response.statusCode)")
                }
            }).resume()
        }
        
        
        self.stackView.addArrangedSubviews([stringInput,
                                            repetitionsInput,
                                            copyStringButton,
                                            urlInput,
                                            fetchURLButton,
                                            self.outputField
                                            ])
        self.stackView.expand(copyStringButton)
        self.stackView.expand(fetchURLButton)
    }
    
    private func log(_ string: String) {
        self.outputField.value = string
    }
}

extension NSStackView {
    
    /// Adds all views as arranged subviews
    func addArrangedSubviews(_ views: [NSView]) {
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
    
    /// Expands the given view to match the stackview width (if vertical stack) 
    /// or height (if horizontal stack). If the view is not already part of the stack, 
    /// adds it to the stack.
    /// - parameter doNotAdd: do not add the subview if not already part of the stack. 
    ///   This will cause autolayout issue if the subview is not already part of the stack, 
    ///   but will speed up the method if the stack contains a lot of views already
    func expand(_ view: NSView, padding: CGFloat = 0.0, doNotAdd: Bool = false) {
        if !self.arrangedSubviews.contains(view) {
            self.addArrangedSubview(view)
        }
        
        constrain(self, view) { stack, view in
            switch self.orientation {
            case .vertical:
                view.leading == stack.leading + padding
                view.trailing == stack.trailing - padding
            case .horizontal:
                view.top == stack.top - padding
                view.bottom == stack.bottom + padding
            }
        }
    }
}
