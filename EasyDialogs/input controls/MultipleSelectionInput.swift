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
import Cartography
import EasyTables

public class MultipleSelectionInput<VALUE: Equatable>: ValueInput<[VALUE], NSScrollView> {
    
    /// The scroll view wrapping an inner table view
    public let scrollView: NSScrollView
    
    /// The inner table view wrapped by a scroll view
    public let tableView: NSTableView
    
    /// Table selection
    private let tableSource: EasyTableSource<VALUE>
    
    public init(label: String? = nil,
                possibleValues: [VALUE],
                valueToDisplay: ((VALUE)->Any)? = nil,
                selectedValues: [VALUE] = [],
                validationRules: [AnyInputValidation<[VALUE]>] = [],
                maxRowsToDisplay: Int? = nil
        )
    {
        let (scroll, table) = NSTableView.inScrollView()
        self.scrollView = scroll

        let valueToDisplay = valueToDisplay ?? { "\($0)" }
        table.headerView = nil
        self.tableView = table
        let tableSource = EasyTableSource(
            initialObjects: possibleValues,
            columns: [
                ColumnDefinition(name: "Value", value: valueToDisplay)
            ],
            contextMenuOperations: [],
            table: table,
            allowMultipleSelection: true,
            selectionCallback: { _ in })
        self.tableSource = tableSource
        let maxRows = min(maxRowsToDisplay ?? possibleValues.count, possibleValues.count)
        let rowHeight = tableSource.table.rowHeight + tableSource.table.intercellSpacing.height
        constrain(scroll) { scroll in
            scroll.height >= CGFloat(maxRows) * rowHeight
        }
        
        super.init(
            label: label,
            inlineLabel: false,
            value: selectedValues,
            controlView: self.scrollView,
            valueExtraction: { (Any) -> [VALUE]? in
                return tableSource.dataSource.selectedItems
            },
            setValue: { _, value in
                tableSource.dataSource.select(items: value ?? [])
            },
            validationRules: validationRules
        )
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
}

extension Array where Element: Equatable {
    
    /// Finds position of element in the array. This is a linear complexity operation.
    fileprivate func indexOf(_ value: Element) -> Int? {
        return self.index(where: { $0 == value })
    }
}

