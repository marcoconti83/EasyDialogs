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

import Cocoa
import Cartography
import EasyTables
import ClosureControls

/// An inputs that displays a list of objects
open class ObjectListInput<VALUE: Equatable>: ValueInput<[VALUE], NSView> {
    
    /// Table selection
    private let tableSource: EasyTableSource<Unique<VALUE>>
    
    /// Callback to signify that an object has been created/modified. If
    /// the parameter is null, the operation was canceled.
    public typealias ObjectReadyCallback = (VALUE?)->()
    
    /// Handler to call when an objects need to me created. The handler is
    /// passed a callback to invoke when the object has been created.
    public typealias ObjectCreationHandler = (@escaping ObjectReadyCallback)->()
    
    /// Handler to call when an object needs to be modified. The handler is
    /// passed a callback to invoke when the object has been modified.
    public typealias ObjectEditHandler = (VALUE, @escaping ObjectReadyCallback)->()
    
    /// Object edit handler
    private var objectEditHandler: ObjectEditHandler? = nil
    
    /// Button to edit element in list
    private var editButton: ClosureButton? = nil
    
    /// Button to remove elements from list
    private var removeButton: ClosureButton? = nil
    
    /// Button to move up
    private var moveUpButton: ClosureButton? = nil
    
    /// Button to move down
    private var moveDownButton: ClosureButton? = nil
    
    /// Delegate for changes in field value
    public var delegate: (([VALUE])->())? = nil
    
    /// Table view holding the current objects
    private var table: NSTableView
    
    /// A reference to future self. Needed to be able to pass self to super
    /// constructor arguments
    private var futureReference: WeakMutableRef<ObjectListInput<VALUE>>
    
    public init(label: String? = nil,
                initialValues: [VALUE],
                validationRules: [AnyInputValidation<[VALUE]>] = [],
                maxRowsToDisplay: Int = 10,
                possibleObjects: [VALUE] = [],
                objectCreation: ObjectCreationHandler? = nil,
                objectEdit: ObjectEditHandler? = nil,
                columns: [ColumnDefinition<VALUE>]? = nil
        )
    {
        let reference = WeakMutableRef<ObjectListInput<VALUE>>()
        let columns = columns ?? [ColumnDefinition(name: "Value", value: { "\($0)" })]
        let (tableContainer, table, tableSource) =
            ObjectListInput<VALUE>.createTable(
                maxRowsToDisplay: maxRowsToDisplay,
                initialValues: initialValues,
                columns: columns,
                reference: reference
        )
        self.tableSource = tableSource
        let contentView = type(of: self).createBox()
        self.futureReference = reference
        self.table = table
        self.objectEditHandler = objectEdit
        
        // Super
        super.init(
            label: label,
            inlineLabel: false,
            value: initialValues,
            controlView: contentView,
            valueExtraction: { (Any) -> [VALUE]? in
                return tableSource.content.map { $0.object }
        },
            setValue: { _, value in
                tableSource.setContent(value?.map { Unique($0) } ?? [])
        },
            validationRules: validationRules
        )
        
        self.futureReference.object = self
        
        let toolbar = self.createToolbarAndButtons(
            edit: objectEdit,
            create: objectCreation,
            possibleObjects: possibleObjects)
        
        self.setupLayout(
            contentView: contentView,
            table: tableContainer,
            toolbar: toolbar)
        
        self.table.target = self
        self.table.doubleAction = #selector(onDoubleClick)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onDoubleClick() {
        guard self.table.clickedRow >= 0 else { return }
        let object = self.tableSource.content[self.table.clickedRow]
        self.showEditForm(object, closure: self.objectEditHandler)
    }
}
extension ObjectListInput {
    
    private func setupLayout(contentView: NSView, table: NSView, toolbar: NSView) {
        contentView.addSubview(table)
        contentView.addSubview(toolbar)
        constrain(contentView, table, toolbar) { content, table, toolbar in
            table.leading == content.leading
            table.trailing == content.trailing
            table.top == content.top
            table.bottom == toolbar.top
            toolbar.leading == content.leading
            toolbar.trailing == content.trailing
            toolbar.bottom == content.bottom
        }
    }
    
