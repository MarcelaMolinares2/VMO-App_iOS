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
import Combine

struct PharmacyFormView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var pharmacy: Pharmacy = Pharmacy()
    @State var pharmacyTemporal: Pharmacy = Pharmacy()
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "pharmacy", op: .view, panelType: "F")
    
    @State private var modalDuplicates = false
    @State private var savedToast = false
    @State private var showValidationError = false
    
    @State private var contactControl = [PanelContactControlModel]()
    @State private var locations = [PanelLocationModel]()
    @State private var visitingHours = [PanelVisitingHourModel]()
    
    @State private var duplicates: [Pharmacy] = []
    @State private var subscriber: AnyCancellable?
    
    private var realm = try! Realm()
    private var categorizationSettings = PanelUtils.categorizationSettings(by: "F")
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modPharmacy") {
                viewRouter.currentPage = "MASTER"
            }
            if viewRouter.data.objectId != nil {
                PanelFormHeaderView(panel: pharmacy)
            } else {
                if !duplicates.isEmpty {
                    PanelFormDuplicationAdviceView().onTapGesture {
                        modalDuplicates = true
                    }
                }
            }
            CustomPanelFormWrapperView(tabs: ["visiting-hours", "locations"], form: $form, options: $options, contactControl: $contactControl, locations: $locations, visitingHours: $visitingHours, savedToast: $savedToast, onFABSaveTapped: validate)
        }
        .sheet(isPresented: $modalDuplicates, content: {
            CustomPanelListDuplicatesView(form: $form) {
                ForEach(duplicates) { item in
                    PanelItemPharmacy(realm: realm, userId: JWTUtils.sub(), pharmacy: item) {
                        
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
            pharmacy = Pharmacy()
            initDefault()
        } else {
            pharmacy = Pharmacy(value: PharmacyDao(realm: try! Realm()).by(objectId: viewRouter.data.objectId!) ?? Pharmacy())
            plainData = try! Utils.objToJSON(pharmacy)
            additionalData = pharmacy.fields
        }
        initNested()
        
        options.objectId = pharmacy.objectId
        options.item = pharmacy.id
        options.op = viewRouter.data.objectId == nil ? .create : .update
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_PHA_DYNAMIC_FORM").complement ?? "")
        
        initDynamic(data: dynamicData)
        initObservers()
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        if !plainData.isEmpty {
            DynamicUtils.fillForm(form: &form, base: plainData, additional: additionalData)
            
            DynamicUtils.fillFormField(form: &form, key: "lines", value: pharmacy.lines.map { String($0.lineId) }.joined(separator: ","))
            DynamicUtils.fillFormCategories(realm: realm, form: &form, categories: Array(pharmacy.categories))
        }
    }
    
    func initDefault() {
        let panelUser = PanelUser()
        panelUser.userId = JWTUtils.sub()
        panelUser.visitsCycle = 0
        panelUser.visitsFee = PanelUtils.defaultVisitsFee(by: options.panelType)
        pharmacy.users.append(panelUser)
    }
    
    func initNested() {
        pharmacy.locations.forEach { pl in
            locations.append(PanelLocationModel(id: pl.id, address: pl.address, latitude: pl.latitude ?? 0, longitude: pl.longitude ?? 0, type: pl.type ?? "DEFAULT", geocode: pl.geocode ?? "", cityId: pl.cityId ?? 0, complement: pl.complement ?? ""))
        }
        for day in 0..<7 {
            if let vh = pharmacy.visitingHours.first(where: { pvh in
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
                duplicates = PanelUtils.duplication(from: Pharmacy.self, object: pharmacy, panelType: options.panelType, classKeys: Pharmacy.classKeys())
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
        pharmacy.fields = DynamicUtils.generateAdditional(form: form)
        pharmacy.transactionType = DynamicUtils.transactionType(action: options.op)
        fillNested()
        categorization()
        PharmacyDao(realm: try! Realm()).store(pharmacy: pharmacy)
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
                    DynamicUtils.cloneObject(main: pharmacyTemporal, temporal: try! JSONDecoder().decode(Pharmacy.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!), skipped: ["objectId", "id", "type"])
                    duplicates = PanelUtils.duplication(from: Pharmacy.self, object: pharmacyTemporal, panelType: options.panelType, classKeys: Pharmacy.classKeys())
                })
        }
    }
    
    func fillNested() {
        pharmacy.locations.removeAll()
        locations.forEach { plm in
            plm.cityId = pharmacy.cityId
        }
        PanelUtils.castLocations(lm: locations).forEach { pl in
            pharmacy.locations.append(pl)
        }
        
        pharmacy.visitingHours.removeAll()
        PanelUtils.castVisitingHours(vh: visitingHours).forEach { vh in
            pharmacy.visitingHours.append(vh)
        }
        
        pharmacy.lines.removeAll()
        if let field = DynamicUtils.findFormField(form: form, key: "lines") {
            field.value.components(separatedBy: ",").forEach { s in
                let panelLine = PanelLine()
                panelLine.lineId = Utils.castInt(value: s)
                pharmacy.lines.append(panelLine)
            }
        }
        
        pharmacy.categories.removeAll()
        DynamicUtils.findFormField(form: form, source: "category").forEach { field in
            if !field.value.isEmpty {
                let panelCategoryPanel = PanelCategoryPanel()
                panelCategoryPanel.id = 0
                panelCategoryPanel.categoryId = Utils.castInt(value: field.value)
                pharmacy.categories.append(panelCategoryPanel)
            }
        }
    }
    
    func categorization() {
        if categorizationSettings.automatic {
            
        }
        if !pharmacy.visitsFeeWasEdited {
            if categorizationSettings.attachVisitsFee {
                if !pharmacy.categories.isEmpty {
                    if let category = CategoryDao(realm: realm).by(id: pharmacy.categories.first?.categoryId) {
                        pharmacy.mainUser()?.visitsFee = category.visitsFeeDoctor
                    }
                }
            }
        }
    }
    
}
