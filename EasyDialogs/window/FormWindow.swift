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
import Cartography
import ClosureControls
import BrightFutures

private let contentViewInternalPadding: CGFloat = 15

/// A window that contains input fields
public class FormWindow<ResultValue>: ModalWindow {
    
    /// Inputs to be displayed in the form
    let inputs: [InputView]
    
    /// Error display
    fileprivate var errorLabel: NSTextField! = nil
    
    /// Called to validate form
    private var validateValue: ()->(ResultValue?)
    
    /// Closure to invoke when the user press the confirm button
    internal(set) var onConfirm: (ResultValue)->()
    
    /// Closure invoked when the user cancels the form
    private let onCancel: (()->())?
    
    /// Creates a window with input controls
    /// - parameter onConfirm: invoked when the confirm button is pressed. If it returns true, the window is dismissed
    init(
        inputs: [InputView],
        headerText: String? = nil,
        minFormHeight: CGFloat = 200,
        confirmButtonText: String = "OK",
        validateValue: @escaping ()->(ResultValue?),
        onConfirm: @escaping (ResultValue)->(),
        onCancel: (()->())? = nil
    )
    {
        self.onConfirm = onConfirm
        self.validateValue = validateValue
        self.inputs = inputs
        self.onCancel = onCancel
        super.init()
        
        self.setupWindow(minFormHeight: minFormHeight,
                         headerText: headerText,
                         confirmButtonText: confirmButtonText)
    }
    
    /// Display the window, it won't be dismissed until the
    /// close button is used
    public static func displayForm(
        inputs: [InputView],
        headerText: String? = nil,
        minFormHeight: CGFloat = 200,
        confirmButtonText: String = "OK",
        validateValue: @escaping ()->(ResultValue?),
        onConfirm: @escaping (ResultValue)->(),
        onCancel: (()->())? = nil
        )
    {
        FormWindow(
            inputs: inputs,
            headerText: headerText,
            minFormHeight: minFormHeight,
            confirmButtonText: confirmButtonText,
            validateValue: validateValue,
            onConfirm: onConfirm,
            onCancel: onCancel
        ).present()
    }
    
    /// Display the window, it won't be dismissed until the
    /// close button is used
    public static func displayForm(
        inputs: [InputView],
        headerText: String? = nil,
        minFormHeight: CGFloat = 200,
        confirmButtonText: String = "OK",
        validateValue: @escaping ()->(ResultValue?)
        ) -> Future<ResultValue, AbortedError>
    {
        return Future { completion in
            self.displayForm(
                inputs: inputs,
                headerText: headerText,
                minFormHeight: minFormHeight,
                confirmButtonText: confirmButtonText,
                validateValue: validateValue,
                onConfirm: { completion(.success($0)) },
                onCancel: { completion(.failure(AbortedError())) }
            )
        }
    }
    
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func confirmButtonPressed() {
        for input in self.inputs {
            if !input.hasValidValue {
                self.showError("Error in field '\(input.name)'")
                return
            }
        }
        guard let value = self.validateValue() else { return }
        self.dismiss()
        self.onConfirm(value)
    }
    
    fileprivate func cancelButtonPressed() {
        self.dismiss()
        self.onCancel?()
    }
    
    private func showError(_ message: String) {
        self.errorLabel.isHidden = false
        self.errorLabel.stringValue = message
    }
}

// MARK: - Form setup
extension FormWindow {
    
    /// Creates controls and layout
    fileprivate func setupWindow(
        minFormHeight: CGFloat,
        headerText: String?,
        confirmButtonText: String
        ) {
        
        let contentView = self.window!.contentView!
        let wrapperView = NSView()
        contentView.addSubview(wrapperView)
        constrain(contentView, wrapperView) { content, wrapper in
            wrapper.edges == content.edges
            wrapper.width >= 500
        }
        
        let stack = self.createStackView(minFormHeight: minFormHeight, in: wrapperView)
        self.createHeaderIfNeeded(headerText: headerText, stack: stack, in: wrapperView)
        self.createButtons(confirmButtonText: confirmButtonText, stack: stack, in: wrapperView)
    }
    
    private func createStackView(minFormHeight: CGFloat, in container: NSView) -> NSView {
        
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 1
        let scroll = NSScrollView.verticalScrollView(for: stack)
        scroll.drawsBackground = false
        scroll.borderType = .noBorder
        
        container.addSubview(scroll)
        constrain(scroll, container) { scroll, container in
            scroll.trailing == container.trailing - contentViewInternalPadding
            scroll.leading == container.leading + contentViewInternalPadding
        }
        
        constrain(scroll, stack) { scroll, stack in
            stack.top == scroll.top
            stack.left == scroll.left
            stack.right == scroll.right
            stack.width == scroll.width
            scroll.height == stack.height
        }
        stack.addArrangedSubviewsAndExpand(self.inputs)

        return scroll
    }
    
    private func createHeaderIfNeeded(headerText: String?, stack: NSView, in container: NSView) {
        
        if let headerText = headerText {
            let label = NSTextField.createMultilineLabel(headerText)
            
            container.addSubview(label)
            constrain(label, stack, container) { label, stack, container in
                label.top == container.top + contentViewInternalPadding
                label.bottom == stack.top - contentViewInternalPadding
                label.trailing == stack.trailing
                label.leading == stack.leading
            }
        } else {
            constrain(stack, container) { stack, container in
                stack.top == container.top + contentViewInternalPadding
            }
        }
    }
    
    private func createButtons(confirmButtonText: String, stack: NSView, in container: NSView) {
        
        let OKButton = ClosureButton(label: confirmButtonText) { [weak self] _ in
            self?.confirmButtonPressed()
        }
        let cancelButton = ClosureButton(label: "Cancel") { [weak self] _ in
            self?.cancelButtonPressed()
        }
        
        let errorLabel = NSTextField.createLabel()
        errorLabel.isHidden = true
        errorLabel.textColor = NSColor.red
        errorLabel.backgroundColor = NSColor.white
        errorLabel.drawsBackground = true
        
        self.errorLabel = errorLabel
        
        container.addSubview(OKButton)
        container.addSubview(cancelButton)
        container.addSubview(errorLabel)
        
        constrain(OKButton, stack, container, errorLabel) { button, stack, container, error in
            button.bottom == container.bottom - contentViewInternalPadding
            button.trailing == container.trailing - contentViewInternalPadding
            error.trailing == container.trailing - contentViewInternalPadding
            error.leading == container.leading + contentViewInternalPadding
            stack.bottom == error.top - contentViewInternalPadding
            error.bottom == button.top - contentViewInternalPadding
        }
        
        constrain(OKButton, cancelButton, container) { OKButton, cancelButton, container in
            cancelButton.leading == container.leading + contentViewInternalPadding
            cancelButton.top == OKButton.top
            cancelButton.bottom == OKButton.bottom
            OKButton.width >= 100
            cancelButton.width >= 100
            OKButton.height >= 30
        }
    }
}
