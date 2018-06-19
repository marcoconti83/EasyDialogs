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
        
        self.setupWindow(headerText: headerText,
                         confirmButtonText: confirmButtonText)
    }
    
    /// Display the window, it won't be dismissed until the
    /// close button is used
    public static func displayForm(
        inputs: [InputView],
        headerText: String? = nil,
        confirmButtonText: String = "OK",
        validateValue: @escaping ()->(ResultValue?),
        onConfirm: @escaping (ResultValue)->(),
        onCancel: (()->())? = nil
        )
    {
        FormWindow(
            inputs: inputs,
            headerText: headerText,
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
        confirmButtonText: String = "OK",
        validateValue: @escaping ()->(ResultValue?)
        ) -> Future<ResultValue, AbortedError>
    {
        return Future { completion in
            self.displayForm(
                inputs: inputs,
                headerText: headerText,
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
    
    @objc public func cancel(_ sender: Any?) {
        self.cancelButtonPressed()
    }
}

// MARK: - Form setup
extension FormWindow {
    
    /// Creates controls and layout
    fileprivate func setupWindow(
        headerText: String?,
        confirmButtonText: String
        ) {
        
        let contentView = self.window!.contentView!
        let wrapperView = NSView()
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrapperView)
        constrain(contentView, wrapperView) { content, wrapper in
            wrapper.edges == content.edges
            wrapper.width >= 500
        }
        
        let header = self.createHeader(headerText: headerText)
        let footer = self.createFooter(confirmButtonText: confirmButtonText)
        let stack = self.createStackView()
        stack.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        [header, stack, footer].forEach { wrapperView.addSubview($0) }
        constrain(header, footer, stack, wrapperView) { header, footer, stack, wrapperView in
            header.left == wrapperView.left + contentViewInternalPadding
            header.right == wrapperView.right - contentViewInternalPadding
            header.width == footer.width
            header.width == stack.width
            header.top == wrapperView.top
            stack.top == header.bottom
            stack.left == header.left
            footer.left == header.left
            stack.bottom == footer.top
            footer.bottom == wrapperView.bottom
        }
    }
    
    private func createStackView() -> NSView {
        
        let stack = NSStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.orientation = .vertical
        stack.spacing = 1
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.documentView = stack
        scroll.drawsBackground = false
        scroll.borderType = .noBorder
        scroll.autohidesScrollers = true
        scroll.allowsMagnification = false
        scroll.verticalScrollElasticity = .none
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        
        constrain(scroll, stack) { scroll, stack in
            stack.top == scroll.top
            stack.left == scroll.left
            stack.right == scroll.right
            stack.width == scroll.width
            scroll.height <= stack.height ~ NSLayoutConstraint.Priority.defaultHigh.rawValue
            scroll.height >= 300
        }
        stack.addArrangedSubviewsAndExpand(self.inputs)
        return scroll
    }
    
    
    private func createHeader(headerText: String?) -> NSView {
        
        let header = NSView()
        header.translatesAutoresizingMaskIntoConstraints = false
        if let headerText = headerText {
            let label = NSTextField.createMultilineLabel(headerText)
            label.translatesAutoresizingMaskIntoConstraints = false
            header.addSubview(label)
            constrain(header, label) { header, label in
                label.top == header.top + contentViewInternalPadding
                label.bottom == header.bottom - contentViewInternalPadding
            }
        }
        header.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return header
    }
    
    private func createFooter(confirmButtonText: String) -> NSView {
        
        let OKButton = ClosureButton(label: confirmButtonText) { [weak self] _ in
            self?.confirmButtonPressed()
        }
        let cancelButton = ClosureButton(label: "Cancel") { [weak self] _ in
            self?.cancelButtonPressed()
        }
        OKButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        let errorLabel = NSTextField.createLabel()
        errorLabel.isHidden = true
        errorLabel.textColor = NSColor.red
        errorLabel.backgroundColor = NSColor.white
        errorLabel.drawsBackground = true
        
        self.errorLabel = errorLabel
        
        let footer = NSView()
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.addSubview(OKButton)
        footer.addSubview(cancelButton)
        footer.addSubview(errorLabel)
        
        constrain(OKButton, footer, errorLabel) { button, footer, error in
            button.bottom == footer.bottom - contentViewInternalPadding
            button.trailing == footer.trailing - contentViewInternalPadding
            error.trailing == footer.trailing
            error.leading == footer.leading
            error.top == footer.top + contentViewInternalPadding
            error.bottom == button.top - contentViewInternalPadding
        }
        
        constrain(OKButton, cancelButton, footer) { OKButton, cancelButton, footer in
            cancelButton.leading == footer.leading
            cancelButton.top == OKButton.top
            cancelButton.bottom == OKButton.bottom
            OKButton.width >= 100
            cancelButton.width >= 100
        }
        footer.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return footer
    }
}
