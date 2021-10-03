//
//  DynamicFormView.swift
//  PRO
//
//  Created by VMO on 7/01/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI

struct DynamicFormView: View {
    
    @Binding var tab: DynamicFormTab
    
    var body: some View {
        Form {
            ForEach(tab.groups.indices) { index in
                DynamicFormSection(group: $tab.groups[index])
            }
        }
    }
}

struct DynamicFormSection: View {
    
    @Binding var group: DynamicFormTab.DynamicFormGroup
    
    var body: some View {
        Section(header: Text(group.title)) {
            ForEach(group.fields.indices) { index in
                switch(group.fields[index].controlType) {
                case "textfield":
                    DynamicFormTextField(field: $group.fields[index])
                default:
                    Text("A")
                }
            }
        }
    }
}

struct DynamicFormTextField: View {
    
    @Binding var field: DynamicFormTab.DynamicFormGroup.DynamicFormField
    
    var body: some View {
        VStack {
            Text("env\(field.label.capitalized)")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $field.value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct DynamicFormList: View {
    
    @Binding var field: DynamicFormTab.DynamicFormGroup.DynamicFormField
    @State private var selectedValue = -1
    
    @State var items = [ListItem]()
    
    var body: some View {
        Picker("env\(field.label.capitalized)", selection: $selectedValue) {
            ForEach(items, id: \.id) { item in
                Text(item.value).tag(item.id)
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        switch field.sourceType {
        case "table":
            print("table")
            /*switch field.source {
            case "colleges":
                <#code#>
            default:
                <#code#>
            }*/
        case "json":
            let data = Utils.jsonDictionary(string: field.source)
            data.forEach { (key: String, value: Any) in
                items.append(ListItem(id: key, value: Utils.castString(value: value)))
            }
        default:
            //values
            print("default")
        }
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
