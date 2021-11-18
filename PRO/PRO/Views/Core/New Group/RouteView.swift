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
    @State private var saveGroup: Group = Group()
    @State private var contentItems: Bool = false
    @State private var cardShow = false
    @State private var type = ""
    
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
                            save()
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
                    selected[self.type]?.binding.forEach{ it in
                        addPanelItems(type: self.type, it: it)
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
        if !moduleRouter.objectId.isEmpty {
            contentItems = true
            if let group = try? GroupDao(realm: try! Realm()).by(objectId: ObjectId(string: moduleRouter.objectId)) {
                saveGroup = group
                name = group.name ?? ""
                group.groupMemberList.forEach { i in
                    addPanelItems(type: i.type ?? "", it: String(i.idPanel))
                }
            }
        }
    }
    
    func addPanelItems(type: String, it: String){
        switch type {
        case "M":
            if let doctor = DoctorDao(realm: try! Realm()).by(id: it){
                if !validate(items: items, it: it) {
                    items.append(doctor)
                }
            }
        case "F":
            if let pharmacy = PharmacyDao(realm: try! Realm()).by(id: it){
                if !validate(items: items, it: it) {
                    items.append(pharmacy)
                }
            }
        case "C":
            if let client = ClientDao(realm: try! Realm()).by(id: it){
                if !validate(items: items, it: it) {
                    items.append(client)
                }
            }
        case "P":
            if let patient = PatientDao(realm: try! Realm()).by(id: it){
                if !validate(items: items, it: it) {
                    items.append(patient)
                }
            }
        default:
            break
        }
    }
    
    func save(){
        if saveGroup != Group() {
            let gr = Group()
            gr.objectId = saveGroup.objectId
            gr.name = name
            items.forEach{ i in
                gr.groupMemberList.append(addGroupMemberList(i: i))
            }
            GroupDao(realm: try! Realm()).store(group: gr)
            moduleRouter.objectId = ""
            moduleRouter.currentPage = "LIST"
        } else {
            saveGroup.name = name
            items.forEach{ i in
                saveGroup.groupMemberList.append(addGroupMemberList(i: i))
            }
            GroupDao(realm: try! Realm()).store(group: saveGroup)
            moduleRouter.currentPage = "LIST"
            
        }
    }
    
    func addGroupMemberList(i: Panel & SyncEntity) -> GroupMember{
        let grM = GroupMember()
        grM.type = i.type
        grM.idPanel = i.id
        return grM
    }
    
    func validate(items: [Panel & SyncEntity], it: String) -> Bool {
        var exists: Bool = false
        items.forEach{ i in
            if String(i.id) == it {
                exists = true
            }
        }
        return exists
    }
    
    func onPanelSelected(_ type: String) {
        self.cardShow.toggle()
        self.type = type
        selectPanelModalToggle.status.toggle()
    }
    
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        RouteView()
    }
}
