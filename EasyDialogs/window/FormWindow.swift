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

/// A window that contains input fields
public class FormWindow: ModalWindow {
    
    static let contentViewInternalPadding: CGFloat = 15

    /// Inputs to be displayed in the form
    let inputs: [InputView]
    
    /// Error display
    fileprivate var errorLabel: NSTextField! = nil
    
    /// Closure to invoke when the user press the confirm button
    private let onConfirm: ()->(Bool)
    
    /// Closure invoked when the user cancels the form
    private let onCancel: (()->())?
    
    /// Creates a window with input controls
    /// - parameter onConfirm: invoked when the confirm button is pressed. If it returns true, the window is dismissed
    private init(
        inputs: [InputView],
        headerText: String?,
        minFormHeight: CGFloat,
        confirmButtonText: String,
        onConfirm: @escaping ()->(Bool),
        onCancel: (()->())?
    )
    {
        self.onConfirm = onConfirm
        self.inputs = inputs
        self.onCancel = onCancel
        super.init()
        
        self.setupWindow(minFormHeight: minFormHeight,
                         headerText: headerText,
                         confirmButtonText: confirmButtonText)
    }
    
    /// Display the window, it won't be dismissed until the
    /// close button is used. This is achieved by retaining 
    /// a reference internally.
    public static func displayForm(
        inputs: [InputView],
        headerText: String? = nil,
        minFormHeight: CGFloat = 200,
        confirmButtonText: String = "OK",
        onConfirm: @escaping ()->(Bool),
        onCancel: (()->())? = nil
        )
    {
        FormWindow(
            inputs: inputs,
            headerText: headerText,
            minFormHeight: minFormHeight,
            confirmButtonText: confirmButtonText,
            onConfirm: onConfirm,
            onCancel: onCancel
        ).present()
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
        guard self.onConfirm() else { return }
        self.dismiss()
    }
    
    fileprivate func cancelButtonPressed() {
        self.onCancel?()
        self.dismiss()
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
            scroll.trailing == container.trailing - FormWindow.contentViewInternalPadding
            scroll.leading == container.leading + FormWindow.contentViewInternalPadding
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
                label.top == container.top + FormWindow.contentViewInternalPadding
                label.bottom == stack.top - FormWindow.contentViewInternalPadding
                label.trailing == stack.trailing
                label.leading == stack.leading
            }
        } else {
            constrain(stack, container) { stack, container in
                stack.top == container.top + FormWindow.contentViewInternalPadding
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
            button.bottom == container.bottom - FormWindow.contentViewInternalPadding
            button.trailing == container.trailing - FormWindow.contentViewInternalPadding
            error.trailing == container.trailing - FormWindow.contentViewInternalPadding
            error.leading == container.leading + FormWindow.contentViewInternalPadding
            stack.bottom == error.top - FormWindow.contentViewInternalPadding
            error.bottom == button.top - FormWindow.contentViewInternalPadding
        }
        
        constrain(OKButton, cancelButton, container) { OKButton, cancelButton, container in
            cancelButton.leading == container.leading + FormWindow.contentViewInternalPadding
            cancelButton.top == OKButton.top
            cancelButton.bottom == OKButton.bottom
            OKButton.width >= 100
            cancelButton.width >= 100
            OKButton.height >= 30
        }
    }
}
