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
    
    var doctor: Doctor?
    var plainData = ""
    var dynamicData = Dictionary<String, Any>()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "doctor", op: "")
    @State private var showValidationError = false
    
    init(viewRouter: ViewRouter) {
        if viewRouter.data.id > 0 {
            doctor = try! Realm().object(ofType: Doctor.self, forPrimaryKey: viewRouter.data.id)
            plainData = try! Utils.objToJSON(doctor)
            print(plainData)
        } else {
            doctor = Doctor()
        }
        options.objectId = doctor?.objectId
        options.item = doctor?.id ?? 0
        options.op = viewRouter.data.id > 0 ? "update" : "create"
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_DOC_DYNAMIC_FORM").complement ?? "")
    }
    
    var body: some View {
        VStack {
            HeaderToggleView(couldSearch: false, title: doctor?.name ?? "modMedic", icon: Image("ic-medic"), color: Color.cPanelMedic)
            switch tabRouter.current {
            case "LOCATIONS":
                PanelLocationView(panel: doctor, couldAdd: true)
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
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(form.tabs, id: \.id) { tab in
                        Text(tab.key)
                        Image("ic-home")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / CGFloat(form.tabs.count + 1), alignment: .center)
                            .foregroundColor(tabRouter.current == tab.key ? .cPrimary : .cAccent)
                            .onTapGesture {
                                tabRouter.current = tab.key
                            }
                    }
                    Image("ic-map")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(form.tabs.count + 1), alignment: .center)
                        .foregroundColor(tabRouter.current == "LOCATIONS" ? .cPrimary : .cAccent)
                        .onTapGesture {
                            tabRouter.current = "LOCATIONS"
                        }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 46, maxHeight: 46)
        }
        .onAppear {
            tabRouter.current = "BASIC"
            initDynamic(data: dynamicData)
        }
        .toast(isPresenting: $showValidationError) {
            AlertToast(type: .regular, title: NSLocalizedString("errFormValidation", comment: ""))
        }
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        if !plainData.isEmpty {
            print("FILL!!")
        }
    }
    
    func save() {
        if DynamicUtils.validate(form: form) {
            print(doctor)
            DynamicUtils.cloneObject(main: doctor, temporal: try! JSONDecoder().decode(Doctor.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!), skipped: ["objectId", "id", "type"])
            print(doctor)
            //DoctorDao(realm: try! Realm()).store()
        } else {
            showValidationError = true
            
        }
    }
    
}

extension Decodable {
  init(from: Any) throws {
    let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
    let decoder = JSONDecoder()
    self = try decoder.decode(Self.self, from: data)
  }
}

    /*
    var dataSave = Doctor()
    print(doctor?.objectId)
    dataSave.objectId = (doctor?.objectId)!
    print(dataSave.objectId)
    dataSave.id = doctor?.id ?? 0
    print(dataSave)
    print(DynamicUtils.toJSON(form: form))
    dataSave = try! JSONDecoder().decode(Doctor.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!)
    print(dataSave)
     SwiftTryCatch.try({
              // try something
          }, catch: { (error) in
              print("\(error.description)")
          }, finally: {
              // close resources
     })
    print(doctor)
    var dataSave = Doctor(value: doctor ?? Doctor())
    dataSave = try! JSONDecoder().decode(Doctor.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!)
    print(dataSave)
     */
    /*for (index, attr) in Mirror(reflecting: tmp).children.enumerated() {
        if let propertyName = attr.label as String? {
            let property = propertyName.replacingOccurrences(of: "_", with: "")
            if !["objectId", "id", "type"].contains(property) {
                SwiftTryCatch.try({
                    doctor?.setValue(tmp.value(forKey: property), forUndefinedKey: property)
                }, catch: { (error) in
                    print(String(describing: error?.description))
                }, finally: {
                })
            }
        }
    }
    */