    private static func createTable(
        maxRowsToDisplay: Int,
        initialValues: [VALUE],
        columns: [ColumnDefinition<VALUE>],
        reference: WeakMutableRef<ObjectListInput<VALUE>>
        ) -> (NSView, NSTableView, EasyTableSource<Unique<VALUE>>)
    {
        let (scroll, table) = NSTableView.inScrollView()
        table.headerView = nil
        let tableSource = EasyTableSource(
            initialObjects: initialValues.map { Unique($0) },
            columns: columns.map { Unique<VALUE>.wrapColumnDefinition($0) },
            contextMenuOperations: [],
            table: table,
            selectionModel: .multipleNative,
            autosortByFirstColumn: false,
            selectionCallback: { _ in reference.object?.updateSelection() })
        let rowHeight = tableSource.table.rowHeight + tableSource.table.intercellSpacing.height
        constrain(scroll) { scroll in
            scroll.height == CGFloat(maxRowsToDisplay) * rowHeight
        }
        return (scroll, table, tableSource)
    }
    
    private func createToolbarAndButtons(
        edit: ObjectEditHandler?,
        create: ObjectCreationHandler?,
        possibleObjects: [VALUE]
        ) -> NSView {
        let buttons = [
            self.createAddButton(objectCreationClosure: create),
            self.createChooseFromListButton(possibleObjects: possibleObjects),
            self.createEditButton(closure: edit),
            self.createRemoveButton(),
            self.createUpButton(),
            self.createDownButton()
            ].compactMap { $0 }
        buttons.forEach {
            $0.showsBorderOnlyWhileMouseInside = true
            constrain($0) { button in
                button.width == 25
                button.height == 25
            }
        }
        let toolbar = NSStackView(views: buttons)
        toolbar.spacing = 0
        toolbar.orientation = .horizontal
        return toolbar
    }
    
    private func createRemoveButton() -> ClosureButton? {
        let button = ClosureButton() { [weak self] _ in
            guard let `self` = self else { return }
            let selected = self.tableSource.dataSource.selectedItems
            guard !selected.isEmpty else { return }
            var remaining = self.tableSource.content
            selected.forEach {
                guard let index = remaining.index(of: $0) else { return }
                remaining.remove(at: index)
            }
            self.tableSource.setContent(remaining)
            self.notifyDelegate()
        }
        self.removeButton = button
        button.image = Images.get(name: "delete.png")
        button.toolTip = "Remove selected"
        button.isEnabled = false
        return button
    }
    
    private func createUpButton() -> ClosureButton? {
        let button = ClosureButton() { [weak self] _ in
            guard let `self` = self else { return }
            let selected = self.tableSource.dataSource.selectedItems
            guard !selected.isEmpty else { return }
            let list = self.tableSource.content.movingPositionOf(selected, offset: -1)
            self.tableSource.setContent(list)
            self.tableSource.dataSource.select(items: selected, extendSelection: false)
            self.notifyDelegate()
        }
        self.moveUpButton = button
        button.image = Images.get(name: "arrow_up.png")
        button.toolTip = "Move up"
        button.isEnabled = false
        return button
    }

    private func createDownButton() -> ClosureButton? {
        let button = ClosureButton() { [weak self] _ in
            guard let `self` = self else { return }
            let selected = self.tableSource.dataSource.selectedItems
            guard !selected.isEmpty else { return }
            let list = self.tableSource.content.movingPositionOf(selected, offset: 1)
            self.tableSource.setContent(list)
            self.tableSource.dataSource.select(items: selected, extendSelection: false)
            self.notifyDelegate()
        }
        self.moveDownButton = button
        button.image = Images.get(name: "arrow_down.png")
        button.toolTip = "Move down"
        button.isEnabled = false
        return button
    }

    
    private func createChooseFromListButton(possibleObjects: [VALUE]) -> ClosureButton? {
        guard !possibleObjects.isEmpty else { return nil }
        let button = ClosureButton() { _ in
            possibleObjects.askMultipleAnswers("Select one or more items to add to the list",
                                                    initialValue: [])
            { [weak self] response in
                guard let `self` = self, case .ok(let objects) = response else { return }
                self.tableSource.setContent(self.tableSource.content + objects.map { Unique($0) })
                self.notifyDelegate()
            }
        }
        button.image = Images.get(name: "zoom")
        button.toolTip = "Pick item from list"
        return button
    }
    
