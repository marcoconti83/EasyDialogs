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

extension Sequence where Self.Iterator.Element: Equatable {
    
    /// Asks to choose one or more values from the collection
    public func ask(_ message: String,
                       initialValue: Self.Iterator.Element? = nil,
                       valueToDisplay: ((Self.Iterator.Element)->Any)? = nil,
                       handler: @escaping (InputResponse<Self.Iterator.Element>)->())
    {
        let array = Array(self)
        SingleSelectionInput(label: nil,
                             values: array,
                             valueToDisplay: valueToDisplay,
                             value: initialValue ?? array.first)
            .askInForm(message: message, handler: handler)
    }
    
    /// Asks to choose one or more values from the collection
    public func ask(_ message: String,
                    initialValue: Self.Iterator.Element? = nil,
                    valueToDisplay: ((Self.Iterator.Element)->Any)? = nil)
        -> Future<Self.Iterator.Element, AbortedError>
    {
        return Future {
            self.ask(
                message,
                initialValue: initialValue,
                valueToDisplay: valueToDisplay,
                handler: InputFuture.handler($0)
            )
        }
    }

    /// Asks to choose one or more values from the collection
    public func askMultipleAnswers(_ message: String,
                    initialValue: [Self.Iterator.Element] = [],
                    valueToDisplay: ((Self.Iterator.Element)->Any)? = nil,
                    handler: @escaping (InputResponse<[Self.Iterator.Element]>)->())
    {
        MultipleSelectionInput(label: nil,
                               possibleValues: Array(self),
                               valueToDisplay: valueToDisplay,
                               selectedValues: initialValue)
            .askInForm(message: message, handler: handler)
    }
    
    /// Asks to choose one or more values from the collection
    public func askMultipleAnswers(_ message: String,
                                   initialValue: [Self.Iterator.Element] = [],
                                   valueToDisplay: ((Self.Iterator.Element)->Any)? = nil)
        -> Future<[Self.Iterator.Element], AbortedError>
    {
        return Future {
            self.askMultipleAnswers(
                message,
                initialValue: initialValue,
                valueToDisplay: valueToDisplay,
                handler: InputFuture.handler($0)
            )
        }
    }
}
