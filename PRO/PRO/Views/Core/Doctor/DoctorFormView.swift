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
import Combine

struct DoctorFormView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var doctor: Doctor = Doctor()
    @State var doctorTemporal: Doctor = Doctor()
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "doctor", op: .view, panelType: "M")
    
    @State private var modalDuplicates = false
    @State private var savedToast = false
    @State private var showValidationError = false
    
    @State private var contactControl = [PanelContactControlModel]()
    @State private var locations = [PanelLocationModel]()
    @State private var visitingHours = [PanelVisitingHourModel]()
    
    @State private var duplicates: [Doctor] = []
    @State private var subscriber: AnyCancellable?
    
    private var realm = try! Realm()
    private var categorizationSettings = PanelUtils.categorizationSettings(by: "M")
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modDoctor") {
                viewRouter.currentPage = "MASTER"
            }
            if viewRouter.data.objectId != nil {
                PanelFormHeaderView(panel: doctor)
            } else {
                if !duplicates.isEmpty {
                    PanelFormDuplicationAdviceView().onTapGesture {
                        modalDuplicates = true
                    }
                }
            }
            CustomPanelFormWrapperView(tabs: ["visiting-hours", "locations", "contact-control"], form: $form, options: $options, contactControl: $contactControl, locations: $locations, visitingHours: $visitingHours, savedToast: $savedToast, onFABSaveTapped: validate)
        }
        .sheet(isPresented: $modalDuplicates, content: {
            CustomPanelListDuplicatesView(form: $form) {
                ForEach(duplicates) { d in
                    PanelItemDoctor(realm: realm, userId: JWTUtils.sub(), doctor: d) {
                        
                    }
                }
            } onSaveAnywayTapped: {
                modalDuplicates = false
                save()
            }
        })
        .onAppear {
            initForm()
        }
        .onDisappear {
            subscriber = nil
        }
        .toast(isPresenting: $showValidationError) {
            AlertToast(type: .error(.cDanger), title: NSLocalizedString("errFormEmpty", comment: ""))
        }
        .toast(isPresenting: $savedToast) {
            AlertToast(type: .complete(.cDone), title: NSLocalizedString("envSuccessfullySaved", comment: ""))
        }
    }
    
    func initForm() {
        if viewRouter.data.objectId == nil {
            doctor = Doctor()
            initDefault()
        } else {
            doctor = Doctor(value: DoctorDao(realm: try! Realm()).by(objectId: viewRouter.data.objectId!) ?? Doctor())
            plainData = try! Utils.objToJSON(doctor)
            additionalData = doctor.fields
        }
        initNested()
        
        options.objectId = doctor.objectId
        options.item = doctor.id
        options.op = viewRouter.data.objectId == nil ? .create : .update
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_DOC_DYNAMIC_FORM").complement ?? "")
        
        initDynamic(data: dynamicData)
        initObservers()
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        if !plainData.isEmpty {
            DynamicUtils.fillForm(form: &form, base: plainData, additional: additionalData)
            
            DynamicUtils.fillFormField(form: &form, key: "clients", value: doctor.clients.map { String($0.relatedToId) }.joined(separator: ","))
            DynamicUtils.fillFormField(form: &form, key: "lines", value: doctor.lines.map { String($0.lineId) }.joined(separator: ","))
            DynamicUtils.fillFormCategories(realm: realm, form: &form, categories: Array(doctor.categories))
        }
    }
    
    func initDefault() {
        let panelUser = PanelUser()
        panelUser.userId = JWTUtils.sub()
        panelUser.visitsCycle = 0
        panelUser.visitsFee = PanelUtils.defaultVisitsFee(by: options.panelType)
        doctor.users.append(panelUser)
    }
    
    func initNested() {
        ContactControlTypeDao(realm: realm).all().forEach { ccType in
            var status = false
            if let cc = doctor.contactControl.first(where: { ccp in
                ccp.contactControlTypeId == ccType.id
            }) {
                status = cc.status == 1
            }
            contactControl.append(PanelContactControlModel(contactControlType: ccType, status: status))
        }
        doctor.locations.forEach { pl in
            locations.append(PanelLocationModel(id: pl.id, address: pl.address, latitude: pl.latitude ?? 0, longitude: pl.longitude ?? 0, type: pl.type ?? "DEFAULT", geocode: pl.geocode ?? "", cityId: pl.cityId ?? 0, complement: pl.complement ?? ""))
        }
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
    
    func validate() {
        if DynamicUtils.validate(form: form) {
            if options.op == .create {
                duplicates = PanelUtils.duplication(from: Doctor.self, object: doctor, panelType: options.panelType, classKeys: Doctor.classKeys())
                if !duplicates.isEmpty {
                    modalDuplicates = true
                    return
                }
            }
            save()
        } else {
            showValidationError = true
        }
    }
    
    func save() {
        doctor.fields = DynamicUtils.generateAdditional(form: form)
        doctor.transactionType = DynamicUtils.transactionType(action: options.op)
        fillNested()
        categorization()
        DoctorDao(realm: try! Realm()).store(doctor: doctor)
        goTo(page: "MASTER")
    }
    
    func goTo(page: String) {
        savedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Globals.ENV_SAVE_DELAY) {
            viewRouter.currentPage = page
        }
    }
    
    func initObservers() {
        if options.op == .create && PanelUtils.couldValidDuplicates(panelType: options.panelType) {
            self.subscriber = Timer
                .publish(every: 0.5, on: .main, in: .common)
                .autoconnect()
                .sink(receiveValue: { _ in
                    DynamicUtils.cloneObject(main: doctorTemporal, temporal: try! JSONDecoder().decode(Doctor.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!), skipped: ["objectId", "id", "type"])
                    duplicates = PanelUtils.duplication(from: Doctor.self, object: doctorTemporal, panelType: options.panelType, classKeys: Doctor.classKeys())
                })
        }
    }
    
    func fillNested() {
        doctor.locations.removeAll()
        locations.forEach { plm in
            plm.cityId = doctor.cityId
        }
        PanelUtils.castLocations(lm: locations).forEach { pl in
            doctor.locations.append(pl)
        }
        
        doctor.contactControl.removeAll()
        PanelUtils.castContactControl(cc: contactControl).forEach { cc in
            doctor.contactControl.append(cc)
        }
        
        doctor.visitingHours.removeAll()
        PanelUtils.castVisitingHours(vh: visitingHours).forEach { vh in
            doctor.visitingHours.append(vh)
        }
        
        doctor.clients.removeAll()
        if let field = DynamicUtils.findFormField(form: form, key: "clients") {
            field.value.components(separatedBy: ",").forEach { s in
                let relation = PanelRelation()
                relation.id = 0
                relation.relatedToId = Utils.castInt(value: s)
                doctor.clients.append(relation)
            }
        }
        
        doctor.lines.removeAll()
        if let field = DynamicUtils.findFormField(form: form, key: "lines") {
            field.value.components(separatedBy: ",").forEach { s in
                let panelLine = PanelLine()
                panelLine.lineId = Utils.castInt(value: s)
                doctor.lines.append(panelLine)
            }
        }
        
        doctor.categories.removeAll()
        DynamicUtils.findFormField(form: form, source: "category").forEach { field in
            if !field.value.isEmpty {
                let panelCategoryPanel = PanelCategoryPanel()
                panelCategoryPanel.id = 0
                panelCategoryPanel.categoryId = Utils.castInt(value: field.value)
                doctor.categories.append(panelCategoryPanel)
            }
        }
        
        if let field = DynamicUtils.findFormField(form: form, key: "groups") {
            field.value.components(separatedBy: ",").forEach { s in
                if let group = GroupDao(realm: realm).by(id: Utils.castInt(value: s)) {
                    if !group.members.contains(where: { gm in
                        gm.panelId == doctor.id || gm.panelObjectId == doctor.objectId
                    }) {
                        let gm = GroupMember()
                        gm.panelId = doctor.id
                        gm.panelObjectId = doctor.objectId
                        gm.panelType = options.panelType
                        try! realm.write {
                            group.members.append(gm)
                        }
                    }
                }
            }
        }
    }
    
    func categorization() {
        if categorizationSettings.automatic {
            
        }
        if !doctor.visitsFeeWasEdited {
            if categorizationSettings.attachVisitsFee {
                if !doctor.categories.isEmpty {
                    if let category = CategoryDao(realm: realm).by(id: doctor.categories.first?.categoryId) {
                        doctor.mainUser()?.visitsFee = category.visitsFeeDoctor
                    }
                }
            }
        }
    }
    
}
