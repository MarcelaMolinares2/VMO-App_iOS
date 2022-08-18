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
    
    @State var doctor: Doctor = Doctor()
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "doctor", op: "")
    @State private var showValidationError = false
    
    @State private var contactControl = [PanelContactControlModel]()
    @State private var locations = [PanelLocationModel]()
    @State private var visitingHours = [PanelVisitingHourModel]()
    
    var realm = try! Realm()
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modDoctor") {
                
            }
            if viewRouter.data.objectId != nil {
                if let d = doctor {
                    PanelFormHeaderView(panel: d)
                }
            }
            ZStack(alignment: .bottom) {
                TabView(selection: $tabRouter.current) {
                    ForEach($form.tabs) { $tab in
                        CustomForm {
                            DynamicFormView(form: $form, tab: $tab, options: options)
                            ScrollViewFABBottom()
                        }
                        .tag(tab.key)
                        .tabItem {
                            Text(NSLocalizedString("envTab\(tab.key.capitalized)", comment: ""))
                            Image("ic-dynamic-tab-\(tab.key.lowercased())")
                        }
                    }
                    PanelFormVisitingHoursView(items: $visitingHours)
                        .tag("visiting-hours")
                        .tabItem {
                            Text("envTabVisitingHours")
                            Image("ic-calendar")
                        }
                    PanelFormLocationView(items: $locations)
                        .tag("locations")
                        .tabItem {
                            Text("envTabLocations")
                            Image("ic-map")
                        }
                    PanelFormContactControlView(items: $contactControl)
                        .tag("contact-control")
                        .tabItem {
                            Text("envTabContactControl")
                            Image("ic-contact-control")
                        }
                }
                .tabViewStyle(DefaultTabViewStyle())
                HStack(alignment: .bottom) {
                    Spacer()
                    if !["locations"].contains(tabRouter.current) {
                        FAB(image: "ic-cloud") {
                            self.save()
                        }
                    }
                }
                .padding(.bottom, Globals.UI_FAB_VERTICAL + 50)
                .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
            }
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
            additionalData = doctor.fields
        }
        initContactControl()
        initLocations()
        initVisitingHours()
        
        options.objectId = doctor.objectId
        options.item = doctor.id
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
    
    func initContactControl() {
        print(ContactControlTypeDao(realm: realm).all())
        ContactControlTypeDao(realm: realm).all().forEach { ccType in
            var status = false
            if let cc = doctor.contactControl.first(where: { ccp in
                ccp.contactControlTypeId == ccType.id
            }) {
                status = cc.status == 1
            }
            contactControl.append(PanelContactControlModel(contactControlType: ccType, status: status))
        }
    }
    
    func initLocations() {
        doctor.locations.forEach { pl in
            locations.append(PanelLocationModel(address: pl.address, latitude: pl.latitude ?? 0, longitude: pl.longitude ?? 0, type: pl.type ?? "DEFAULT", cityId: pl.cityId ?? 0, complement: pl.complement ?? ""))
        }
    }
    
    func initVisitingHours() {
        for day in 0..<7 {
            if let vh = doctor.visitingHours.first(where: { pvh in
                pvh.dayOfWeek == day
            }) {
                visitingHours.append(PanelVisitingHourModel(dayOfWeek: vh.dayOfWeek, amHourStart: vh.amHourStart, amHourEnd: vh.amHourEnd, pmHourStart: vh.pmHourStart, pmHourEnd: vh.pmHourEnd, amStatus: vh.amStatus == 1, pmStatus: vh.pmStatus == 1))
            } else {
                visitingHours.append(PanelVisitingHourModel(dayOfWeek: day))
            }
        }
    }
    
    func save() {
        if DynamicUtils.validate(form: form) {
            DynamicUtils.cloneObject(main: doctor, temporal: try! JSONDecoder().decode(Doctor.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!), skipped: ["objectId", "id", "type"])
            doctor.fields = DynamicUtils.generateAdditional(form: form)
            doctor.transactionType = options.op.uppercased()
            DoctorDao(realm: try! Realm()).store(doctor: doctor)
            viewRouter.currentPage = "MASTER"
        } else {
            showValidationError = true
        }
    }
    
    func onTabSelected(_ tab: String) {
        tabRouter.current = tab
    }
    
}
