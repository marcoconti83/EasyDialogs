//
//  InputFuture.swift
//  EasyDialogs
//
//  Created by Marco Conti on 22.02.18.
//  Copyright © 2018 com.marco83. All rights reserved.
//

import Foundation
import BrightFutures
import Result

public struct AbortedError: Error {}

struct InputFuture {
    
    /// Returns a handler that will invoke the resolver of a future
    static func handler<T>(_ resolver: @escaping (Result<T, AbortedError>) -> Void)
        -> (InputResponse<T>)->()
    {
        return { response in
            switch response {
            case .ok(let value):
                resolver(.success(value))
            case .cancel:
                resolver(.failure(AbortedError()))
            }
        }
    }
}
