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

import Foundation
import ClosureControls
import Cartography
import BrightFutures

private let contentViewInternalPadding: CGFloat = 15

extension Bool {
    
    /// Asks a yes/no/cancel question
    public static func askWithCancel(_ message: String,
                       handler: @escaping (InputResponse<Bool>)->())
    {
        ButtonsFormWindow.displayForm(
            headerText: message,
            buttons: [
                ClosureButton(label: "Cancel", closure: { _ in
                    handler(.cancel)
                }),
                ClosureButton(label: "No", closure: { _ in
                    handler(.ok(false))
                }),
                ClosureButton(label: "Yes", closure: { _ in
                    handler(.ok(true))
                })
            ])
    }
    
    /// Asks a yes/no/cancel question
    public static func askWithCancel(_ message: String) -> Future<Bool, AbortedError>
    {
        return Future {
            self.askWithCancel(message, handler: InputFuture.handler($0))
        }
    }
    
    /// Asks a yes/no question
    public static func ask(_ message: String,
                           handler: @escaping (Bool)->())
    {
        ButtonsFormWindow.displayForm(
            headerText: message,
            buttons: [
                ClosureButton(label: "No", closure: { _ in
                    handler(false)
                }),
                ClosureButton(label: "Yes", closure: { _ in
                    handler(true)
                })
            ])
    }
    
    /// Asks a yes/no question
    public static func ask(_ message: String) -> Future<Bool, Error>
    {
        return Future { completion in
            self.ask(message) {
                completion(.success($0))
            }
        }
    }
}

/// A window to ask a yes/no question
private class ButtonsFormWindow: ModalWindow {

    private init (headerText: String,
                  buttons: [ClosureButton])
    {
        super.init()
        self.setupWindow(headerText: headerText, buttons: buttons)
    }
    
    private func setupWindow(headerText: String,
                             buttons: [ClosureButton])
    {
        precondition(!buttons.isEmpty)
        
        let contentView = self.window!.contentView!
        let wrapperView = NSView()
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrapperView)
        constrain(contentView, wrapperView) { content, wrapper in
            wrapper.edges == content.edges
            wrapper.width >= 500
        }
        
        let label = NSTextField.createMultilineLabel(headerText)
        let buttonsView = NSView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(label)
        wrapperView.addSubview(buttonsView)
        
        constrain(label, wrapperView, buttonsView) { label, wrapper, buttons in
            label.top == wrapper.top + contentViewInternalPadding
            label.trailing == wrapper.trailing - contentViewInternalPadding
            label.leading == wrapper.leading + contentViewInternalPadding
            buttons.leading == label.leading
            buttons.trailing == label.trailing
            buttons.top == label.bottom + contentViewInternalPadding
            buttons.bottom == wrapper.bottom - contentViewInternalPadding
        }
        self.setupButtons(buttons, wrapperView: buttonsView)
    }
    
    private func setupButtons(_ buttons: [ClosureButton], wrapperView: NSView) {
        
        var prevButton: ClosureButton? = nil
        buttons.forEach { button in
            
            let closure = button.closure
            button.closure = { [weak self] in
                self?.dismiss()
                closure?($0)
            }
            wrapperView.addSubview(button)
            
            if let prevButton = prevButton {
                constrain(button, prevButton) { button, prevButton in
                    button.top == prevButton.top
                    button.bottom == prevButton.bottom
                    button.right == prevButton.left - contentViewInternalPadding
                    button.width >= button.height
                }
            } else {
                constrain(button, wrapperView) { button, wrapper in
                    button.bottom == wrapper.bottom
                    button.top == wrapper.top
                    button.trailing == wrapper.trailing
                    button.width >= button.height
                }
            }
            prevButton = button
        }
        
        constrain(buttons.last!, wrapperView) { button, wrapper in
            button.leading >= wrapper.leading + contentViewInternalPadding
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Display the window, it won't be dismissed until a
    /// button is pressed. This is achieved by retaining
    /// a reference internally.
    fileprivate static func displayForm(
        headerText: String,
        buttons: [ClosureButton])
    {
        ButtonsFormWindow(
            headerText: headerText,
            buttons: buttons
        ).present()
    }
    

}
