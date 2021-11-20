//
//  PatientFormView.swift
//  PRO
//
//  Created by VMO on 18/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast

struct PatientFormView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var patient: Patient?
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    @StateObject var tabRouter = TabRouter()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "patient", op: "")
    
    var body: some View {
        VStack {
            HeaderToggleView(couldSearch: false, title: patient?.name ?? "modPatient", icon: Image("ic-patient"), color: Color.cPanelPatient)
            
            switch tabRouter.current {
            case "LOCATIONS":
                PanelLocationView(panel: patient, couldAdd: true)
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
            print("_________")
            print(options)
            tabRouter.current = "BASIC"
            initForm()
        }
    }
    
    func initForm() {
        
        if viewRouter.data.objectId.isEmpty {
            patient = Patient()
        } else {
            patient = Patient(value: try! PatientDao(realm: try! Realm()).by(objectId: ObjectId(string: viewRouter.data.objectId)) ?? Patient())
            plainData = try! Utils.objToJSON(patient)
            additionalData = patient?.additionalFields ?? "{}"
        }
        options.objectId = patient?.objectId
        options.item = patient?.id ?? 0
        options.op = viewRouter.data.objectId.isEmpty ? "create" : "update"
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_PAT_DYNAMIC_FORM").complement ?? "")
        
        initDynamic(data: dynamicData)
        
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        
        print("__________DATA__________")
        print(data)
        
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        
        print(form)
        print(form.id)
        print(form.tabs)
        
        if !plainData.isEmpty {
            DynamicUtils.fillForm(form: &form, base: plainData, additional: additionalData)
        }
    }
    
    func save(){
        print("ajjaja")
    }
    
    func onTabSelected(_ tab: String) {
        tabRouter.current = tab
    }
}
