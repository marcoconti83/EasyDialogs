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
import Cartography

extension NSStackView {
    
    /// Adds all views as arranged subviews.
    /// Expands the given view to match the stackview width (if vertical stack)
    /// or height (if horizontal stack).
    public func addArrangedSubviewsAndExpand(_ views: [NSView]) {
        views.forEach {
            self.addArrangedSubview($0)
            self.expand($0)
        }
    }
    
    /// Expands the given view to match the stackview width (if vertical stack)
    /// or height (if horizontal stack).
    private func expand(_ view: NSView, padding: CGFloat = 0.0) {
        
        constrain(self, view) { stack, view in
            switch self.orientation {
            case .vertical:
                view.leading == stack.leading + padding
                view.trailing == stack.trailing - padding
            case .horizontal:
                view.top == stack.top - padding
                view.bottom == stack.bottom + padding
            @unknown default:
                fatalError()
            }
        }
    }
}
