//
//  DialogPickers.swift
//  PRO
//
//  Created by VMO on 24/08/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

class ListGenericViewModel: ObservableObject {

    @Published var items: [GenericSelectableItem] = [GenericSelectableItem]()
    
    func put(list: [GenericSelectableItem]) {
        items = list
    }
    
    func toggle() {
        let tmp = items
        items = tmp
    }

}

class ListPanelViewModel: ObservableObject {

    @Published var items: [GenericSelectablePanelItem] = [GenericSelectablePanelItem]()
    
    func put(list: [GenericSelectablePanelItem]) {
        items = list
    }
    
    func toggle() {
        let tmp = items
        items = tmp
    }

}

struct PanelDialogPicker: View {
    
    @ObservedObject var modalToggle: ModalToggle
    @Binding var selected: [String]
    var type: String = ""
    var multiple: Bool = false
    var skip: Bool = false
    
    @ObservedObject var viewModel = ListPanelViewModel()
    @StateObject var headerRouter = TabRouter()
    @State var searchText = ""
    let headerHeight = CGFloat(40)
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                HStack {
                    Button(action: {
                        self.modalToggle.status.toggle()
                    }) {
                        Image("ic-left-arrow")
                            .resizable()
                            .scaledToFit()
                            .padding(5)
                    }
                    SearchBar(headerRouter: self.headerRouter, text: $searchText, placeholder: Text("Buscar"))
                }
                .frame(height: headerHeight)
                .padding([.leading, .trailing], 10)
                .background(Color.white)
                .zIndex(1)
                List {
                    Color
                        .clear
                        .frame(height: 30)
                    ForEach(viewModel.items.filter {
                        searchText.isEmpty ? true : ($0.panel.name ?? "").lowercased().contains(searchText.lowercased())
                    }, id: \.panel.id) { item in
                        ZStack {
                            if item.selected {
                                Color
                                    .cSelected
                                    .ignoresSafeArea()
                                    .cornerRadius(15)
                            }
                            PanelItem(panel: item.panel).onTapGesture {
                                self.onItemSelected(item: item)
                            }
                        }
                    }
                }
            }
            if multiple {
                VStack {
                    Button(action: {
                        self.done()
                    }) {
                        Image("ic-done")
                            .resizable()
                            .foregroundColor(.cTextHigh)
                            .scaledToFit()
                            .padding(5)
                    }
                }
                .frame(height: headerHeight)
                .padding([.leading, .trailing], 10)
                .background(Color.white)
                .zIndex(1)
            }
        }
        .background(Color.white)
        .padding(20)
        .clipped()
        .cornerRadius(20)
        .onAppear {
            self.load()
        }
    }
    
    func load() {
        var list = [Panel & SyncEntity]()
        switch type {
        case "M":
            list = DoctorDao(realm: try! Realm()).all()
        case "F":
            list = PharmacyDao(realm: try! Realm()).all()
        case "C":
            list = ClientDao(realm: try! Realm()).all()
        case "P":
            list = PatientDao(realm: try! Realm()).all()
        default:
            break
        }
        var cleanedList = [GenericSelectablePanelItem]()
        if skip {
            
        } else {
            cleanedList = list.map { GenericSelectablePanelItem(panel: $0) }
            for item in cleanedList {
                item.selected = selected.contains("\(item.panel.id)")
            }
        }
        viewModel.put(list: cleanedList)
    }
    
    func onItemSelected(item: GenericSelectablePanelItem) {
        item.selected = !item.selected
        viewModel.toggle()
        if !multiple {
            done()
        }
    }
    
    func done() {
        selected = viewModel.items.filter { item in item.selected }.map { "\($0.panel.id)" }
        modalToggle.status.toggle()
    }
    
}

struct GenericDialogItem: View {
    var item: GenericSelectableItem
    var alignment: Alignment
    let onItemTapped: () -> Void
    
    var body: some View {
        Button(action: {
            self.onItemTapped()
        }) {
            ZStack {
                if item.selected {
                    Color
                        .cSelected
                        .ignoresSafeArea()
                        .cornerRadius(15)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: .infinity)
                }
                VStack(alignment: .leading) {
                    Text("\(item.label)")
                        .foregroundColor(.cTextHigh)
                    if !item.complement.isEmpty {
                        Text("\(item.complement)")
                            .foregroundColor(.cTextMedium)
                            .lineLimit(2)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: alignment)
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 5)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40)
        }
    }
    
}

struct SourceDynamicDialogPicker: View {
    let onSelectionDone: (_ selected: [String]) -> Void
    
    @Binding var selected: [String]
    var data: String = ""
    var multiple: Bool = false
    var isSheet: Bool = false
    
    @ObservedObject var viewModel = ListGenericViewModel()
    @StateObject var headerRouter = TabRouter()
    @State var searchText = ""
    let headerHeight = CGFloat(40)
    
