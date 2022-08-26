//
//  ClientFormView.swift
//  PRO
//
//  Created by VMO on 4/12/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast
import Combine

struct ClientFormView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var client: Client = Client()
    @State var clientTemporal: Client = Client()
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "client", op: .view, panelType: "C")
    
    @State private var modalDuplicates = false
    @State private var savedToast = false
    @State private var showValidationError = false
    
    @State private var contactControl = [PanelContactControlModel]()
    @State private var locations = [PanelLocationModel]()
    @State private var visitingHours = [PanelVisitingHourModel]()
    
    @State private var duplicates: [Client] = []
    @State private var subscriber: AnyCancellable?
    
    private var realm = try! Realm()
    private var categorizationSettings = PanelUtils.categorizationSettings(by: "C")
    
    var body: some View {
        VStack{
            HeaderToggleView(title: "modClient") {
                viewRouter.currentPage = "MASTER"
            }
            if viewRouter.data.objectId != nil {
                PanelFormHeaderView(panel: client)
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
                    PanelItemClient(realm: realm, userId: JWTUtils.sub(), client: item) {
                        
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
            client = Client()
            initDefault()
        } else {
            client = Client(value: ClientDao(realm: try! Realm()).by(objectId: viewRouter.data.objectId!) ?? Client())
            plainData = try! Utils.objToJSON(client)
            additionalData = client.fields
        }
        initNested()
        
        options.objectId = client.objectId
        options.item = client.id
        options.op = viewRouter.data.objectId == nil ? .create : .update
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_CLI_DYNAMIC_FORM").complement ?? "")
        
        initDynamic(data: dynamicData)
        initObservers()
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        if !plainData.isEmpty {
            DynamicUtils.fillForm(form: &form, base: plainData, additional: additionalData)
            
            DynamicUtils.fillFormCategories(realm: realm, form: &form, categories: Array(client.categories))
        }
    }
    
    func initDefault() {
        let panelUser = PanelUser()
        panelUser.userId = JWTUtils.sub()
        panelUser.visitsCycle = 0
        panelUser.visitsFee = PanelUtils.defaultVisitsFee(by: options.panelType)
        client.users.append(panelUser)
    }
    
    func initNested() {
        client.locations.forEach { pl in
            locations.append(PanelLocationModel(id: pl.id, address: pl.address, latitude: pl.latitude ?? 0, longitude: pl.longitude ?? 0, type: pl.type ?? "DEFAULT", geocode: pl.geocode ?? "", cityId: pl.cityId ?? 0, complement: pl.complement ?? ""))
        }
        for day in 0..<7 {
            if let vh = client.visitingHours.first(where: { pvh in
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
                duplicates = PanelUtils.duplication(from: Client.self, object: client, panelType: options.panelType, classKeys: Client.classKeys())
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
        client.fields = DynamicUtils.generateAdditional(form: form)
        client.transactionType = DynamicUtils.transactionType(action: options.op)
        fillNested()
        categorization()
        ClientDao(realm: try! Realm()).store(client: client)
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
                    DynamicUtils.cloneObject(main: clientTemporal, temporal: try! JSONDecoder().decode(Client.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!), skipped: ["objectId", "id", "type"])
                    duplicates = PanelUtils.duplication(from: Client.self, object: clientTemporal, panelType: options.panelType, classKeys: Client.classKeys())
                })
        }
    }
    
    func fillNested() {
        client.locations.removeAll()
        locations.forEach { plm in
            plm.cityId = client.cityId
        }
        PanelUtils.castLocations(lm: locations).forEach { pl in
            client.locations.append(pl)
        }
        
        client.visitingHours.removeAll()
        PanelUtils.castVisitingHours(vh: visitingHours).forEach { vh in
            client.visitingHours.append(vh)
        }
        
        client.categories.removeAll()
        DynamicUtils.findFormField(form: form, source: "category").forEach { field in
            if !field.value.isEmpty {
                let panelCategoryPanel = PanelCategoryPanel()
                panelCategoryPanel.id = 0
                panelCategoryPanel.categoryId = Utils.castInt(value: field.value)
                client.categories.append(panelCategoryPanel)
            }
        }
    }
    
    func categorization() {
        if categorizationSettings.automatic {
            
        }
        if !client.visitsFeeWasEdited {
            if categorizationSettings.attachVisitsFee {
                if !client.categories.isEmpty {
                    if let category = CategoryDao(realm: realm).by(id: client.categories.first?.categoryId) {
                        client.mainUser()?.visitsFee = category.visitsFeeDoctor
                    }
                }
            }
        }
    }
    
}

