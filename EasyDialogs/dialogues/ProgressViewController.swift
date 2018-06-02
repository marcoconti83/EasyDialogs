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

class ProgressViewController: NSViewController, ProgressMonitor {
    
    @IBOutlet weak var messageTextView: NSTextField!
    @IBOutlet weak var buttonAbort: NSButton!
    @IBOutlet weak var buttonDismiss: NSButton!
    @IBOutlet weak var dummyIndicator: NSProgressIndicator!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var indicator: NSProgressIndicator!
    let uuid = UUID()
    
    private var dismissed = false
    
    @IBOutlet weak var textScrollViewHeightConstraint: NSLayoutConstraint!
    private var cancelCallback: (()->())?
    private var message: String
    var autoDismissWhenDone: Bool {
        didSet {
            if self.autoDismissWhenDone && self.isDone {
                dismiss()
            }
        }
    }
    private var doneMessage: String?
    
    private var isDone: Bool {
        didSet {
            if self.isDone {
                if let doneMessage = self.doneMessage {
                    self.messageTextView.stringValue = doneMessage
                }
                self.indicator.maxValue = 1
                self.indicator.doubleValue = 1
                self.indicator.isHidden = true
                self.buttonAbort.isHidden = true
                self.dummyIndicator.isHidden = true
                if self.autoDismissWhenDone {
                    self.dismiss()
                } else {
                    self.buttonDismiss.isHidden = false
                    self.buttonDismiss.isEnabled = true
                }
            }
        }
    }
    
    init(message: String,
         doneMessage: String?,
         autoDismissWhenDone: Bool,
         cancelCallback: (()->())?)
    {
        self.doneMessage = doneMessage
        self.cancelCallback = cancelCallback
        self.message = message
        self.autoDismissWhenDone = autoDismissWhenDone
        self.isDone = false
        super.init(nibName: nil, bundle: Bundle.init(for: ProgressViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTextView.stringValue = self.message
        self.buttonAbort.isEnabled = self.cancelCallback != nil
        self.buttonDismiss.isEnabled = false
        self.buttonDismiss.isHidden = true
        self.indicator.isIndeterminate = true
        self.indicator.startAnimation(nil)
        self.dummyIndicator.startAnimation(nil)
    }
    
    @IBAction func didAbort(_ sender: Any) {
        self.cancelCallback?()
        self.dismiss()
    }
    @IBAction func didDismiss(_ sender: Any) {
        self.dismiss()
    }
    
    private func dismiss() {
        self.dismissed = true
        guard let window = self.view.window else { return }
        window.sheetParent?.endSheet(window)
    }
    
    func updateProgress(current: Double, total: Double) {
        guard !self.dismissed else { return }
        DispatchQueue.main.async {
            self.indicator.isHidden = false
            self.indicator.startAnimation(nil)
            self.indicator.isIndeterminate = false
            self.indicator.maxValue = total
            self.indicator.doubleValue = current
        }
    }
    
    func updateProgress(current: Int, total: Int) {
        self.updateProgress(current: Double(current), total: Double(total))
    }
    
    func appendLog(_ log: NSAttributedString) {
        guard !self.dismissed else { return }
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.25
                self.textScrollViewHeightConstraint.animator().constant = 200
            }, completionHandler: nil)
            self.textView.textStorage?.append(log)
        }
    }
    
    func done() {
        DispatchQueue.main.async {
            self.isDone = true
        }
    }
}

struct WeakBox<T: AnyObject> {
    weak var value: T?
    
    init(value: T) {
        self.value = value
    }
}

public protocol ProgressMonitor: class {
    
    /// Update the progress
    func updateProgress(current: Double, total: Double)
    /// Update the progress
    func updateProgress(current: Int, total: Int)
    /// Append text to the log
    func appendLog(_ log: NSAttributedString)
    /// Mark as completed
    func done()
    /// Autodismiss the dialog when done
    var autoDismissWhenDone: Bool { get set }
}

extension ProgressMonitor {
    
    /// Append text to the log
    public func appendLog(_ log: String, style: LogStyle = .plain, newLine: Bool = true) {
        self.appendLog(style.format(log + (newLine ? "\n" : "")))
    }
    /// Append object to the log
    public func appendLog(describing object: Any, style: LogStyle = .plain, newLine: Bool = true) {
        let string = String(describing: object) + (newLine ? "\n" : "")
        self.appendLog(string, style: style)
    }
}

public enum LogStyle {
    case error
    case progressUpdate
    case info
    case plain
    case done
    
    func format(_ string: String) -> NSAttributedString {
        return self.format(NSAttributedString(string: string))
    }
    
    private func format(_ string: NSAttributedString) -> NSAttributedString {
        let prefix = NSAttributedString(string: self.prefix)
        let attributed = NSMutableAttributedString(attributedString: prefix)
        attributed.append(self.formatFont(in: string))
        return attributed
    }
    
    private var prefix: String {
        switch self {
        case .progressUpdate:
            return "➡️ "
        case .error:
            return "⚠️ "
        case .done:
            return "✅ "
        default:
            return ""
        }
    }
    
    private func formatFont(in string: NSAttributedString) -> NSAttributedString {
        guard self == .info else {
            return string
        }
        let attributed = NSMutableAttributedString(attributedString: string)
        attributed.addAttribute(NSAttributedStringKey.foregroundColor, value: NSColor.lightGray, range: NSRange(location: 0, length: attributed.length))
        return attributed
    }
}

public struct ProgressDialog {
    
    /**
     Shows a progress dialog as a sheet in the given window. This method immediately
     returns a `ProgressMonitor`, which can be used to update the progress dialog.
     
     Updates to the progress dialog can be invoked from any thread; in fact, it only
     makes sense to use this dialog if the work that generates progress update is run
     on a background thread. Performing that work on the main thread will cause the UI
     not to update until the work is completed.
     
     - parameter message: the message to display in the window
     - parameter doneMessage: the message to display when done, it will replace the initial message
     - parameter window: the window where the sheet should be presented
     - parameter autoDismissWhenDone: if `true`, the sheet will be dismissed as soon
     as the `done` method is invoked on the returned `ProgressMonitor`. If `false`,
     the user needs to click on the "Done" button to dismiss the sheet once the
     work is completed.
     - parameter cancelCallback: if not `nil`, the progress dialog will present an "Abort" button
     that, when clicked, will invoke this callback and dismiss the sheet.
     If this value is `nil`, the button won't be enabled.
     - returns: a `ProgressMonitor` that should be used to update the progress dialog.
     Once the work is completed and the progress dialog dismissed, any reference to
     this should be released.
     
     */
    public static func showProgress(
        message: String = "Operation in progress...",
        doneMessage: String? = nil,
        window: NSWindow,
        autoDismissWhenDone: Bool = false,
        cancelCallback: (()->())? = nil
        ) -> ProgressMonitor
    {
        let controller = ProgressViewController(
            message: message,
            doneMessage: doneMessage,
            autoDismissWhenDone: autoDismissWhenDone,
            cancelCallback: cancelCallback)
        let sheetWindow = NSWindow(contentViewController: controller)
        window.beginSheet(sheetWindow, completionHandler: { _ in })
        return controller
    }
}


