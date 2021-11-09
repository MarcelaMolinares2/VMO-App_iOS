//
//  RouteView.swift
//  PRO
//
//  Created by Fernando Garcia on 28/10/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct RouteView: View {
    @ObservedObject private var moduleRouter = ModuleRouter()
    var body: some View {
        switch moduleRouter.currentPage {
        case "LIST":
            RouteListView(moduleRouter: moduleRouter)
        case "FORM":
            RouteFormView(moduleRouter: moduleRouter)
        default:
            Text("")
        }
    }
}

struct RouteListView: View {
    @ObservedObject var moduleRouter: ModuleRouter
    var body: some View {
        ZStack {
            VStack{
                HeaderToggleView(couldSearch: true, title: "modPeopleRoute", icon: Image("ic-people-route"), color: Color.cPanelRequestDay)
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                        moduleRouter.currentPage = "FORM"
                    }
                }
            }
        }
    }
}

struct RouteFormView: View {
    @ObservedObject var moduleRouter: ModuleRouter
    @State private var name = ""
    //@State private var items: [Panel & SyncEntity] = []
    @State private var items = [Panel & SyncEntity]()
    @State private var isValidationOn = false
    @State private var cardShow = false
    @State private var type = ""
    
    @ObservedObject private var selectPanelModalToggle = ModalToggle()
    @State private var slDefault = [String]()
    @State private var slDoctors = [String]()
    @State private var slPharmacies = [String]()
    @State private var slClients = [String]()
    @State private var slPatients = [String]()
    
    var body: some View {
        let selected = [
            "M": BindingWrapper(binding: $slDoctors),
            "F": BindingWrapper(binding: $slPharmacies),
            "C": BindingWrapper(binding: $slClients),
            "P": BindingWrapper(binding: $slPatients)
        ]
        ZStack {
            VStack {
                HeaderToggleView(couldSearch: false, title: "modPeopleRoute", icon: Image("ic-people-route"), color: Color.cPanelRequestDay)
                VStack{
                    TextField(NSLocalizedString("envName", comment: ""), text: $name)
                    Divider()
                     .frame(height: 1)
                     .padding(.horizontal, 5)
                     .background(Color.gray)
                }.padding(10)
                List {
                    ForEach(items, id: \.objectId) { item in
                        PanelItem(panel: item)
                    }
                    .onDelete(perform: self.delete)
                }
                /*
                ScrollView {
                    LazyVStack {
                        
                        /*
                        ForEach (selected.$binding, id: \.id) { element in
                            Text(element)
                        }
                        */
                        ForEach(items, id: \.objectId) { it in
                            PanelItem(panel: it)
                            
                        }
                        .onDelete(perform: self.delete)
                        /*
                        ForEach(items, id: \.id) { element in
                            PanelItem(panel: element)
                        }
                        */
                        
                    }
                }
                */
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                        if validate() {
                            save()
                        }
                        moduleRouter.currentPage = "LIST"
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                        cardShow.toggle()
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
            if selectPanelModalToggle.status {
                GeometryReader {geo in
                    PanelDialogPicker(modalToggle: selectPanelModalToggle, selected: selected[self.type]?.$binding ?? $slDefault, type: self.type, multiple: true)
                }
                .background(Color.black.opacity(0.45))
                .onDisappear {
                    selected[self.type]?.binding.forEach{ it in
                        switch self.type {
                        case "M":
                            if let doctor = DoctorDao(realm: try! Realm()).by(id: it){
                                items.append(doctor)
                            }
                        case "F":
                            items.append(contentsOf: [PharmacyDao(realm: try! Realm()).by(id: it) ?? Pharmacy()])
                        case "C":
                            items.append(contentsOf: [ClientDao(realm: try! Realm()).by(id: it) ?? Client()])
                        case "P":
                            items.append(contentsOf: [PatientDao(realm: try! Realm()).by(id: it) ?? Patient()])
                        default:
                            break
                        }
                    }
                }
            }
        }
        .partialSheet(isPresented: self.$cardShow) {
            PanelTypeMenu(onPanelSelected: onPanelSelected, panelTypes: ["M", "F", "C", "P"], isPresented: self.$cardShow)
        }
    }
    
    
    private func delete(at offsets: IndexSet) {
        self.items.remove(atOffsets: offsets)
    }
    
    func onPanelSelected (_ type: String) {
        self.cardShow.toggle()
        self.type = type
        selectPanelModalToggle.status.toggle()
        print(items)
    }
    
    func validate() -> Bool {
        isValidationOn = true
        if items.isEmpty {
            return false
        }
        return true
    }
    
    func save() {
        
    }
    
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        RouteView()
    }
}
