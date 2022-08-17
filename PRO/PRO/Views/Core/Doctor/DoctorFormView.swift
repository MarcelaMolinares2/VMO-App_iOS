//
//  MedicFormView.swift
//  PRO
//
//  Created by VMO on 10/01/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast

struct DoctorFormView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    
    @State var doctor: Doctor?
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "doctor", op: "")
    @State private var showValidationError = false
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modMedic") {
                
            }
            switch tabRouter.current {
            case "LOCATIONS":
                PanelLocationView(panel: doctor, couldAdd: true)
            default:
                ZStack(alignment: .bottomTrailing) {
                    ForEach(form.tabs, id: \.id) { tab in
                        if tab.key == tabRouter.current {
                            if let ix = form.tabs.firstIndex(where: { $0.key == tabRouter.current }) {
                                CustomForm {
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
        if viewRouter.data.objectId == nil {
            doctor = Doctor()
        } else {
            doctor = Doctor(value: DoctorDao(realm: try! Realm()).by(objectId: viewRouter.data.objectId!) ?? Doctor())
            plainData = try! Utils.objToJSON(doctor)
            additionalData = doctor?.fields ?? "{}"
        }
        options.objectId = doctor!.objectId
        options.item = doctor?.id ?? 0
        options.op = viewRouter.data.objectId == nil ? "create" : "update"
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_DOC_DYNAMIC_FORM").complement ?? "")
        
        initDynamic(data: dynamicData)
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        if !plainData.isEmpty {
            DynamicUtils.fillForm(form: &form, base: plainData, additional: additionalData)
        }
    }
    
    func save() {
        if DynamicUtils.validate(form: form) && doctor != nil {
            DynamicUtils.cloneObject(main: doctor, temporal: try! JSONDecoder().decode(Doctor.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!), skipped: ["objectId", "id", "type"])
            doctor?.fields = DynamicUtils.generateAdditional(form: form)
            doctor?.transactionType = options.op.uppercased()
            DoctorDao(realm: try! Realm()).store(doctor: doctor!)
            viewRouter.currentPage = "MASTER"
        } else {
            showValidationError = true
        }
    }
    
    func onTabSelected(_ tab: String) {
        tabRouter.current = tab
    }
    
}
