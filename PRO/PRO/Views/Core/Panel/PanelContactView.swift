//
//  PanelContactView.swift
//  PRO
//
//  Created by VMO on 22/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast

struct PanelContactView: View {
    
    var panel: Panel!
    @State var couldAdd = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
        }
    }
    
}

struct PanelContactListView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @ObservedResults(Contact.self, sortDescriptor: SortDescriptor(keyPath: "name", ascending: true)) var contacts
    @Binding var searchText: String
    @State var menuIsPresented = false
    @State var panel: Panel & SyncEntity = GenericPanel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                PanelListHeader(total: contacts.count) {
                    
                }
                ScrollView {
                    LazyVStack {
                        ForEach(contacts.filter {
                            self.searchText.isEmpty ? true :
                                ($0.name ?? "").lowercased().contains(self.searchText.lowercased())
                        }, id: \.objectId) { element in
                            PanelItem(panel: element).onTapGesture {
                                self.panel = element
                                self.menuIsPresented = true
                            }
                        }
                    }
                }
            }
            FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                FormEntity(objectId: "").go(path: PanelUtils.formByPanelType(type: "CT"), router: viewRouter)
            }
        }
        .partialSheet(isPresented: $menuIsPresented) {
            PanelMenu(isPresented: self.$menuIsPresented, panel: panel)
        }
    }
    
}


struct PanelContactFormView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    
    @State var contact: Contact?
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "contact", op: "")
    @State private var showValidationError = false
    
    var body: some View {
        VStack {
            HeaderToggleView(couldSearch: false, title: contact?.name ?? "modContact", icon: Image("ic-contact"), color: Color.cPanelMedic)
            switch tabRouter.current {
                case "LOCATIONS":
                    PanelLocationView(panel: contact, couldAdd: true)
                default:
                    ZStack(alignment: .bottomTrailing) {
                        ForEach(form.tabs, id: \.id) { tab in
                            if tab.key == tabRouter.current {
                                if let ix = form.tabs.firstIndex(where: { $0.key == tabRouter.current }) {
                                    DynamicFormView(form: $form, tab: $form.tabs[ix], options: options)
                                }
                            }
                        }
                        FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                            self.save()
                        }
                    }
            }
            BottomNavigationBarDynamic(onTabSelected: onTabSelected, currentTab: $tabRouter.current, tabs: $form.tabs, staticTabs: ["LOCATIONS"])
        }
        .onAppear {
            tabRouter.current = "BASIC"
            initForm()
        }
        .toast(isPresenting: $showValidationError) {
            AlertToast(type: .regular, title: NSLocalizedString("errFormValidation", comment: ""))
        }
    }
    
    func initForm() {
        if viewRouter.data.objectId.isEmpty {
            contact = Contact()
        } else {
            contact = Contact(value: try! ContactDao(realm: try! Realm()).by(objectId: ObjectId(string: viewRouter.data.objectId)) ?? Contact())
            plainData = try! Utils.objToJSON(contact)
            additionalData = contact?.additionalFields ?? "{}"
        }
        options.objectId = contact?.objectId
        options.item = contact?.id ?? 0
        options.op = viewRouter.data.objectId.isEmpty ? "create" : "update"
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_CTC_DYNAMIC_FORM").complement ?? "")
        
        initDynamic(data: dynamicData)
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        if !plainData.isEmpty {
            DynamicUtils.fillForm(form: &form, base: plainData, additional: additionalData)
        }
    }
    
    func save() {
        if DynamicUtils.validate(form: form) && contact != nil {
            DynamicUtils.cloneObject(main: contact, temporal: try! JSONDecoder().decode(Contact.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!), skipped: ["objectId", "id", "type"])
            contact?.additionalFields = DynamicUtils.generateAdditional(form: form)
            ContactDao(realm: try! Realm()).store(contact: contact!)
            viewRouter.currentPage = "MASTER"
        } else {
            showValidationError = true
        }
    }
    
    func onTabSelected(_ tab: String) {
        tabRouter.current = tab
    }
    
}

