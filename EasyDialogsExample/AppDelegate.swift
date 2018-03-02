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
import ClosureControls
import Cartography

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        func showSampleForm(numberOfControls: Int) {
            FormWindow.displayForm(
                inputs: (1...numberOfControls).map {
                    TextFieldInput<String>(label: "Text \($0)")
                },
                headerText: "This form has \(numberOfControls) controls",
                validateValue: { true }
                ).onSuccess { _ in }
        }
        
        let window = NSWindow()
        let view = NSView()
        let buttonLarge = ClosureButton(
            label: "Open large form",
            closure: { _ in showSampleForm(numberOfControls: 100) }
        )
        let buttonSmall = ClosureButton(
            label: "Open small form",
            closure: { _ in showSampleForm(numberOfControls: 3) }
        )
        view.addSubview(buttonLarge)
        view.addSubview(buttonSmall)
        constrain(view, buttonLarge, buttonSmall) { view, b1, b2 in
            b1.top == view.top
            b1.left == view.left
            b1.right == view.right
            b1.bottom == b2.top
            b2.left == view.left
            b2.right == view.right
            b2.bottom == view.bottom
            b2.height == b1.height
            view.width == 400
            view.height == 400
        }
        window.contentView = view
        window.makeKeyAndOrderFront(self)
        window.center()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}


