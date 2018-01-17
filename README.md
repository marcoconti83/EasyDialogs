# EasyDialogs

EasyDialogs makes creating forms and input dialogs on macOS simple and concise. 
It provides input dialogs for text, numbers, dropdown and multiple selection.

# Example

![Example](https://user-images.githubusercontent.com/620000/30260589-914d88f0-96c8-11e7-9be3-b23df188d638.png)

To create a modal form window like the one seen in the screenshot, all you need is this code:

```swift        
let nameInput = TextFieldInput<String>(
   label: "Name",
   validationRules: [Validation.NotEmptyString().any]
)
let ageInput = TextFieldInput<Int>(
   label: "Age",
   value: 18,
   validationRules: [Validation.Custom({$0 != nil && $0! >= 0 && $0! < 200}).any]
)
let colorInput = SingleSelectionInput(
   label: "Favorite color",
   values: ["red", "blue", "yellow"]
)
FormWindow.displayForm(
   inputs: [
       nameInput,
       ageInput,
       colorInput
   ],
   headerText: "Please tell me about yourself",
   onConfirm: { _ in
       print("\(nameInput.value!), age \(ageInput.value!), likes \(colorInput.value ?? "no color")")
       return true
})
```
