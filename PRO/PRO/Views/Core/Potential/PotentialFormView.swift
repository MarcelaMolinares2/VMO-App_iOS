//
//  PotentialFormView.swift
//  PRO
//
//  Created by VMO on 18/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast

struct PotentialFormView: View {
    
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    
    @State var potential: PotentialProfessional?
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "potentialProfessional", op: "")
    @State private var showValidationError = false
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modPotentialProfessional") {
                
            }
            switch tabRouter.current {
            case "LOCATIONS":
                PanelLocationView(panel: potential, couldAdd: true)
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
                    FAB(image: "ic-cloud") {
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
            potential = PotentialProfessional()
        } else {
            potential = PotentialProfessional(value: try! PotentialDao(realm: try! Realm()).by(objectId: ObjectId(string: viewRouter.data.objectId)) ?? Patient())
            plainData = try! Utils.objToJSON(potential)
            additionalData = potential?.fields ?? "{}"
        }
        options.objectId = potential!.objectId
        options.item = potential?.id ?? 0
        options.op = viewRouter.data.objectId.isEmpty ? "create" : "update"
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_PPT_DYNAMIC_FORM").complement ?? "")
        
        initDynamic(data: dynamicData)
        
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        
        if !plainData.isEmpty {
            DynamicUtils.fillForm(form: &form, base: plainData, additional: additionalData)
        }
    }
    
    func save(){
        if DynamicUtils.validate(form: form) && potential != nil {
            DynamicUtils.cloneObject(main: potential, temporal: try! JSONDecoder().decode(PotentialProfessional.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!), skipped: ["objectId", "id", "type"])
            potential?.fields = DynamicUtils.generateAdditional(form: form)
            PotentialDao(realm: try! Realm()).store(potential: potential!)
            viewRouter.currentPage = "POTENTIAL-LIST"
        } else {
            showValidationError = true
        }
    }
    
    func onTabSelected(_ tab: String) {
        tabRouter.current = tab
    }
    
}
