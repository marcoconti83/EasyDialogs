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

open class MultipleSelectionInput<VALUE: Equatable>: ValueInput<[VALUE], NSScrollView> {
    
    /// The scroll view wrapping an inner table view
    public let scrollView: NSScrollView
    
    /// The inner table view wrapped by a scroll view
    public let tableView: NSTableView
    
    /// Table selection
    private let tableSource: EasyTableSource<VALUE>
    
    public var selectionChangeDelegate: (([VALUE])->())? = nil
    
    convenience public init(label: String? = nil,
                possibleValues: [VALUE],
                valueToDisplay: ((VALUE)->Any)? = nil,
                selectedValues: [VALUE] = [],
                validationRules: [AnyInputValidation<[VALUE]>] = [],
                maxRowsToDisplay: Int? = nil,
                minRowsToDisplay: Int = 3,
                columns: [ColumnDefinition<VALUE>]? = nil,
                showHeader: Bool = false
        )
    {
        let valueToDisplay = valueToDisplay ?? { "\($0)" }
        let columns = columns ?? [ColumnDefinition(name: "Value", value: valueToDisplay)]
        self.init(label: label,
                  possibleValues: possibleValues,
                  selectedValues: selectedValues,
                  columns: columns,
                  validationRules: validationRules,
                  maxRowsToDisplay: maxRowsToDisplay,
                  minRowsToDisplay: minRowsToDisplay,
                  showHeader: showHeader
        )
    }
    
    public init(label: String? = nil,
                possibleValues: [VALUE],
                selectedValues: [VALUE] = [],
                columns: [ColumnDefinition<VALUE>],
                validationRules: [AnyInputValidation<[VALUE]>] = [],
                maxRowsToDisplay: Int? = nil,
                minRowsToDisplay: Int = 3,
                showHeader: Bool = false
        )
    {
        let (scroll, table) = NSTableView.inScrollView()
        self.scrollView = scroll

        if !showHeader {
            table.headerView = nil
        }
        self.tableView = table
        let closure = MutableRef<([VALUE]) -> Void>()
        let tableSource = EasyTableSource(
            initialObjects: possibleValues,
            columns: columns,
            contextMenuOperations: [],
            table: table,
            selectionModel: .multipleCheckbox,
            selectionCallback: { closure.ref?($0) }
        )
        self.tableSource = tableSource
        let rowHeight = tableSource.table.rowHeight + tableSource.table.intercellSpacing.height
        MultipleSelectionInput.setScrollSize(scroll: scroll,
                                             rowHeight: rowHeight,
                                             minRows: minRowsToDisplay,
                                             maxRows: maxRowsToDisplay,
                                             totalRows: possibleValues.count,
                                             showHeader: showHeader)
        scroll.hasVerticalScroller = true
        super.init(
            label: label,
            inlineLabel: false,
            value: selectedValues,
            controlView: self.scrollView,
            valueExtraction: { _, _ -> [VALUE]? in
                return tableSource.dataSource.selectedItems
            },
            setValue: { _, _, value in
                tableSource.dataSource.select(items: value ?? [])
            },
            validationRules: validationRules
        )
        closure.ref = { [weak self] sel in
            self?.selectionChangeDelegate?(sel)
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    private static func setScrollSize(scroll: NSScrollView,
                                      rowHeight: CGFloat,
                                      minRows: Int,
                                      maxRows: Int?,
                                      totalRows: Int,
                                      showHeader: Bool)
    {
        func height(rows: Int, halfRow: Bool) -> CGFloat {
            let headerSize = showHeader ? 1.2 : 0
            return (CGFloat(rows) + CGFloat(headerSize) + (halfRow ? 0.5 : 0.0)) * rowHeight
        }
    
        var minRows = minRows
        if let maxRows = maxRows {
            let needsHalfRow = totalRows > maxRows
            constrain(scroll) { scroll in
                scroll.height <= height(rows: maxRows, halfRow: needsHalfRow)
            }
            if minRows > maxRows {
                minRows = maxRows
            }
        }
        let needsHalfRow = minRows < totalRows
        constrain(scroll) { scroll in
            scroll.height >= height(rows: minRows, halfRow: needsHalfRow)
        }
    }
}

extension Array where Element: Equatable {
    
    /// Finds position of element in the array. This is a linear complexity operation.
    fileprivate func indexOf(_ value: Element) -> Int? {
        return self.index(where: { $0 == value })
    }
}
