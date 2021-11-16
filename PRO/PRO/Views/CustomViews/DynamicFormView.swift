//
//  DynamicFormView.swift
//  PRO
//
//  Created by VMO on 7/01/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import BottomSheet

struct DynamicFormView: View {
    
    @Binding var form: DynamicForm
    @Binding var tab: DynamicFormTab
    var options: DynamicFormFieldOptions
    
    var body: some View {
        Form {
            ForEach(tab.groups.indices) { index in
                DynamicFormSection(form: $form, group: $tab.groups[index], options: options)
            }
        }
    }
}

struct DynamicFormSection: View {
    
    @Binding var form: DynamicForm
    @Binding var group: DynamicFormGroup
    var options: DynamicFormFieldOptions
    
    var body: some View {
        Section(header: Text(group.title)) {
            ForEach(group.fields.indices) { index in
                if group.fields[index].localVisible {
                    DynamicFieldView(form: $form, field: $group.fields[index], options: options)
                }
            }
        }
    }
}

struct DynamicFieldView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    @Binding var form: DynamicForm
    @Binding var field: DynamicFormField
    var options: DynamicFormFieldOptions
    
    @State var user: User?
    @State var formConditions: DynamicConditionForm?
    
    var body: some View {
        VStack {
            switch(field.controlType) {
            case "text-field":
                DynamicFormTextField(field: $field)
            case "list":
                DynamicFormList(field: $field)
            case "day-month":
                DynamicFormDayMonth(field: $field)
            default:
                Text("A")
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        user = userSettings.userData()
        initEditable()
        initRequired()
        initVisible()
    }
    
    func hasConditions(type: String) -> Bool {
        if let conditions = field.condition {
            if let c = try? JSONDecoder().decode(DynamicConditionForm.self, from: conditions.data(using: .utf8)!) {
                formConditions = c
                var groups = [DynamicConditionGroup]()
                switch type {
                case "editable":
                    groups = formConditions?.editable ?? [DynamicConditionGroup]()
                case "required":
                    groups = formConditions?.required ?? [DynamicConditionGroup]()
                case "visible":
                    groups = formConditions?.visible ?? [DynamicConditionGroup]()
                default:
                    break
                }
                if !groups.isEmpty {
                    var hasConditions = false
                    groups.forEach { group in
                        if !group.conditions.isEmpty {
                            hasConditions = true
                        }
                    }
                    return hasConditions
                }
            }
        }
        return false
    }
    
    func initEditable() {
        let type = "editable"
        if hasConditions(type: type) {
            if let set = formConditions?.editable {
                initConditions(set: set, type: type)
            }
        } else {
            self.field.localEditable = self.isEditable()
        }
    }
    
    func isEditable() -> Bool {
        switch options.table {
        case "movement":
            break
        default:
            if options.op == "create" {
                return field.editable.createUserTypes.components(separatedBy: ",").contains(String(user?.type ?? 0))
            } else {
                return field.editable.updateUserTypes.components(separatedBy: ",").contains(String(user?.type ?? 0))
            }
        }
        return false
    }
    
    func initRequired() {
        let type = "required"
        if hasConditions(type: type) {
            if let set = formConditions?.required {
                initConditions(set: set, type: type)
            }
        } else {
            self.field.localRequired = self.isRequired()
        }
    }
    
    func isRequired() -> Bool {
        switch options.table {
        case "movement":
            break
        default:
            return field.requiredUserTypes.components(separatedBy: ",").contains(String(user?.type ?? 0))
        }
        return false
    }
    
    func initVisible() {
        let type = "visible"
        if hasConditions(type: type) {
            if let set = formConditions?.visible {
                initConditions(set: set, type: type)
            }
        } else {
            self.field.localVisible = self.isVisible()
        }
    }
    
    func isVisible() -> Bool {
        switch options.table {
        case "movement":
            break
        default:
            if options.op == "create" {
                return field.visible.createUserTypes.components(separatedBy: ",").contains(String(user?.type ?? 0))
            } else {
                return field.visible.updateUserTypes.components(separatedBy: ",").contains(String(user?.type ?? 0))
            }
        }
        return false
    }
    
    func initConditions(set: [DynamicConditionGroup], type: String) {
        set.forEach({ group in
            group.conditions.forEach { condition in
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { t in
                    form.tabs.forEach { tab in
                        tab.groups.forEach { g in
                            g.fields.forEach { fd in
                                if fd.key == condition.field {
                                    let newValue = fd.value.components(separatedBy: ",")
                                    if newValue != condition.current {
                                        condition.current = newValue
                                        //print("UPDATE \(condition.field) = \(fd.value)")
                                        refreshConditions(set: set, type: type)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func refreshConditions(set: [DynamicConditionGroup], type: String) {
        switch (type) {
        case "editable":
            field.localEditable = self.validateConditions(set: set)
            break
        case "required":
            field.localRequired = self.validateConditions(set: set)
            break
        case "visible":
            field.localVisible = self.validateConditions(set: set)
            break
        default:
            break
        }
    }
    
    func validateConditions(set: [DynamicConditionGroup]) -> Bool {
        var result = true
        set.forEach { group in
            group.conditions.forEach { condition in
                if condition.current.isEmpty {
                    result = false
                } else {
                    if condition.field != "" && condition.op != "" && !condition.value.isEmpty {
                        var contains = false
                        condition.current.forEach { it in
                            if condition.value.contains(it) {
                                contains = true
                            }
                        }
                        if !contains {
                            result = false
                        }
                    }
                }
            }
        }
        return result
    }
    
}

struct DynamicFormTextField: View {
    
    @Binding var field: DynamicFormField
    
    var body: some View {
        VStack {
            Text(NSLocalizedString("env\(field.label.capitalized)", comment: field.label))
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("env\(field.label.capitalized)", text: $field.value)
                .border((field.localRequired && field.value.isEmpty) ? Color.cDanger : Color.cFieldBorder)
                .cornerRadius(CGFloat(4))
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct DynamicFormDayMonth: View {
    
    @Binding var field: DynamicFormField
    @State var selected = [String]()
    @State private var selectDialog = false
    
    var body: some View {
        Button(action: {
            selectDialog.toggle()
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("env\(field.label.capitalized)", comment: field.label))
                        .font(selected.isEmpty ? .none : .system(size: 14.0))
                        .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : (selected.isEmpty ? .cTextMedium : .cTextHigh))
                    if !selected.isEmpty {
                        Text("")
                            .foregroundColor(.cTextHigh)
                    }
                }
                Spacer()
                Image("ic-right-arrow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16, alignment: .center)
                    .foregroundColor(.cAccent)
            }
        }
        .partialSheet(isPresented: $selectDialog) {
            DayMonthDialogPicker()
                .layoutPriority(.greatestFiniteMagnitude)
        }
    }
    
}

struct DynamicFormList: View {
    
    @Binding var field: DynamicFormField
    
    @State var items = [ListItem]()
    @State var selected = [String]()
    @State var selectedLabel: String = ""
    
    @State private var selectSourceDynamic = false
    @State private var selectSourceTable = false
    @State private var selectSourceServer = false
    
    var body: some View {
        Button(action: {
            switch field.sourceType {
            case "json":
                selectSourceDynamic.toggle()
            case "table":
                selectSourceTable.toggle()
            default:
                selectSourceServer.toggle()
            }
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("env\(field.label.capitalized)", comment: field.label))
                        .font(selected.isEmpty ? .none : .system(size: 14.0))
                        .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : (selected.isEmpty ? .cTextMedium : .cTextHigh))
                    if !selected.isEmpty {
                        Text(selectedLabel)
                            .foregroundColor(.cTextHigh)
                    }
                }
                Spacer()
                Image("ic-right-arrow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16, alignment: .center)
                    .foregroundColor(.cAccent)
            }
        }
        .partialSheet(isPresented: $selectSourceDynamic) {
            SourceDynamicDialogPicker(onSelectionDone: onSelectionDone, selected: $selected, data: field.source, multiple: field.multiple, title: NSLocalizedString("env\(field.label.capitalized)", comment: field.label), isSheet: true)
        }
        .partialSheet(isPresented: $selectSourceTable) {
            CustomDialogPicker(onSelectionDone: onSelectionDone, selected: $selected, key: field.source, multiple: field.multiple, title: NSLocalizedString("env\(field.label.capitalized)", comment: field.label), isSheet: true)
        }
    }
    
    func onSelectionDone(_ : [String]) {
        field.value = selected.joined()
        if field.multiple {
            selectedLabel = "\(selected.count) \(NSLocalizedString("envItemsSelected", comment: ""))"
        } else {
            if !selected.isEmpty {
                switch field.sourceType {
                case "json":
                    let list = Utils.genericList(data: field.source)
                    let rs = list.filter { item -> Bool in
                        item.id == selected[0]
                    }
                    if !rs.isEmpty {
                        selectedLabel = rs[0].label
                    }
                case "table":
                    selectedLabel = DynamicUtils.tableValue(key: field.source, selected: selected) ?? "--"
                default:
                    selectedLabel = ""
                }
            }
        }
        selectSourceDynamic = false
        selectSourceTable = false
        selectSourceServer = false
    }
    
}

struct ListItem {
    var id: String
    var value: String
}

struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    typealias Index = Base.Index
    typealias Element = (index: Index, element: Base.Element)

    let base: Base

    var startIndex: Index { base.startIndex }

    var endIndex: Index { base.endIndex }

    func index(after i: Index) -> Index {
        base.index(after: i)
    }

    func index(before i: Index) -> Index {
        base.index(before: i)
    }

    func index(_ i: Index, offsetBy distance: Int) -> Index {
        base.index(i, offsetBy: distance)
    }

    subscript(position: Index) -> Element {
        (index: position, element: base[position])
    }
}

extension RandomAccessCollection {
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}
