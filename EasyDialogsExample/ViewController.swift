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
import EasyTables
import BrightFutures

class ViewController: NSViewController {

    private var outputField: NSTextField!
    @IBOutlet weak var stackView: NSStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.outputField = NSTextField.createLabel()
         
        self.createURLSection()
        self.createStringSection()
        self.createTextSection()
        self.createIngredientsSection()
        let externalButton = ClosureButton(label: "External dialog") { [weak self] _ in
            self?.openInputWindow()
        }
        let simpleInput = ClosureButton(label: "Simple value input") { [weak self] _ in
            self?.simpleInput()
        }
        let randomInput = CustomEditorInput<UInt32>.init(
            label: "Randomizer",
            value: nil,
            editor:  { _, _ in Future(value: arc4random()) })
        
        self.stackView.addArrangedSubviewsAndExpand([
            externalButton,
            simpleInput,
            randomInput,
            self.outputField])
    }
    
    fileprivate func log(_ string: String) {
        self.outputField.stringValue = string
    }
}

extension ViewController {
    
    fileprivate func createStringSection() {
        let passwordInput = TextFieldInput<String>(label: "Secret token", value: "password", secure: true)
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
                                            passwordInput
            ])
    }
    
    fileprivate func createURLSection() {
        let urlInput = TextFieldInput<URL>(label: "Website URL", value: URL(string: "https://www.w3.org/")!)
        let printSourceInput = CheckBoxInput(label: "Print source", value: true)
        let fetchURLButton = ClosureButton(label: "Fetch website") { _ in
            guard let value = urlInput.value else { return }
            let printSource = printSourceInput.value!
            let progress = ProgressDialog.showProgress(
                message: "Fetching website...",
                doneMessage: "Done fetching!",
                window: self.view.window!,
                autoDismissWhenDone: false)
            URLSession.shared.dataTask(with: value, completionHandler: { (data, response, _) in
                progress.appendLog("Fetching \(value)...", style: .info)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { // artificial delay
                    guard let response = response as? HTTPURLResponse else {
                        progress.appendLog("Network error", style: .error)
                        progress.done()
                        return
                    }
                    progress.appendLog("Response status: \(response.statusCode)", style: .done)
                    if printSource, let data = data, let source = String(data: data, encoding: .utf8) {
                        progress.appendLog(source, style: .info)
                    }
                    progress.done()
                }
            }).resume()
        }
        self.stackView.addArrangedSubviewsAndExpand([urlInput, printSourceInput, fetchURLButton])
    }
    
    fileprivate func createTextSection() {
        let textInput = TextViewInput(
            label: "Text",
            value: "All human beings are born free and equal in dignity and rights.")
        let analysisTypeInput = SingleSelectionInput(
            label: "What to count",
            values: LengthAnalysis.all,
            allowEmpty: false)
        
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
    
    fileprivate func createIngredientsSection() {
        
        let inventoryInput = ObjectListInput<Ingredient>(
            label: "Ingredients",
            initialValues: [
                Ingredient(name: "Pasta", amount: 300, unit: .grams),
                Ingredient(name: "Tomatoes", amount: 4, unit: .pieces),
                Ingredient(name: "Olive oil", amount: 4, unit: .teaspoons),
                Ingredient(name: "Garlic", amount: 1, unit:.pieces)
            ],
            possibleObjects: [
                Ingredient(name: "Salt", amount: 1, unit: .teaspoons),
                Ingredient(name: "Pepper", amount: 1, unit: .teaspoons),
            ],
            objectCreation: Ingredient.bindings.formWindowForCreationClosure(),
            objectEdit: Ingredient.bindings.formWindowForEditClosure(),
            columns: [
                ColumnDefinition(name: "Name", value: { $0.name }),
                ColumnDefinition(name: "Amount", value: { "\($0.amount) \($0.unit)" })
            ]
        )
        self.stackView.addArrangedSubviewsAndExpand([inventoryInput])
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
        FormWindow<(colors: String, name: String, age: Int)>.displayForm(
            inputs: [
                nameInput,
                ageInput,
                colorInput
            ],
            headerText: "Please tell me about yourself",
            validateValue: {
                let colors = colorInput.value!.isEmpty ?
                    "no color" :
                    colorInput.value!.joined(separator: ", ")
                guard let name = nameInput.value else { return nil }
                guard let age = ageInput.value else { return nil }
                return (colors: colors, name: name, age: age)
            },
            onConfirm: { 
                self.log("\($0.name), age \($0.age), likes \($0.colors)")
        })
        
    }
    
    fileprivate func simpleInput() {
        ["Tomato","Ceddar","Onion"].askMultipleAnswers("Choose topping") {
            guard case .ok(let answer) = $0 else { return }
            self.log("Topping: \(answer)")
        }
    }
}

/// A recipe ingredient
struct Ingredient: EmptyInit, Equatable {
    
    var name: String = ""
    var amount: UInt = 0
    var unit: UnitOfMeasure = .grams
    
    init() {}
    
    init(name: String, amount: UInt, unit: UnitOfMeasure) {
        self.name = name
        self.amount = amount
        self.unit = unit
    }
    
    enum UnitOfMeasure: String {
        case pieces
        case cups
        case teaspoons
        case grams
        
        static var all: [UnitOfMeasure] {
            return [.pieces, .cups, .teaspoons, .grams]
        }
    }
    
    static func ==(lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.name == rhs.name && lhs.amount == rhs.amount && lhs.unit == rhs.unit
    }
    
    static var bindings: BindingsFactory<Ingredient> {
       return BindingsFactory<Ingredient>(
        { PropertyInputBinding(\Ingredient.name,
                               TextFieldInput<String>(label: "Name")).any },
        { PropertyInputBinding(\Ingredient.amount,
                               TextFieldInput<UInt>(label: "Amount")).any },
        { PropertyInputBinding(\Ingredient.unit,
                                 SingleSelectionInput(label: "Unit of measure",
                                                      values: Ingredient.UnitOfMeasure.all,
                                                      valueToDisplay: { $0.rawValue })).any }
        )
    }
}

/// Analysis of a text
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
            return text.count
        }
    }
 
    var description: String {
        return self.rawValue
    }
    
    static let all: [LengthAnalysis] = [.numberOfCharacters, .numberOfWords, .numberOfLines]
}

extension String: EmptyInit {}
