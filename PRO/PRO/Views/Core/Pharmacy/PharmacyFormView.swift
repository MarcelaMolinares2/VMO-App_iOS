//
//  PharmacyFormView.swift
//  PRO
//
//  Created by VMO on 18/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast

struct PharmacyFormView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    
    @State var pharmacy: Pharmacy?
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "pharmacy", op: "")
    @State private var showValidationError = false
    
    @State var productsStock = [String]()
    
    var body: some View {
        VStack {
            HeaderToggleView(couldSearch: false, title: pharmacy?.name ?? "modPharmacy", icon: Image("ic-pharmacy"), color: Color.cPanelPharmacy)
            switch tabRouter.current {
                case "CONTACTS":
                    PanelContactView(panel: pharmacy, couldAdd: true)
                case "LOCATIONS":
                    PanelLocationView(panel: pharmacy, couldAdd: true)
                case "STOCK":
                    PanelStockView(selected: $productsStock, couldAdd: true)
                default:
                    ZStack(alignment: .bottomTrailing) {
                        ForEach(form.tabs, id: \.id) { tab in
                            if tab.key == tabRouter.current {
                                if let ix = form.tabs.firstIndex(where: { $0.key == tabRouter.current }) {
                                    Form {
                                        DynamicFormView(form: $form, tab: $form.tabs[ix], options: options)
                                    }
                                }
                            }
                        }
                        FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                            self.save()
                        }
                    }
            }
            BottomNavigationBarDynamic(onTabSelected: onTabSelected, currentTab: $tabRouter.current, tabs: $form.tabs, staticTabs: [viewRouter.data.objectId.isEmpty ? "" : "CONTACTS", "LOCATIONS", "STOCK"])
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
            pharmacy = Pharmacy()
        } else {
            pharmacy = Pharmacy(value: try! PharmacyDao(realm: try! Realm()).by(objectId: ObjectId(string: viewRouter.data.objectId)) ?? Pharmacy())
            plainData = try! Utils.objToJSON(pharmacy)
            additionalData = pharmacy?.additionalFields ?? "{}"
        }
        options.objectId = pharmacy?.objectId
        options.item = pharmacy?.id ?? 0
        options.op = viewRouter.data.objectId.isEmpty ? "create" : "update"
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_PHA_DYNAMIC_FORM").complement ?? "")
        
        initDynamic(data: dynamicData)
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        if !plainData.isEmpty {
            DynamicUtils.fillForm(form: &form, base: plainData, additional: additionalData)
        }
    }
    
    func save() {
        if DynamicUtils.validate(form: form) && pharmacy != nil {
            DynamicUtils.cloneObject(main: pharmacy, temporal: try! JSONDecoder().decode(Pharmacy.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!), skipped: ["objectId", "id", "type"])
            pharmacy?.additionalFields = DynamicUtils.generateAdditional(form: form)
            PharmacyDao(realm: try! Realm()).store(pharmacy: pharmacy!)
            viewRouter.currentPage = "MASTER"
        } else {
            showValidationError = true
        }
    }
    
    func onTabSelected(_ tab: String) {
        tabRouter.current = tab
    }
    
}
