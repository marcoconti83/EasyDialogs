# EasyDialogs

_EasyDialogs_ simplifies the task of programmatically creating forms and input dialogs on _macOS_.

The focus is on ease of use for the developer rather than customization or beautiful controls. As such, the intended use is for the quick creation of internal tools rather than consumer applications. But don't let me stop you if that's your goal :-)

This library provides input dialogs for text, numbers, dropdown, multiple selection and more. All controls are intended to be created programmatically, i.e. without using interface builder.


## Example

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

## Documentation
Documentation can be found in the [docs](docs) folder.