    private func createEditButton(closure: ObjectEditHandler?) -> ClosureButton? {
        guard let closure = closure else { return nil }
        let button = ClosureButton() { [weak self] _ in
            guard
                let `self` = self,
                let item = self.tableSource.dataSource.selectedItems.first
                else { return }
            self.showEditForm(item, closure: closure)
        }
        button.image = Images.get(name: "pencil.png")
        self.editButton = button
        button.isEnabled = false
        button.toolTip = "Edit selected"
        return button
    }
    
    private func createAddButton(objectCreationClosure: ObjectCreationHandler?) -> ClosureButton? {
        guard let objectCreationClosure = objectCreationClosure else { return nil }
        let button = ClosureButton() { _ in
            objectCreationClosure() { [weak self] in
                guard let `self` = self,
                    let created = $0
                    else { return }
                self.tableSource.setContent(self.tableSource.content + [Unique(created)])
                self.notifyDelegate()
            }
        }
        button.image = Images.get(name: "add.png")
        button.toolTip = "Create new"
        return button
    }
    
    private static func createBox() -> NSView {
        let box = NSBox()
        box.boxType = .custom
        box.cornerRadius = 0
        box.contentViewMargins = NSSize(width: 0, height: 0)
        box.borderType = .lineBorder
        box.borderWidth = 1
        box.borderColor = NSColor.controlShadowColor
        return box
    }
    
    private func updateSelection() {
        let hasSelected = !self.tableSource.dataSource.selectedItems.isEmpty
        self.editButton?.isEnabled = hasSelected
        self.removeButton?.isEnabled = hasSelected
        self.moveUpButton?.isEnabled = hasSelected
        self.moveDownButton?.isEnabled = hasSelected
    }
    
    private func notifyDelegate() {
        let currentValue = self.tableSource.content
        self.delegate?(currentValue.map { $0.object })
    }
    
    private func showEditForm(_ item: Unique<VALUE>, closure: ObjectEditHandler?) {
        closure?(item.object) { [weak self] newObj in
            guard let edited = newObj.flatMap({ Unique($0) }) else { return }
            guard var items = self?.tableSource.content else { return }
            if let index = items.index(of: item) {
                items.remove(at: index)
                items.insert(edited, at: index)
            } else {
                items.append(edited)
            }
            self?.tableSource.setContent(items)
            self?.notifyDelegate()
        }

    }
}

extension Unique {
    
    static func wrapColumnDefinition(_ column: ColumnDefinition<Object>)
        -> ColumnDefinition<Unique<Object>>
    {
        return ColumnDefinition(
            name: column.name,
            width: column.width,
            alignment: column.alignment,
            value: { wrapper in
                return column.value(wrapper.object)
            }
        )
    }
}

extension Array where Element: Equatable {
    
    public func movingPositionOf(_ elements: [Element], offset: Int) -> Array<Element> {
        guard !elements.isEmpty, offset != 0 else { return self }
        var result = self
        (offset > 0 ? elements.reversed() : elements).forEach {
            result = result.movingPositionOf($0, offset: offset)
        }
        return result
    }
    
    private func movingPositionOf(_ element: Element, offset: Int) -> Array<Element> {
        guard let index = self.index(of: element) else { return self }
        var newPosition = index + offset
        if newPosition < 0 {
            newPosition = 0
        }
        if newPosition >= self.count {
            newPosition = self.count - 1
        }
        guard newPosition != index else { return self }
        var newArray = self
        let element = newArray.remove(at: index)
        newArray.insert(element, at: newPosition)
        return newArray
    }
}
