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
import Combine

struct PotentialFormView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var potential: PotentialProfessional = PotentialProfessional()
    @State var potentialTemporal: PotentialProfessional = PotentialProfessional()
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "potential", op: .view, panelType: "T")
    
    @State private var modalDuplicates = false
    @State private var savedToast = false
    @State private var showValidationError = false
    
    @State private var contactControl = [PanelContactControlModel]()
    @State private var locations = [PanelLocationModel]()
    @State private var visitingHours = [PanelVisitingHourModel]()
    
    @State private var duplicates: [PotentialProfessional] = []
    @State private var subscriber: AnyCancellable?
    
    private var realm = try! Realm()
    private var categorizationSettings = PanelUtils.categorizationSettings(by: "T")
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modPotentialProfessional") {
                viewRouter.currentPage = "MASTER"
            }
            if viewRouter.data.objectId != nil {
                PanelFormHeaderView(panel: potential)
            } else {
                if !duplicates.isEmpty {
                    PanelFormDuplicationAdviceView().onTapGesture {
                        modalDuplicates = true
                    }
                }
            }
            CustomPanelFormWrapperView(tabs: [], form: $form, options: $options, contactControl: $contactControl, locations: $locations, visitingHours: $visitingHours, savedToast: $savedToast, onFABSaveTapped: validate)
        }
        .sheet(isPresented: $modalDuplicates, content: {
            CustomPanelListDuplicatesView(form: $form) {
                ForEach(duplicates) { item in
                    PanelItemPotential(realm: realm, userId: JWTUtils.sub(), potential: item) {
                        
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
            potential = PotentialProfessional()
            initDefault()
        } else {
            potential = PotentialProfessional(value: PotentialDao(realm: try! Realm()).by(objectId: viewRouter.data.objectId!) ?? PotentialProfessional())
            plainData = try! Utils.objToJSON(potential)
            additionalData = potential.fields
        }
        initNested()
        
        options.objectId = potential.objectId
        options.item = potential.id
        options.op = viewRouter.data.objectId == nil ? .create : .update
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_PPT_DYNAMIC_FORM").complement ?? "")
        
        initDynamic(data: dynamicData)
        initObservers()
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        if !plainData.isEmpty {
            DynamicUtils.fillForm(form: &form, base: plainData, additional: additionalData)
        }
    }
    
    func initDefault() {
        let panelUser = PanelUser()
        panelUser.userId = JWTUtils.sub()
        panelUser.visitsCycle = 0
        panelUser.visitsFee = PanelUtils.defaultVisitsFee(by: options.panelType)
        potential.users.append(panelUser)
    }
    
    func initNested() {
    }
    
    func validate() {
        if DynamicUtils.validate(form: form) {
            if options.op == .create {
                duplicates = PanelUtils.duplication(from: PotentialProfessional.self, object: potential, panelType: options.panelType, classKeys: PotentialProfessional.classKeys())
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
        potential.fields = DynamicUtils.generateAdditional(form: form)
        potential.transactionType = DynamicUtils.transactionType(action: options.op)
        fillNested()
        categorization()
        PotentialDao(realm: try! Realm()).store(potential: potential)
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
                    DynamicUtils.cloneObject(main: potentialTemporal, temporal: try! JSONDecoder().decode(PotentialProfessional.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!), skipped: ["objectId", "id", "type"])
                    duplicates = PanelUtils.duplication(from: PotentialProfessional.self, object: potentialTemporal, panelType: options.panelType, classKeys: PotentialProfessional.classKeys())
                })
        }
    }
    
    func fillNested() {
    }
    
    func categorization() {
        if categorizationSettings.automatic {
            
        }
        if !potential.visitsFeeWasEdited {
            if categorizationSettings.attachVisitsFee {
                if !potential.categories.isEmpty {
                    if let category = CategoryDao(realm: realm).by(id: potential.categories.first?.categoryId) {
                        potential.mainUser()?.visitsFee = category.visitsFeeDoctor
                    }
                }
            }
        }
    }
    
}
