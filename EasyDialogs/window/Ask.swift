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
import BrightFutures

/// A response to a request for input
public enum InputResponse<T> {
    case cancel
    case ok(T)
    
    public var value: T? {
        switch self {
        case .cancel:
            return nil
        case .ok(let answer):
            return answer
        }
    }
}

extension ValueInput {
    
    /// Display a modal form with this value input
    public func askInForm(message: String,
                          handler: @escaping (InputResponse<VALUE>)->())
    {
        FormWindow.displayForm(
            inputs: [self],
            headerText: message,
            validateValue: { self.value },
            onConfirm: { handler(.ok($0)) },
            onCancel: { handler(.cancel) }
        )
    }
    
    /// Display a modal form with this value input. Returns a future.
    public func askInForm(message: String) -> Future<VALUE, AbortedError> {
        return Future { completion in
            self.askInForm(
                message: message,
                handler: InputFuture.handler(completion))
        }
    }
}
