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

public class ModalWindow: NSWindowController {
    
    /// Holding self reference to make window peristent until dismissed
    fileprivate var selfReference: ModalWindow? = nil
    
    public init() {
        let window = ModalWindow.createWindow()
        super.init(window: window)
        self.selfReference = self
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ModalWindow {

    /// Dismiss the window
    func dismiss() {
        NSApp.stopModal()
        self.window!.orderOut(self)
        self.selfReference = nil // this will release the last reference
    }
    
    func present() {
        self.showWindow(nil)
        NSApp.runModal(for: self.window!)
    }
    
    /// Creates the window
    static func createWindow() -> NSWindow {
        let window = NSWindow()
        window.center()
        window.styleMask = [
            NSWindow.StyleMask.titled,
            NSWindow.StyleMask.resizable
        ]
        return window
    }
}
