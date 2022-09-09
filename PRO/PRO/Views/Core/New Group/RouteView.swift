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
    
    @State private var search = ""
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack{
                HeaderToggleView(search: $search, title: "modRoutes")
                ScrollView {
                    ForEach (groups, id: \.objectId){ item in
                        RouteListCardView(item: item).onTapGesture {
                            self.groupSelected = item
                            self.optionsModal = true
                        }
                    }
                }
            }
            HStack {
                Spacer()
                FAB(image: "ic-plus") {
                    self.moduleRouter.objectId = nil
                    moduleRouter.currentPage = "FORM"
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
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
        self.moduleRouter.objectId = group.objectId
        self.moduleRouter.currentPage = "FORM"
    }
    
    func onDelete(_ group: Group) {
        self.optionsModal = false
        GroupDao(realm: try! Realm()).delete(group: group)
    }
    
}

struct RouteListCardView: View {
    
    var item: Group
    
    var body: some View {
        VStack {
            CustomCard {
                Text(item.name)
                    .foregroundColor(.cTextHigh)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                HStack {
                    HStack {
                        let doctors = item.members.filter { $0.panelType == "M" }.count
                        Image("ic-doctor")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundColor(doctors == 0 ? Color.cIconLight : Color.cPanelMedic)
                        Text(String(doctors))
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    HStack {
                        let pharmacies = item.members.filter { $0.panelType == "F" }.count
                        Image("ic-pharmacy")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundColor(pharmacies == 0 ? Color.cIconLight : Color.cPanelPharmacy)
                        Text(String(pharmacies))
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    HStack {
                        let clients = item.members.filter { $0.panelType == "C" }.count
                        Image("ic-client")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundColor(clients == 0 ? Color.cIconLight : Color.cPanelClient)
                        Text(String(clients))
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    HStack {
                        let patients = item.members.filter { $0.panelType == "P" }.count
                        Image("ic-patient")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundColor(patients == 0 ? Color.cIconLight : Color.cPanelPatient)
                        Text(String(patients))
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
    }
    
}

class PanelItemModel: Identifiable {
    var objectId: ObjectId
    var type: String = ""
    
    init(objectId: ObjectId, type: String) {
        self.objectId = objectId
        self.type = type
    }
}

struct RouteFormView: View {
    @ObservedObject var moduleRouter: ModuleRouter
    
    @State private var modalPanelType = false
    @State private var routeName = ""
    
    @State var group: Group?
    
    @State private var layout: ViewLayout = .list
    
    @State private var members = [PanelItemModel]()
    
    @State private var showToast = false
    @State private var savedToast = false
    
    var realm = try! Realm()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HeaderToggleView(title: "modRoute") {
                    moduleRouter.currentPage = "LIST"
                }
                VStack {
                    CustomCard {
                        Text("envName")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(routeName.isEmpty ? Color.cDanger : .cTextMedium)
                        TextField("envName", text: $routeName)
                            .cornerRadius(CGFloat(4))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal, Globals.UI_FORM_PADDING_HORIZONTAL)
                PanelSelectWrapperView(realm: realm, types: ["M", "F", "C", "P"], members: $members, modalPanelType: $modalPanelType)
            }
            HStack(alignment: .bottom) {
                VStack(spacing: 10) {
                    FAB(image: "ic-map") {
                        
                    }
                    FAB(image: "ic-plus") {
                        modalPanelType = true
                    }
                }
                Spacer()
                FAB(image: "ic-cloud") {
                    validate()
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .toast(isPresenting: $showToast) {
            AlertToast(type: .error(.cError), title: NSLocalizedString("errFormEmpty", comment: ""))
        }
        .toast(isPresenting: $savedToast) {
            AlertToast(type: .complete(.cDone), title: NSLocalizedString("envSuccessfullySaved", comment: ""))
        }
        .onAppear {
            initForm()
        }
    }
    
    func initForm() {
        if let obId = moduleRouter.objectId {
            group = Group(value: GroupDao(realm: realm).by(objectId: obId) ?? Group())
            routeName = group?.name ?? ""
            members.removeAll()
            group?.members.forEach{ gm in
                if let panel = PanelUtils.panel(type: gm.panelType, objectId: gm.panelObjectId, id: gm.panelId) {
                    members.append(PanelItemModel(objectId: panel.objectId, type: gm.panelType))
                }
            }
        } else {
            group = Group()
        }
    }
    
    func validate() {
        if routeName.isEmpty {
            showToast = true
            return
        }
        save()
    }
    
    func save() {
        group?.name = routeName
        group?.members.removeAll()
        members.forEach { pim in
            let member = GroupMember()
            member.panelObjectId = pim.objectId
            member.panelId = PanelUtils.panel(type: pim.type, objectId: pim.objectId)?.id ?? 0
            member.panelType = pim.type
            group?.members.append(member)
        }
        GroupDao(realm: realm).store(group: group!)
        goTo()
    }
    
    func goTo() {
        savedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Globals.ENV_SAVE_DELAY) {
            moduleRouter.currentPage = "LIST"
        }
    }
    
}
