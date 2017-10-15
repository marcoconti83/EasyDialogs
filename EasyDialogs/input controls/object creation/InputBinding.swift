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

/// An object that can be initialized with no parameters
public protocol EmptyInit {
    init()
}

/// A generic binding for an object. This allow for declaring bindings on
/// an object without having to specify what is bound to what, but just say
/// that such binding exists. This is needed to reference to a list of bound properties
/// that are not uniform on the property type.
public protocol ObjectInputBinding {
    
    associatedtype Object
    
    /// Write some value to the object
    func write(on object: inout Object) throws
    
    /// Read some value to the object
    func read(from object: Object?)
    
    var input: InputView { get }
}

/// Type-erasure for ObjectInputBinding
public class AnyObjectInputBinding<Object> {
    
    private let _writeOn: (_ object: inout Object) throws -> ()
    private let _readFrom: (_ object: Object?) -> ()
    public let input: InputView
    
    init<Binding: ObjectInputBinding>(_ binding: Binding) where Binding.Object == Object {
        _writeOn = binding.write
        _readFrom = binding.read
        input = binding.input
    }
    
    func write(on object: inout Object) throws {
        try self._writeOn(&object)
    }
    
    func read(from object: Object?) {
        self._readFrom(object)
    }
}

/// A value that was supposed to be not-nil can not be extracted from the input
struct UnexpectedNilValueError: Error {
    let propertyName: String
}

/// This is a binding between a property of an object and the input view that
/// is used to input that property
public struct PropertyInputBinding<Object, PropertyType, Input: InputViewForValue & InputView>: ObjectInputBinding
    where Input.InputValue == PropertyType
{
    
    let propertyReference: WritableKeyPath<Object, PropertyType>
    public let typedInput: Input
    
    public var input: InputView {
        return self.typedInput
    }
    
    public init(
        _ reference: WritableKeyPath<Object, PropertyType>,
        _ input: Input)
    {
        self.propertyReference = reference
        self.typedInput = input
    }
    
    /// Sets the property on the object based on the input content
    public func write(on object: inout Object) throws {
        guard let value = typedInput.value else { throw UnexpectedNilValueError(propertyName: typedInput.name) }
        object[keyPath: propertyReference] = value
    }
    
    /// Sets the input value based on the property content
    public func read(from object: Object?) {
        typedInput.value = object?[keyPath: propertyReference]
    }
    
    /// Return a generic input binding
    public var any: AnyObjectInputBinding<Object> {
        return AnyObjectInputBinding(self)
    }
}

/// This is a binding between an optional property of an object and the input view that
/// is used to input that property
public struct OptionalPropertyInputBinding<Object, PropertyType, Input: InputViewForValue & InputView>: ObjectInputBinding
    where Input.InputValue == PropertyType
{
    public let object: Object
    public let typedInput: Input
    public var input: InputView {
        return self.typedInput
    }
    
    let propertyReference: WritableKeyPath<Object, PropertyType?>
    
    /// Sets the property on the object based on the input content
    public func write(on object: inout Object) throws {
        object[keyPath: propertyReference] = typedInput.value
    }
    
    /// Sets the input value based on the property content
    public func read(from object: Object?) {
        typedInput.value = object?[keyPath: propertyReference]
    }
    
    /// Return a generic input binding
    public var any: AnyObjectInputBinding<Object> {
        return AnyObjectInputBinding(self)
    }
}

/// A collection of bindings creation closures
public struct BindingsFactory<Object> {
    
    public init(_ bindings: ()->(AnyObjectInputBinding<Object>) ...) {
        self.bindings = bindings
    }
    
    public let bindings: [()->(AnyObjectInputBinding<Object>)]
}
