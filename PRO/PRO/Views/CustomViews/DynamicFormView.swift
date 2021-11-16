//
//  DynamicFormView.swift
//  PRO
//
//  Created by VMO on 7/01/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI

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
            case "date":
                DynamicFormDate(field: $field)
            case "time":
                DynamicFormTime(field: $field)
            case "checkbox":
                DynamicFormCheckbox(field: $field)
            case "canvas":
                DynamicFormCanvas(field: $field)
            case "image":
                DynamicFormImage(field: $field, options: options)
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
                .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
            TextField("env\(field.label.capitalized)", text: $field.value)
                .cornerRadius(CGFloat(4))
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct DynamicFormDate: View {
    
    @Binding var field: DynamicFormField

    @State private var date = Date()

    var body: some View {
        VStack {
            Text(NSLocalizedString("env\(field.label.capitalized)", comment: field.label))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
            DatePicker("", selection: $date.onChange(dateChanged), displayedComponents: .date)
                .labelsHidden()
                .clipped()
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        date = Utils.strToDate(value: field.value)
    }
    
    func dateChanged(_ date: Date) {
        field.value = Utils.dateFormat(date: date)
    }
    
}

struct DynamicFormTime: View {
    
    @Binding var field: DynamicFormField

    @State private var date = Date()

    var body: some View {
        VStack {
            Text(NSLocalizedString("env\(field.label.capitalized)", comment: field.label))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
            DatePicker("", selection: $date.onChange(dateChanged), displayedComponents: .hourAndMinute)
                .labelsHidden()
                .clipped()
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        date = Utils.strToDate(value: "2021-01-01 \(field.value):00")
    }
    
    func dateChanged(_ date: Date) {
        field.value = Utils.dateFormat(date: date, format: "HH:mm")
    }
    
}

struct DynamicFormCheckbox: View {
    
    @Binding var field: DynamicFormField
    @State private var checked = true
    
    var body: some View {
        VStack {
            Toggle(NSLocalizedString("env\(field.label.capitalized)", comment: field.label), isOn: $checked.onChange(valueChanged))
                .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        if field.value == "Y" {
            checked = true
        } else {
            checked = false
        }
    }
    
    func valueChanged(_ value: Bool) {
        field.value = value ? "Y" : "N"
    }
    
}

struct DynamicFormImage: View {
    
    @Binding var field: DynamicFormField
    var options: DynamicFormFieldOptions
    
    @State private var showActionSheet = false
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentImageViewer = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    @State private var uiImage: UIImage?
    
    var body: some View {
        VStack {
            Button(action: {
                showActionSheet = true
            }) {
                VStack {
                    Text(NSLocalizedString("env\(field.label.capitalized)", comment: field.label))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
                }
                .frame(height: 44)
            }
            .buttonStyle(BorderlessButtonStyle())
            .actionSheet(isPresented: self.$showActionSheet) {
                ActionSheet(title: Text("envSelect"), message: Text(""), buttons: [
                    .default(Text("envCamera"), action: {
                        self.sourceType = .camera
                        self.shouldPresentImagePicker = true
                    }),
                    .default(Text("envGallery"), action: {
                        self.sourceType = .photoLibrary
                        self.shouldPresentImagePicker = true
                    }),
                    .cancel()
                ])
            }
            if field.value == "Y" {
                Button(action: {
                    shouldPresentImageViewer = true
                }) {
                    Text("envPreviewResource")
                }
                .frame(height: 40)
                .buttonStyle(BorderlessButtonStyle())
                .popover(isPresented: $shouldPresentImageViewer) {
                    ImageViewerDialog(table: options.table, field: field.key, id: options.item)
                }
            }
        }
        .sheet(isPresented: $shouldPresentImagePicker) {
            CustomImagePickerView(sourceType: sourceType, uiImage: self.$uiImage, onSelectionDone: onSelectionDone)
        }
    }
    
    func onSelectionDone(_ done: Bool) {
        self.shouldPresentImagePicker = false
        field.value = done ? "Y" : field.value
        if done {
            MediaUtils.store(uiImage: uiImage, table: options.table, field: field.key, id: options.item)
        }
    }
    
}

struct DynamicFormCanvas: View {
    
    @Binding var field: DynamicFormField

    @State private var drawDialog = false
    
    var body: some View {
        VStack {
            Button(action: {
                drawDialog = true
            }) {
                VStack {
                    Text(NSLocalizedString("env\(field.label.capitalized)", comment: field.label))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            if field.value == "Y" {
                Button(action: {
                    
                }) {
                    Text("envPreviewResource")
                }
            }
        }
        .onAppear {
            load()
        }
        .sheet(isPresented: $drawDialog, content: {
            CanvasDrawerDialog()
        })
    }
    
    func load() {
    }
    
}

struct DynamicFormDayMonth: View {
    
    @Binding var field: DynamicFormField
    @State var selected = [String]()
    @State private var selectDialog = false
    @State var selectedLabel: String = ""
    
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
        .sheet(isPresented: $selectDialog, content: {
            DayMonthDialogPicker(onSelectionDone: onSelectionDone, selected: $selected)
        })
    }
    
    func onSelectionDone(_ : [String]) {
        selectDialog = false
        if selected.count > 1 {
            selectedLabel = "\(Utils.castString(value: CommonUtils.months[Utils.castInt(value: selected[0]) - 1]["name"])) \(selected[1])"
        }
    }
    
}

struct DynamicFormList: View {
    
    @Binding var field: DynamicFormField
    
    @State var items = [ListItem]()
    @State var selected = [String]()
    @State var selectedLabel: String = ""
    
    @State private var selectSourceDynamic = false
    @State private var selectSourceTableAuto = false
    @State private var selectSourceTableFull = false
    @State private var selectSourceServer = false
    
    var body: some View {
        Button(action: {
            switch field.sourceType {
            case "json":
                selectSourceDynamic.toggle()
            case "table":
                if true {
                    selectSourceTableFull.toggle()
                } else {
                    selectSourceTableAuto.toggle()
                }
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
        .partialSheet(isPresented: $selectSourceTableAuto) {
            CustomDialogPicker(onSelectionDone: onSelectionDone, selected: $selected, key: field.source, multiple: field.multiple, title: NSLocalizedString("env\(field.label.capitalized)", comment: field.label), isSheet: true)
        }
        .sheet(isPresented: $selectSourceTableFull, content: {
            CustomDialogPicker(onSelectionDone: onSelectionDone, selected: $selected, key: field.source, multiple: field.multiple, title: NSLocalizedString("env\(field.label.capitalized)", comment: field.label), isSheet: true)
        })
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
        selectSourceTableFull = false
        selectSourceTableAuto = false
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
