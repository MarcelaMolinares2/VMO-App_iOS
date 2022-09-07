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
        ForEach($tab.groups) { $group in
            DynamicFormSection(form: $form, group: $group, options: options)
        }
    }
}

struct DynamicFormSection: View {
    
    @Binding var form: DynamicForm
    @Binding var group: DynamicFormGroup
    var options: DynamicFormFieldOptions
    
    var body: some View {
        let title = DynamicUtils.formatLabel(s: group.title).localized(defaultValue: group.title)
        CustomSection(title) {
            ForEach($group.fields) { $field in
                if field.localVisible {
                    DynamicFieldView(form: $form, field: $field, options: options)
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
                case "canvas", "habeas-data", "image":
                    DynamicFormImage(field: $field, options: options)
                case "checkbox":
                    DynamicFormCheckbox(field: $field)
                case "date":
                    DynamicFormDate(field: $field)
                case "day-month":
                    DynamicFormDayMonth(field: $field)
                case "file":
                    Text("B")
                case "info":
                    DynamicFormInfo(field: $field)
                case "list":
                    DynamicFormList(field: $field)
                case "text-field":
                    DynamicFormTextField(field: $field)
                case "time":
                    DynamicFormTime(field: $field)
            default:
                EmptyView()
            }
        }
        .padding(.vertical, 6)
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
        formConditions = field.condition
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
        if options.op == .create {
            return field.editable.createUserTypes.components(separatedBy: ",").contains(String(user?.type ?? 0))
        } else {
            return field.editable.updateUserTypes.components(separatedBy: ",").contains(String(user?.type ?? 0))
        }
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
            return optionsValue(key: "required") && movementOptsValue(key: "required")
        default:
            return field.requiredUserTypes.components(separatedBy: ",").contains(String(user?.type ?? 0))
        }
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
                return optionsValue(key: "visible") && movementOptsValue(key: "visible")
            default:
                if options.op == .create {
                    return field.visible.createUserTypes.components(separatedBy: ",").contains(String(user?.type ?? 0))
                } else {
                    return field.visible.updateUserTypes.components(separatedBy: ",").contains(String(user?.type ?? 0))
                }
        }
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
            field.localEditable = self.validateConditions(set: set) && self.isEditable()
            break
        case "required":
                field.localRequired = self.validateConditions(set: set) && self.isRequired()
            break
        case "visible":
            field.localVisible = self.validateConditions(set: set) && self.isVisible()
            break
        default:
            break
        }
    }
    
    func validateConditions(set: [DynamicConditionGroup]) -> Bool {
        var result = true
        set.forEach { group in
            group.conditions.forEach { condition in
                
                if ["equal", "not-equal"].contains(condition.op) {
                    if condition.value.isEmpty {
                        if !condition.current.isEmpty {
                            if !condition.current[0].isEmpty {
                                result = false
                            }
                        }
                    } else {
                        var contains = false
                        condition.current.forEach { it in
                            if condition.value.contains(it) {
                                contains = true
                            }
                        }
                        switch condition.op {
                            case "equal":
                                if !contains {
                                    result = false
                                }
                            case "not-equal":
                                if contains {
                                    result = false
                                }
                            default:
                                break
                        }
                    }
                } else if ["less", "more"].contains(condition.op) {
                    if !condition.value.isEmpty {
                        if !condition.value[0].isEmpty {
                            if condition.current.isEmpty {
                                result = false
                            } else {
                                if condition.current[0].isEmpty {
                                    result = false
                                } else {
                                    switch field.dataType {
                                        case "date", "time":
                                            var v: Date
                                            var c: Date
                                            if field.dataType == "date" {
                                                v = Utils.strToDate(value: condition.value[0])
                                                c = Utils.strToDate(value: condition.current[0])
                                            } else {
                                                v = Utils.strToDate(value: condition.value[0], format: "HH:mm")
                                                c = Utils.strToDate(value: condition.current[0], format: "HH:mm")
                                            }
                                            if condition.op == "less" {
                                                if c >= v {
                                                    result = false
                                                }
                                            } else {
                                                if c <= v {
                                                    result = false
                                                }
                                            }
                                        default:
                                            let v = Utils.castInt(value: condition.value[0])
                                            let c = Utils.castInt(value: condition.current[0])
                                            if condition.op == "less" {
                                                if c >= v {
                                                    result = false
                                                }
                                            } else {
                                                if c <= v {
                                                    result = false
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    //BETWEEN
                }
            }
        }
        return result
    }
    
    func optionsValue(key: String) -> Bool {
        if let panelTypes = Utils.jsonDictionary(string: field.options)["panelType"] as? Dictionary<String, Any> {
            if let panelOptions = panelTypes[options.panelType] as? Dictionary<String, Any> {
                if let keyOptions = panelOptions[key] as? Dictionary<String, Any> {
                    if let opValues = keyOptions[DynamicUtils.transactionType(action: options.op).lowercased()] as? String {
                        return opValues.components(separatedBy: ",").contains(String(user?.type ?? 0))
                    }
                }
            }
        }
        return false
    }
    
    func movementOptsValue(key: String) -> Bool {
        if let panelTypes = Utils.jsonDictionary(string: field.options)["visitType"] as? Dictionary<String, Any> {
            if let visitOptions = panelTypes[options.type] as? Dictionary<String, Any> {
                if let keyOptions = visitOptions["visible"] as? Int {
                    return keyOptions == 1
                }
            }
        }
        return false
    }
    
}

struct DynamicFormDescriptionView: View {
    
    var field: DynamicFormField
    
    var body: some View {
        if let d = field.description {
            if !d.isEmpty {
                Text(d)
                    .foregroundColor(.cTextMedium)
                    .font(.system(size: 13))
            }
        }
    }
    
}

struct DynamicFormTextField: View {
    
    @Binding var field: DynamicFormField
    
    var body: some View {
        let label = DynamicUtils.formatLabel(s: field.label).localized(defaultValue: field.label)
        VStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
            TextField(label, text: $field.value)
                .cornerRadius(CGFloat(4))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            DynamicFormDescriptionView(field: field)
        }
    }
    
}

struct DynamicFormInfo: View {
    
    @Binding var field: DynamicFormField
    
    var body: some View {
        let label = DynamicUtils.formatLabel(s: field.label).localized(defaultValue: field.label)
        VStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.cTextMedium)
            Text(field.value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.cTextHigh)
        }
    }
    
}

struct DynamicFormDate: View {
    
    @Binding var field: DynamicFormField

    @State private var date = Date()

    var body: some View {
        let label = DynamicUtils.formatLabel(s: field.label).localized(defaultValue: field.label)
        VStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
            DatePicker("", selection: $date.onChange(dateChanged), displayedComponents: .date)
                .labelsHidden()
                .clipped()
            DynamicFormDescriptionView(field: field)
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
        let label = DynamicUtils.formatLabel(s: field.label).localized(defaultValue: field.label)
        VStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
            DatePicker("", selection: $date.onChange(dateChanged), displayedComponents: .hourAndMinute)
                .labelsHidden()
                .clipped()
            DynamicFormDescriptionView(field: field)
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
        let label = DynamicUtils.formatLabel(s: field.label).localized(defaultValue: field.label)
        VStack {
            Toggle(label, isOn: $checked.onChange(valueChanged))
                .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
            DynamicFormDescriptionView(field: field)
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        if field.value == "1" {
            checked = true
        } else {
            checked = false
        }
    }
    
    func valueChanged(_ value: Bool) {
        field.value = value ? "1" : "0"
    }
    
}

struct DynamicFormImage: View {
    
    @Binding var field: DynamicFormField
    var options: DynamicFormFieldOptions
    
    @State private var actionSheet = false
    @State private var modalCamera = false
    @State private var modalDraw = false
    @State private var modalGallery = false
    
    @State private var initialValue = ""
    @State private var availableSources = ""
    
    @State private var uiImage: UIImage?
    
    private let pickerSources = Utils.jsonDictionary(string: Config.get(key: "PICKER_SOURCES").complement ?? "{}")
    
    var body: some View {
        let label = DynamicUtils.formatLabel(s: field.label).localized(defaultValue: field.label)
        VStack {
            HStack {
                Text(label)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
                if field.value == "Y" {
                    Button(action: {
                        delete()
                    }) {
                        Image("ic-delete")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.cDanger)
                            .frame(width: 24, height: 24, alignment: .center)
                    }
                    .frame(width: 44, height: 44, alignment: .center)
                }
            }
            Button(action: {
                switch field.controlType {
                    case "canvas":
                        onSourceSelected(s: "D")
                    default:
                        actionSheet = true
                }
            }) {
                if field.value == "Y" {
                    ImageViewerWrapperView(table: options.table, field: field.key, id: options.item, localId: options.objectId)
                } else {
                    Image(icon())
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.cIcon)
                        .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                }
            }
            DynamicFormDescriptionView(field: field)
        }
        .actionSheet(isPresented: $actionSheet) {
            ActionSheet(title: Text("envSelect"), message: nil, buttons: Widgets.mediaSourcePickerButtons(available: availableSources, action: onSourceSelected))
        }
        .sheet(isPresented: $modalCamera) {
            CustomImagePickerView(sourceType: .camera, uiImage: self.$uiImage, onSelectionDone: onSelectionDone)
        }
        .sheet(isPresented: $modalDraw) {
            CanvasDrawerDialog(uiImage: self.$uiImage, title: NSLocalizedString(label, comment: field.label), onSelectionDone: onSelectionDone)
        }
        .sheet(isPresented: $modalGallery) {
            CustomImagePickerView(sourceType: .photoLibrary, uiImage: self.$uiImage, onSelectionDone: onSelectionDone)
        }
        .onAppear {
            initField()
        }
    }
    
    func initField() {
        initialValue = field.value
        switch field.controlType {
            case "image":
                availableSources = Utils.castString(value: pickerSources["IMAGE"], defaultValue: "C,G")
            case "habeas-data":
                availableSources = Utils.castString(value: pickerSources["HABEAS-DATA"], defaultValue: "D,C,G")
            default:
                break
        }
    }
    
    func delete() {
        field.value = initialValue
        MediaUtils.remove(table: options.table, field: field.key, id: options.item, localId: options.objectId)
    }
    
    func icon() -> String {
        switch field.controlType {
            case "canvas":
                return "ic-draw"
            case "habeas-data":
                return "ic-habeas-data"
            default:
                return "ic-gallery"
        }
    }
    
    func onSourceSelected(s: String) {
        actionSheet = false
        switch s {
            case "C":
                modalCamera = true
            case "D":
                modalDraw = true
            case "G":
                modalGallery = true
            default:
                break;
        }
    }
    
    func onSelectionDone(_ done: Bool) {
        self.modalCamera = false
        self.modalDraw = false
        self.modalGallery = false
        field.value = ""
        if done {
            MediaUtils.store(
                uiImage: uiImage,
                table: options.table,
                field: field.key,
                id: options.item,
                localId: options.objectId
            )
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            field.value = done ? "Y" : initialValue
        }
    }
    
}

enum MediaSource {
    case canvas, gallery, camera
}

enum SheetLayout {
    case picker, viewer
}

struct DynamicFormHabeasData: View {
    
    @Binding var field: DynamicFormField
    var options: DynamicFormFieldOptions
    
    @State private var showActionSheet = false
    @State private var shouldPresentSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var source: MediaSource = .canvas
    @State private var sheetLayout: SheetLayout = .picker
    
    @State private var uiImage: UIImage?
    
    var body: some View {
        let label = DynamicUtils.formatLabel(s: field.label).localized(defaultValue: field.label)
        VStack {
            Button(action: {
                showActionSheet = true
            }) {
                VStack {
                    Text(label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
                }
                .frame(height: 44)
            }
            .buttonStyle(BorderlessButtonStyle())
            .actionSheet(isPresented: self.$showActionSheet) {
                ActionSheet(title: Text("envSelect"), message: Text(""), buttons: [
                    .default(Text("envDraw"), action: {
                        self.source = .canvas
                        self.sheetLayout = .picker
                        self.shouldPresentSheet = true
                    }),
                    .default(Text("envCamera"), action: {
                        self.sourceType = .camera
                        self.source = .camera
                        self.sheetLayout = .picker
                        self.shouldPresentSheet = true
                    }),
                    .default(Text("envGallery"), action: {
                        self.sourceType = .photoLibrary
                        self.source = .gallery
                        self.sheetLayout = .picker
                        self.shouldPresentSheet = true
                    }),
                    .cancel()
                ])
            }
            if field.value == "Y" {
                Button(action: {
                    sheetLayout = .viewer
                    shouldPresentSheet = true
                }) {
                    Text("envPreviewResource")
                }
                .frame(height: 40)
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .sheet(isPresented: $shouldPresentSheet) {
            switch sheetLayout {
                case .picker:
                    switch source {
                        case .canvas:
                            CanvasDrawerDialog(uiImage: self.$uiImage, title: NSLocalizedString("env\(field.label.capitalized)", comment: field.label), onSelectionDone: onSelectionDone)
                        default:
                            CustomImagePickerView(sourceType: sourceType, uiImage: self.$uiImage, onSelectionDone: onSelectionDone)
                    }
                case .viewer:
                    ImageViewerDialog(table: options.table, field: field.key, id: options.item, localId: options.objectId)
            }
        }
    }
    
    func onSelectionDone(_ done: Bool) {
        self.shouldPresentSheet = false
        field.value = done ? "Y" : field.value
        if done {
            MediaUtils.store(uiImage: uiImage, table: options.table, field: field.key, id: options.item, localId: options.objectId)
        }
    }
    
}

struct DynamicFormCanvas: View {
    
    @Binding var field: DynamicFormField
    var options: DynamicFormFieldOptions

    @State private var drawDialog = false
    @State private var shouldPresentImageViewer = false
    
    @State private var uiImage: UIImage?
    
    var body: some View {
        let label = DynamicUtils.formatLabel(s: field.label).localized(defaultValue: field.label)
        VStack {
            VStack {
                Text(label)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
            }
            .frame(height: 44)
            .onTapGesture {
                drawDialog = true
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
                    ImageViewerDialog(table: options.table, field: field.key, id: options.item, localId: options.objectId)
                }
            }
        }
        .sheet(isPresented: $drawDialog, content: {
            CanvasDrawerDialog(uiImage: self.$uiImage, title: NSLocalizedString("env\(field.label.capitalized)", comment: field.label), onSelectionDone: onSelectionDone)
        })
    }
    
    func onSelectionDone(_ done: Bool) {
        self.drawDialog = false
        field.value = done ? "Y" : field.value
        if done {
            MediaUtils.store(uiImage: uiImage, table: options.table, field: field.key, id: options.item, localId: options.objectId)
        }
    }
    
}

struct DynamicFormDayMonth: View {
    
    @Binding var field: DynamicFormField
    
    @State private var modalMonth = false
    @State private var modalDay = false
    @State private var selectedMonth: Int = 0
    @State private var selectedDay: Int = 0
    
    var body: some View {
        let label = DynamicUtils.formatLabel(s: field.label).localized(defaultValue: field.label)
        VStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
            HStack {
                Button(action: {
                    modalMonth = true
                }) {
                    HStack {
                        VStack {
                            Text("envMonth")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                            Text(selectedMonth > 0 ? TimeUtils.monthName(m: selectedMonth) : NSLocalizedString("envChoose", comment: ""))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Image("ic-arrow-expand-more")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24, alignment: .center)
                            .foregroundColor(.cIcon)
                    }
                }
                Button(action: {
                    if selectedMonth > 0 {
                        modalDay = true
                    }
                }) {
                    HStack {
                        VStack {
                            Text("envDay")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                            Text(selectedDay > 0 ? String(selectedDay) : NSLocalizedString("envChoose", comment: ""))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Image("ic-arrow-expand-more")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24, alignment: .center)
                            .foregroundColor(.cIcon)
                    }
                }
            }
            DynamicFormDescriptionView(field: field)
        }
        .partialSheet(isPresented: $modalMonth) {
            DialogMonthPickerView { month in
                selectedMonth = month
                onSelectionDone()
                modalMonth = false
            }
        }
        .partialSheet(isPresented: $modalDay) {
            DialogMonthDayPickerView(month: $selectedMonth) { day in
                selectedDay = day
                onSelectionDone()
                modalDay = false
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        let value = field.value.components(separatedBy: "-")
        if !value.isEmpty {
            selectedMonth = Utils.castInt(value: value[0])
            if value.count > 1 {
                selectedDay = Utils.castInt(value: value[0])
            }
        }
    }
    
    func onSelectionDone() {
        field.value = "\(selectedMonth)-\(selectedDay)"
    }
    
}

struct DynamicFormList: View {
    
    @Binding var field: DynamicFormField
    
    @State var items = [ListItem]()
    @State var selected = [String]()
    @State var selectedLabel: String = ""
    @State var extraData: [String: Any] = [:]
    
    @State private var selectSourceDynamic = false
    @State private var selectSourceTable = false
    @State private var selectSourceServer = false
    
    @State private var capitalized = true
    
    var body: some View {
        let label = DynamicUtils.formatLabel(s: field.label).localized(defaultValue: field.label)
        Button(action: {
            print(field.source)
            switch field.sourceType {
                case "json":
                    selectSourceDynamic.toggle()
                case "table":
                    selectSourceTable.toggle()
                default:
                    selectSourceServer.toggle()
            }
        }) {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(label)
                            .font(selected.isEmpty ? .none : .system(size: 14.0))
                            .foregroundColor((field.localRequired && field.value.isEmpty) ? Color.cDanger : .cTextMedium)
                        if !selected.isEmpty {
                            Text(capitalized ? selectedLabel.capitalized : selectedLabel)
                                .foregroundColor(.cTextHigh)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Spacer()
                    Image("ic-arrow-expand-more")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24, alignment: .center)
                        .foregroundColor(.cIcon)
                }
                DynamicFormDescriptionView(field: field)
            }
        }
        .onAppear {
            load()
        }
        .sheet(isPresented: $selectSourceServer) {
            DialogSourcePickerView(selected: $selected, key: field.source, multiple: field.multiple, title: NSLocalizedString(label, comment: field.label), onSelectionDone: onSelectionDone)
        }
        .sheet(isPresented: $selectSourceDynamic, content: {
            DialogPlainPickerView(selected: $selected, data: field.source, multiple: field.multiple, title: NSLocalizedString(label, comment: field.label), onSelectionDone: onSelectionDone)
        })
        .sheet(isPresented: $selectSourceTable, content: {
            DialogSourcePickerView(selected: $selected, key: field.source, multiple: field.multiple, title: NSLocalizedString(label, comment: field.label), extraData: extraData, onSelectionDone: onSelectionDone)
        })
    }
    
    func load() {
        if !field.value.isEmpty {
            selected = field.value.components(separatedBy: ",")
            onSelectionDone([])
        }
        switch field.source {
            case "category":
                capitalized = false
                extraData["categoryType"] = field.moreOptions.categoryType
                break
            default:
                break
        }
    }
    
    func onSelectionDone(_ : [String]) {
        field.value = selected.joined(separator: ",")
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
                    selectedLabel = DynamicUtils.tableValue(key: field.source, selected: selected)
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
