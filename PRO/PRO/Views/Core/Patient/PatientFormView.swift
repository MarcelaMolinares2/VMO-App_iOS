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
import Combine

struct PatientFormView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var patient: Patient = Patient()
    @State var patientTemporal: Patient = Patient()
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "patient", op: .view, panelType: "P")
    
    @State private var modalDuplicates = false
    @State private var savedToast = false
    @State private var showValidationError = false
    
    @State private var contactControl = [PanelContactControlModel]()
    @State private var locations = [PanelLocationModel]()
    @State private var visitingHours = [PanelVisitingHourModel]()
    
    @State private var duplicates: [Patient] = []
    @State private var subscriber: AnyCancellable?
    
    private var realm = try! Realm()
    private var categorizationSettings = PanelUtils.categorizationSettings(by: "P")
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modPatient") {
                viewRouter.currentPage = "MASTER"
            }
            if viewRouter.data.objectId != nil {
                PanelFormHeaderView(panel: patient)
            } else {
                if !duplicates.isEmpty {
                    PanelFormDuplicationAdviceView().onTapGesture {
                        modalDuplicates = true
                    }
                }
            }
            CustomPanelFormWrapperView(tabs: ["locations"], form: $form, options: $options, contactControl: $contactControl, locations: $locations, visitingHours: $visitingHours, savedToast: $savedToast, onFABSaveTapped: validate)
        }
        .sheet(isPresented: $modalDuplicates, content: {
            CustomPanelListDuplicatesView(form: $form) {
                ForEach(duplicates) { item in
                    PanelItemPatient(realm: realm, userId: JWTUtils.sub(), patient: item) {
                        
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
            patient = Patient()
            initDefault()
        } else {
            patient = Patient(value: PatientDao(realm: try! Realm()).by(objectId: viewRouter.data.objectId!) ?? Patient())
            plainData = try! Utils.objToJSON(patient)
            additionalData = patient.fields
        }
        initNested()
        
        options.objectId = patient.objectId
        options.item = patient.id
        options.op = viewRouter.data.objectId == nil ? .create : .update
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_PAT_DYNAMIC_FORM").complement ?? "")
        
        initDynamic(data: dynamicData)
        initObservers()
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        if !plainData.isEmpty {
            DynamicUtils.fillForm(form: &form, base: plainData, additional: additionalData)
            
            DynamicUtils.fillFormField(form: &form, key: "clients", value: patient.clients.map { String($0.relatedToId) }.joined(separator: ","))
            DynamicUtils.fillFormField(form: &form, key: "doctors", value: patient.doctors.map { String($0.relatedToId) }.joined(separator: ","))
        }
    }
    
    func initDefault() {
        let panelUser = PanelUser()
        panelUser.userId = JWTUtils.sub()
        panelUser.visitsCycle = 0
        panelUser.visitsFee = PanelUtils.defaultVisitsFee(by: options.panelType)
        patient.users.append(panelUser)
    }
    
    func initNested() {
        patient.locations.forEach { pl in
            locations.append(PanelLocationModel(id: pl.id, address: pl.address, latitude: pl.latitude ?? 0, longitude: pl.longitude ?? 0, type: pl.type ?? "DEFAULT", geocode: pl.geocode ?? "", cityId: pl.cityId ?? 0, complement: pl.complement ?? ""))
        }
    }
    
    func validate() {
        if DynamicUtils.validate(form: form) {
            if options.op == .create {
                duplicates = PanelUtils.duplication(from: Patient.self, object: patient, panelType: options.panelType, classKeys: Patient.classKeys())
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
        patient.fields = DynamicUtils.generateAdditional(form: form)
        patient.transactionType = DynamicUtils.transactionType(action: options.op)
        fillNested()
        categorization()
        PatientDao(realm: try! Realm()).store(patient: patient)
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
                    DynamicUtils.cloneObject(main: patientTemporal, temporal: try! JSONDecoder().decode(Patient.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!), skipped: ["objectId", "id", "type"])
                    duplicates = PanelUtils.duplication(from: Patient.self, object: patientTemporal, panelType: options.panelType, classKeys: Patient.classKeys())
                })
        }
    }
    
    func fillNested() {
        patient.locations.removeAll()
        locations.forEach { plm in
            plm.cityId = patient.cityId
        }
        PanelUtils.castLocations(lm: locations).forEach { pl in
            patient.locations.append(pl)
        }
        
        patient.clients.removeAll()
        if let field = DynamicUtils.findFormField(form: form, key: "clients") {
            field.value.components(separatedBy: ",").forEach { s in
                let relation = PanelRelation()
                relation.id = 0
                relation.relatedToId = Utils.castInt(value: s)
                patient.clients.append(relation)
            }
        }
        
        patient.doctors.removeAll()
        if let field = DynamicUtils.findFormField(form: form, key: "doctors") {
            field.value.components(separatedBy: ",").forEach { s in
                let relation = PanelRelation()
                relation.id = 0
                relation.relatedToId = Utils.castInt(value: s)
                patient.doctors.append(relation)
            }
        }
    }
    
    func categorization() {
        if categorizationSettings.automatic {
            
        }
        if !patient.visitsFeeWasEdited {
            if categorizationSettings.attachVisitsFee {
                if !patient.categories.isEmpty {
                    if let category = CategoryDao(realm: realm).by(id: patient.categories.first?.categoryId) {
                        patient.mainUser()?.visitsFee = category.visitsFeeDoctor
                    }
                }
            }
        }
    }
}
