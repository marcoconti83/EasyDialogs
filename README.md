# EasyDialogs

EasyDialogs makes creating forms and input dialogs on macOS simple and concise. 
It provides input dialogs for text, numbers, dropdown and multiple selection.

# Example

![Example](https://user-images.githubusercontent.com/620000/30096810-c515d080-92da-11e7-8bee-fd0bfffd83f3.png)

To create a modal form window like the one seen in the screenshot, all you need is this code:

```
   func openInputWindow() {
        
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
    }
```
