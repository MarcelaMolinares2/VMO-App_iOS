//
//  RouteView.swift
//  PRO
//
//  Created by Fernando Garcia on 28/10/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast

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
    
    @ObservedResults(Group.self) var groups
    
    @State private var optionsModal = false
    @State private var groupSelected: Group = Group()
    
    var body: some View {
        ZStack {
            VStack{
                HeaderToggleView(couldSearch: true, title: "modPeopleRoute", icon: Image("ic-people-route"), color: Color.cPanelRequestDay)
                Spacer()
                List {
                    ForEach (groups, id: \.objectId){ item in
                        VStack {
                            RouteListCardView(item: item).onTapGesture {
                                self.groupSelected = item
                                self.optionsModal = true
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
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
        .partialSheet(isPresented: $optionsModal) {
            RouteBottomMenu(onEdit: onEdit, onDelete: onDelete, group: groupSelected)
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
    }
    
    func onEdit(_ group: Group) {
        self.optionsModal = false
        self.moduleRouter.objectId = group.objectId.stringValue
        self.moduleRouter.currentPage = "FORM"
    }
    
    func onDelete(_ group: Group) {
        self.optionsModal = false
        GroupDao(realm: try! Realm()).delete(group: group)
    }
    
}

struct RouteListCardView: View {
    
    var item: Group
    
    @State private var medics: Int = 0
    @State private var pharmacys: Int = 0
    @State private var clients: Int = 0
    @State private var patients: Int = 0
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 10)
            HStack{
                Text(item.name ?? "")
                    .foregroundColor(.black)
                Spacer()
            }
            Spacer()
            HStack{
                HStack{
                    Image("ic-medic")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 27)
                        .foregroundColor(medics == 0 ? Color.cPrimaryLight: Color.cPanelMedic)
                    Text(String(medics))
                    Spacer()
                    Image("ic-pharmacy")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 27)
                        .foregroundColor(pharmacys == 0 ? Color.cPrimaryLight: Color.cPanelPharmacy)
                    Text(String(pharmacys))
                    Spacer()
                }
                HStack {
                    Image("ic-client")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 27)
                        .foregroundColor(clients == 0 ? Color.cPrimaryLight: Color.cPanelClient)
                    Text(String(clients))
                    Spacer()
                    Image("ic-patient")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 27)
                        .foregroundColor(patients == 0 ? Color.cPrimaryLight: Color.cPanelPatient)
                    Text(String(patients))
                    Spacer()
                }
            }
            Spacer()
                .frame(height: 10)
        }
        .foregroundColor(.cPrimaryLight)
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        item.groupMemberList.forEach{ it in
            switch it.type {
                case "M":
                    medics += 1
                case "F":
                    pharmacys += 1
                case "C":
                    clients += 1
                case "P":
                    patients += 1
                default:
                    print("...")
            }
        }
    }
}

struct RouteFormView: View {
    @ObservedObject var moduleRouter: ModuleRouter
    @State private var name = ""
    @State private var items = [Panel & SyncEntity]()
    @State private var isValidationOn = false
    @State private var cardShow = false
    @State private var type = ""
    @State var searchText = ""
    
    @ObservedObject private var selectPanelModalToggle = ModalToggle()
    @State private var slDefault = [String]()
    @State private var slDoctors = [String]()
    @State private var slPharmacies = [String]()
    @State private var slClients = [String]()
    @State private var slPatients = [String]()
    @State private var colorWarning = Color.gray
    
    @State private var showToast = false
    @State private var textNoName = false
    
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
                VStack {
                    TextField(NSLocalizedString("envName", comment: ""), text: $name)
                    Divider()
                     .frame(height: 1)
                     .padding(.horizontal, 5)
                     .background(colorWarning)
                    if textNoName {
                        HStack {
                            Text(NSLocalizedString("noneNameGroups", comment: ""))
                                .foregroundColor(colorWarning)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                List {
                    ForEach(items, id: \.objectId) { item in
                        HStack(alignment: .center, spacing: 10){
                            switch item.type {
                                case "M":
                                    Image("ic-medic")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 27)
                                        .foregroundColor(Color.cPanelMedic)
                                case "F":
                                    Image("ic-pharmacy")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 27)
                                        .foregroundColor(Color.cPanelPharmacy)
                                case "C":
                                    Image("ic-client")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 27)
                                        .foregroundColor(Color.cPanelClient)
                                case "P":
                                    Image("ic-patient")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 27)
                                        .foregroundColor(Color.cPanelPatient)
                                default:
                                    Text("default")
                            }
                            PanelItem(panel: item)
                        }
                    }
                    .onDelete { (offsets: IndexSet) in
                        var its: Int = 0
                        var type: String = ""
                        offsets.forEach{ it in
                            type = items[it].type
                            its = items[it].id
                        }
                        selected[type]?.binding.removeAll(where: { $0 == String(its) })
                        self.items.remove(atOffsets: offsets)
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                        if !name.replacingOccurrences(of: " ", with: "").isEmpty {
                            let gr = Group()
                            gr.name = name
                            for i in items {
                                let grM = GroupMember()
                                grM.type = i.type
                                grM.idPanel = i.id
                                gr.groupMemberList.append(grM)
                            }
                            GroupDao(realm: try! Realm()).store(group: gr)
                            moduleRouter.currentPage = "LIST"
                        } else {
                            colorWarning = Color.cWarning
                            name = ""
                            textNoName = true
                        }
                    }
                }
                .toast(isPresenting: $showToast){
                    AlertToast(type: .regular, title: NSLocalizedString("noneGroups", comment: ""))
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
                    var exists = false
                    selected[self.type]?.binding.forEach{ it in
                        switch self.type {
                        case "M":
                            if let doctor = DoctorDao(realm: try! Realm()).by(id: it){
                                for i in items {
                                    if String(i.id) == it {
                                        exists = true
                                    }
                                }
                                if !exists {
                                    items.append(doctor)
                                }
                                exists = false
                            }
                        case "F":
                            if let pharmacy = PharmacyDao(realm: try! Realm()).by(id: it){
                                for i in items {
                                    if String(i.id) == it {
                                        exists = true
                                    }
                                }
                                if !exists {
                                    items.append(pharmacy)
                                }
                                exists = false
                            }
                        case "C":
                            if let client = ClientDao(realm: try! Realm()).by(id: it){
                                for i in items {
                                    if String(i.id) == it {
                                        exists = true
                                    }
                                }
                                if !exists {
                                    items.append(client)
                                }
                                exists = false
                            }
                        case "P":
                            if let patient = PatientDao(realm: try! Realm()).by(id: it){
                                for i in items {
                                    if String(i.id) == it {
                                        exists = true
                                    }
                                }
                                if !exists {
                                    items.append(patient)
                                }
                                exists = false
                            }
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
        .onAppear {
            load()
        }
    }
    
    func load() {
        if moduleRouter.objectId.isEmpty {
            if let g = try? GroupDao(realm: try! Realm()).by(objectId: ObjectId(string: moduleRouter.objectId)) {
                print("_______g_______")
                print(g)
            }
        } else {
        }
    }
    
    private func delete(at offsets: IndexSet) {
        self.items.remove(atOffsets: offsets)
    }
    
    func onPanelSelected (_ type: String) {
        self.cardShow.toggle()
        self.type = type
        selectPanelModalToggle.status.toggle()
        //print(items)
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
