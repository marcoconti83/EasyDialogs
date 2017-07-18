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
         
        self.createURLSection()
        self.createStringSection()
        self.createTextSection()
        self.stackView.addArrangedSubviewsAndExpand([self.outputField])
    }
    
    fileprivate func log(_ string: String) {
        self.outputField.value = string
    }
    
}

extension ViewController {
    
    fileprivate func createStringSection() {
        
        let stringInput = TextFieldInput<String>(label: "Input string", value: "foo")
        let repetitionsInput = TextFieldInput<Int>(label: "Repetitions", value: 2, validation: {
            $0 != nil && $0! >= 0 && $0! < 100
        })
        let copyStringButton = ClosureButton(label: "Copy value") { _ in
            guard let repetitions = repetitionsInput.value else {
                self.log("ERROR: Repetitions is not a valid number")
                return
            }
            self.log(String.init(repeating: stringInput.value ?? "", count: repetitions))
        }
        self.stackView.addArrangedSubviewsAndExpand([stringInput,
                                            repetitionsInput,
                                            copyStringButton,
            ])
    }
    
    fileprivate func createURLSection() {
        
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
        self.stackView.addArrangedSubviewsAndExpand([urlInput, fetchURLButton])
    }
    
    fileprivate func createTextSection() {
        let textInput = TextViewInput(label: "Text", value: "All human beings are born free and equal in dignity and rights.")
        let analysisTypeInput = SelectionInput(label: "What to count",
                                               values: LengthAnalysis.all,
                                               selectedValue: .numberOfCharacters)
        
        let analyzeButton = ClosureButton(label: "Analyze text") { _ in
            guard let string = textInput.value else { return }
            guard let analysis = analysisTypeInput.value else { return }
            let count = analysis.perform(on: string)
            self.log("Text is \(count) \(analysis.rawValue)(s) long")
        }
        self.stackView.addArrangedSubviewsAndExpand([
            textInput,
            analysisTypeInput,
            analyzeButton,
        ])
    }
}

extension NSStackView {
    
    /// Adds all views as arranged subviews. 
    /// Expands the given view to match the stackview width (if vertical stack)
    /// or height (if horizontal stack).
    func addArrangedSubviewsAndExpand(_ views: [NSView]) {
        views.forEach {
            self.addArrangedSubview($0)
            self.expand($0)
        }
    }
    
    /// Expands the given view to match the stackview width (if vertical stack) 
    /// or height (if horizontal stack).
    private func expand(_ view: NSView, padding: CGFloat = 0.0) {
        
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


enum LengthAnalysis: String, CustomStringConvertible {
    case numberOfCharacters = "characters"
    case numberOfWords = "words"
    case numberOfLines = "lines"
    
    func perform(on text: String) -> Int {
        switch self {
        case .numberOfLines:
            return text.components(separatedBy: "\n").count
        case .numberOfWords:
            return text.components(separatedBy: CharacterSet.whitespacesAndNewlines).count
        case .numberOfCharacters:
            return text.characters.count
        }
    }
 
    var description: String {
        return self.rawValue
    }
    
    static let all: [LengthAnalysis] = [.numberOfCharacters, .numberOfWords, .numberOfLines]
}
