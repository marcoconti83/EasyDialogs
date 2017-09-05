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

/// An object capable of validating input
public protocol InputValidation {
    
    associatedtype ValidationValue
    
    func validate(_ value: ValidationValue?) -> Bool
}

/// Common validation types
public struct Validation {
    
    public struct NotNil<Value>: InputValidation {
        
        public typealias ValidationValue = Value
        
        public func validate(_ value: Value?) -> Bool {
            return value != nil
        }
        
        public init() {}
    }
    
    public struct NotEmptyString: InputValidation {
        
        public typealias ValidationValue = String
        
        public func validate(_ value: String?) -> Bool {
            return value != nil && !value!.isEmpty
        }
        
        public init() {}
    }
    
    public struct NotEmptySequence<S: Collection>: InputValidation {
        
        public typealias ValidationValue = S
        
        public func validate(_ value: S?) -> Bool {
            return value != nil && !value!.isEmpty
        }
        
        public init() {}
    }
    
    public struct Custom<Value>: InputValidation {
        
        public typealias ValidationValue = Value
        
        let block: (Value?)->Bool
        
        public init(_ block: @escaping (Value?)->Bool) {
            self.block = block
        }
        
        public func validate(_ value: Value?) -> Bool {
            return self.block(value)
        }
    }
}

/// Type-erased input validation
public class AnyInputValidation<V>: InputValidation {
    
    public typealias ValidationValue = V

    private let _validate: (V?) -> Bool
    
    public init<U: InputValidation>(_ validation: U) where U.ValidationValue == V {
        self._validate = validation.validate
    }
    
    public func validate(_ value: V?) -> Bool {
        return _validate(value)
    }
}

extension InputValidation {
    
    /// type erased self
    public var any: AnyInputValidation<ValidationValue> {
        return AnyInputValidation(self)
    }
}
