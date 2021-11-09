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
    
    var body: some View {
        Form {
            ForEach(tab.groups.indices) { index in
                DynamicFormSection(form: $form, group: $tab.groups[index])
            }
        }
    }
}

struct DynamicFormSection: View {
    
    @Binding var form: DynamicForm
    @Binding var group: DynamicFormGroup
    
    var body: some View {
        Section(header: Text(group.title)) {
            ForEach(group.fields.indices) { index in
                DynamicFieldView(form: $form, field: $group.fields[index])
            }
        }
    }
}

struct DynamicFieldView: View {
    
    @Binding var form: DynamicForm
    @Binding var field: DynamicFormField
    @State var editable: Bool = true
    @State var required: Bool = false
    @State var visible: Bool = true
    
    var body: some View {
        if visible {
            switch(field.controlType) {
            case "text-field":
                DynamicFormTextField(field: $field, required: $required, editable: $editable)
            case "list":
                DynamicFormList(field: $field, required: $required, editable: $editable)
            default:
                Text("A")
            }
        }
    }
    
    func isRequired() {
        
    }
    
    func isVisible() {
        
    }
    
}

struct DynamicFormTextField: View {
    
    @Binding var field: DynamicFormField
    @Binding var required: Bool
    @Binding var editable: Bool
    
    var body: some View {
        VStack {
            Text(NSLocalizedString("env\(field.label.capitalized)", comment: field.label))
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("env\(field.label.capitalized)", text: $field.value)
                .border(Color.cFieldBorder)
                .cornerRadius(CGFloat(4))
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct DynamicFormList: View {
    
    @Binding var field: DynamicFormField
    @Binding var required: Bool
    @Binding var editable: Bool
    
    @State var items = [ListItem]()
    @State var selected = [String]()
    
    @ObservedObject var selectSourceDynamic = ModalToggle()
    @ObservedObject var selectSourceTable = ModalToggle()
    @ObservedObject var selectSourceServer = ModalToggle()
    
    @State private var cardShow = false
    
    var body: some View {
        Button(action: {
            switch field.sourceType {
            case "json":
                selectSourceDynamic.status.toggle()
                cardShow.toggle()
            case "table":
                selectSourceTable.status.toggle()
            default:
                selectSourceServer.status.toggle()
            }
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("env\(field.label.capitalized)", comment: field.label))
                        .font(selected.isEmpty ? .none : .system(size: 14.0))
                        .foregroundColor(selected.isEmpty ? .cTextMedium : .cTextHigh)
                    if !selected.isEmpty {
                        /*Text(eps.filter { $0.id == selectedEPS }[0].name ?? "")
                            .foregroundColor(.cTextSelected)
                            .lineLimit(1)
                        */
                        Text("Selected")
                    }
                }
                Spacer()
                Image("ic-arrow-right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10, alignment: .center)
                    .foregroundColor(.cAccent)
            }
        }
        .partialSheet(isPresented: $cardShow) {
            SourceDynamicDialogPicker(onSelectionDone: onSelectionDone, selected: $selected, data: field.source, multiple: field.multiple)
        }
    }
    
    func onSelectionDone(_ selected: [String]) {
        print(selected)
        cardShow.toggle()
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
