//
//  MultipleSelectionInput.swift
//  EasyDialogs
//
//  Created by Marco Conti on 18.07.17.
//  Copyright © 2017 com.marco83. All rights reserved.
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
    private let tableConfiguration: TableConfiguration<VALUE>
    
    public init(label: String? = nil,
                possibleValues: [VALUE],
                selectedValues: [VALUE] = [],
                validation: @escaping ([VALUE]?)->(Bool) = { $0 != nil && !$0!.isEmpty }
        )
    {
        let (scroll, table) = NSTableView.inScrollView()
        self.scrollView = scroll
        self.tableView = table
        let tableConfiguration = TableConfiguration(
            initialObjects: possibleValues,
            columns: [
                ColumnDefinition.init("Value", { "\($0)" })
            ],
            contextMenuOperations: [],
            table: table,
            allowMultipleSelection: true,
            selectionCallback: { _ in })
        self.tableConfiguration = tableConfiguration
        
        super.init(
            label: label,
            value: selectedValues,
            controlView: self.scrollView,
            centerControlWithLabel: false,
            valueExtraction: { (Any) -> [VALUE]? in
                return tableConfiguration.dataSource.selectedItems
            },
            setValue: { _, value in
                tableConfiguration.dataSource.select(items: value ?? [])
            },
            validation: validation
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