    var body: some View {
        VStack {
            HStack {
                if !isSheet {
                    Button(action: {
                        done()
                    }) {
                        Image("ic-left-arrow")
                            .resizable()
                            .scaledToFit()
                            .padding(5)
                    }
                }
                SearchBar(headerRouter: self.headerRouter, text: $searchText, placeholder: Text("Buscar"))
            }
            .frame(height: headerHeight)
            .padding([.leading, .trailing], 10)
            .background(Color.white)
            .zIndex(1)
            if !isSheet ||  CGFloat(viewModel.items.count * 50) > CGFloat(UIScreen.main.bounds.height - (200 + (multiple ? 50 : 0))) {
                List {
                    ForEach(viewModel.items.filter {
                        searchText.isEmpty ? true : $0.label.lowercased().contains(searchText.lowercased())
                    }, id: \.id) { item in
                        GenericDialogItem(item: item, alignment: .leading) {
                            self.onItemSelected(item: item)
                        }
                    }
                }
            } else {
                ForEach(viewModel.items.filter {
                    searchText.isEmpty ? true : $0.label.lowercased().contains(searchText.lowercased())
                }, id: \.id) { item in
                    GenericDialogItem(item: item, alignment: .center) {
                        self.onItemSelected(item: item)
                    }
                }
            }
            if multiple {
                VStack {
                    Button(action: {
                        self.done()
                    }) {
                        Image("ic-done")
                            .resizable()
                            .foregroundColor(.cTextHigh)
                            .scaledToFit()
                            .padding(5)
                    }
                }
                .frame(height: headerHeight)
                .padding([.leading, .trailing], 10)
                .background(Color.white)
                .zIndex(1)
            }
        }
        .background(Color.white)
        .padding(20)
        .clipped()
        .cornerRadius(20)
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        var list = [GenericSelectableItem]()
        let json = Utils.jsonObject(string: data)
        for item in json {
            list.append(GenericSelectableItem(id: Utils.castString(value: item["id"]), label: Utils.castString(value: item["label"])))
        }
        viewModel.put(list: list)
    }
    
    func onItemSelected(item: GenericSelectableItem) {
        item.selected = !item.selected
        viewModel.toggle()
        if !multiple {
            done()
        }
    }
    
    func done() {
        selected = viewModel.items.filter { item in item.selected }.map { $0.id }
        onSelectionDone(selected)
    }
    
}

struct CustomDialogPicker: View {
    let onSelectionDone: (_ selected: [String]) -> Void
    
    @Binding var selected: [String]
    var key: String = ""
    var multiple: Bool = false
    var isSheet: Bool = false
    
    @ObservedObject var viewModel = ListGenericViewModel()
    @StateObject var headerRouter = TabRouter()
    @State var searchText = ""
    let headerHeight = CGFloat(40)
    
    var body: some View {
        VStack {
            HStack {
                if !isSheet {
                    Button(action: {
                        done()
                    }) {
                        Image("ic-left-arrow")
                            .resizable()
                            .scaledToFit()
                            .padding(5)
                    }
                }
                SearchBar(headerRouter: self.headerRouter, text: $searchText, placeholder: Text("Buscar"))
            }
            .frame(height: headerHeight)
            .padding([.leading, .trailing], 10)
            .background(Color.white)
            .zIndex(1)
            if !isSheet ||  CGFloat(viewModel.items.count * 50) > CGFloat(UIScreen.main.bounds.height - (200 + (multiple ? 50 : 0))) {
                List {
                    ForEach(viewModel.items.filter {
                        searchText.isEmpty ? true : $0.label.lowercased().contains(searchText.lowercased())
                    }, id: \.id) { item in
                        GenericDialogItem(item: item, alignment: .leading) {
                            self.onItemSelected(item: item)
                        }
                    }
                }
            } else {
                ForEach(viewModel.items.filter {
                    searchText.isEmpty ? true : $0.label.lowercased().contains(searchText.lowercased())
                }, id: \.id) { item in
                    GenericDialogItem(item: item, alignment: .center) {
                        self.onItemSelected(item: item)
                    }
                }
            }
            if multiple {
                VStack {
                    Button(action: {
                        self.done()
                    }) {
                        Image("ic-done")
                            .resizable()
                            .foregroundColor(.cTextHigh)
                            .scaledToFit()
                            .padding(5)
                    }
                }
                .frame(height: headerHeight)
                .padding([.leading, .trailing], 10)
                .background(Color.white)
                .zIndex(1)
            }
        }
        .background(Color.white)
        .padding(20)
        .clipped()
        .cornerRadius(20)
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        switch key {
        case "CYCLE":
            viewModel.put(list: GenericSelectableDao(realm: try! Realm()).cycles())
        case "MATERIAL":
            viewModel.put(list: GenericSelectableDao(realm: try! Realm()).materials())
        default:
            break
        }
    }
    
    func onItemSelected(item: GenericSelectableItem) {
        item.selected = !item.selected
        viewModel.toggle()
        if !multiple {
            done()
        }
    }
    
    func done() {
        selected = viewModel.items.filter { item in item.selected }.map { $0.id }
        onSelectionDone(selected)
    }
}
