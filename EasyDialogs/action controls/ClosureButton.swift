//
//  ActionButton.swift
//  EasyDialogs
//
//  Created by Marco Conti on 18.07.17.
//  Copyright © 2017 com.marco83. All rights reserved.
//

import Foundation

public class ClosureButton: NSButton {
    
    public var closure: ((Any)->())? = nil
    
    public init(label: String? = nil, closure: ((Any)->())?) {
        super.init(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
        self.closure = closure
        if let label = label {
            self.title = label
        }
        self.linkActionToButton()
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.linkActionToButton()
    }
        
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    func executeClosure(_ sender: Any) {
        self.closure?(sender)
    }
    
    private func linkActionToButton() {
        self.target = self // `target` holds a weak reference
        self.action = #selector(executeClosure(_:))
    }
}
