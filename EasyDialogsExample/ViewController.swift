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
import EasyDialogs
import Cartography
import ClosureControls

class ViewController: NSViewController {

    private var outputField: NSTextField!

    
    @IBOutlet weak var stackView: NSStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.outputField = NSTextField.createLabel()
         
        self.createURLSection()
        self.createStringSection()
        self.createTextSection()
        let externalButton = ClosureButton(label: "External dialog") { [weak self] _ in
            self?.openInputWindow()
        }
        let simpleInput = ClosureButton(label: "Simple value input") { [weak self] _ in
            self?.simpleInput()
        }
        
        self.stackView.addArrangedSubviewsAndExpand([externalButton, simpleInput, self.outputField])
    }
    
    fileprivate func log(_ string: String) {
        self.outputField.stringValue = string
    }
    
}

extension ViewController {
    
    fileprivate func createStringSection() {
        
        let stringInput = TextFieldInput<String>(label: "Input string", value: "foo")
        let repetitionsInput = TextFieldInput<Int>(
            label: "Repetitions",
            value: 2,
            validationRules: [
                Validation.Custom({$0 != nil && $0! >= 0 && $0! < 100}).any
            ]
        )
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
            self.log("Fetching \(value)...")
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
        let textInput = TextViewInput(
            label: "Text",
            value: "All human beings are born free and equal in dignity and rights.")
        let analysisTypeInput = SingleSelectionInput(
            label: "What to count",
            values: LengthAnalysis.all,
            value: .numberOfCharacters)
        
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
    
    fileprivate func openInputWindow() {
        
        let nameInput = TextFieldInput<String>(
            label: "Name",
            validationRules: [Validation.NotEmptyString().any]
        )
        let ageInput = TextFieldInput<Int>(
            label: "Age",
            value: 18,
            validationRules: [Validation.Custom({$0 != nil && $0! >= 0 && $0! < 200}).any]
        )
        let colorInput = MultipleSelectionInput(
            label: "Favorite color",
            possibleValues: ["red", "blue", "yellow"]
        )
        FormWindow.displayForm(
            inputs: [
                nameInput,
                ageInput,
                colorInput
            ],
            headerText: "Please tell me about yourself",
            onConfirm: { _ in
                let colors = colorInput.value!.isEmpty ? "no color" : colorInput.value!.joined(separator: ", ")
                self.log("\(nameInput.value!), age \(ageInput.value!), likes \(colors)")
                return true
        })
        
    }
    
    fileprivate func simpleInput() {
        
        ["Tomato","Ceddar","Onion"].askMultipleAnswers("Choose topping") {
            guard case .ok(let answer) = $0 else { return }
            self.log("Topping: \(answer)")
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

