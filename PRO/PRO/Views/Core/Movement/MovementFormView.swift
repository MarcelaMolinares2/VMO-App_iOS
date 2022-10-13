//
//  MovementFormView.swift
//  PRO
//
//  Created by VMO on 19/01/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import CoreLocation
import SheeKit
import AlertToast

class MovementModel: ObservableObject {
    @Published var panelObjectId = ObjectId()
    @Published var panelId: Int = 0
    @Published var panelType: String = ""
    
    @Published var cycleId: Int = 0
    @Published var date: Date = Date()
    @Published var comment: String = ""
    @Published var targetNext: String = ""
    @Published var duration: Int = 0
    @Published var fields: String = ""
    @Published var companionId: Int = 0
    @Published var contactType: String = ""
    @Published var contactedBy: String = ""
    @Published var contacts: String = ""
    @Published var habeasData: String = ""
    
    @Published var requestAssistance = false
    @Published var attachPanelLocation = false
}

class MovementDurationModel: ObservableObject {
    @Published var hour: Int = 0
    @Published var minute: Int = 0
    @Published var second: Int = 0
}

class MovementFieldModel: ObservableObject {
    @Published var required: Bool
    @Published var visible: Bool
    @Published var controlType: String = ""
    
    init(required: Bool, visible: Bool) {
        self.required = required
        self.visible = visible
    }
    
    init(required: Bool, visible: Bool, controlType: String) {
        self.required = required
        self.visible = visible
        self.controlType = controlType
    }
}

struct MovementFormView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    @ObservedObject var locationService = LocationService()
    
    var realm = try! Realm()
    
    var title = ""
    var icon = "ic-home"
    var color = Color.cPrimary
    var visitType = "NORMAL"
    
    @State private var locationRequired = Config.get(key: "MOV_LOCATION_REQUIRED").value == 1
    @State private var reportType = Config.get(key: "MOV_LOCATION_REQUIRED").value
    
    @State private var movement: Movement = Movement()
    @State private var panel: Panel?
    
    @State private var materials = [AdvertisingMaterialDeliveryMaterial]()
    @State private var promoted = [String]()
    @State private var stock = [MovementProductStockModel]()
    @State private var shopping = [MovementProductShoppingModel]()
    @State private var transference = [MovementProductTransferenceModel]()
    
    @State private var mainTabsLayout = true
    @State private var basicFormValid = false
    @State private var showValidationError = false
    @State private var savedToast = false
    @State private var modalSave = false
    
    @State private var scheduleNextVisit = false
    @State private var scheduleNextDate = Date()
    @State private var scheduleNextTime = Date()
    
    @State var mainTabs = [MovementTab]()
    @State var moreTabs = [MovementTab]()
    
    @State private var extraData: [String: Any] = [:]
    
    @State private var dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_MOV_FORM_ADDITIONAL").complement ?? "")
    @State private var dynamicForm = DynamicForm(tabs: [DynamicFormTab]())
    @State private var dynamicOptions = DynamicFormFieldOptions(table: "movement", op: .view)
    
    @StateObject private var model = MovementModel()
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modVisit") {
                viewRouter.currentPage = "MASTER"
            }
            let locationAvailable = !(locationService.location == nil || (locationService.location?.coordinate.latitude == 0 && locationService.location?.coordinate.longitude == 0))
            if locationRequired && !locationAvailable {
                Spacer()
                VStack {
                    Text("envMovementLocationRequired")
                }
                Spacer()
            } else {
                if panel == nil {
                    Spacer()
                    VStack {
                        Text("envPanelNotFound")
                    }
                    Spacer()
                } else {
                    VStack {
                        VStack {
                            PanelFormHeaderView(panel: panel!)
                        }
                        .background(Color.cBackground1dp)
                        ZStack(alignment: .bottom) {
                            if mainTabsLayout {
                                TabView(selection: $tabRouter.current) {
                                    ForEach(mainTabs) { tab in
                                        MovementTabContentWrapperView(realm: realm, key: tab.key, visitType: visitType, isEditable: true, locationAvailable: locationAvailable, extraData: extraData, model: model, dynamicForm: $dynamicForm, dynamicOptions: $dynamicOptions, materials: $materials, promoted: $promoted, stock: $stock, shopping: $shopping, transference: $transference, basicValid: $basicFormValid)
                                            .tag(tab.key)
                                            .tabItem {
                                                Text(tab.label.localized())
                                                Image(tab.icon)
                                            }
                                    }
                                }
                            } else {
                                TabView(selection: $tabRouter.current) {
                                    ForEach(moreTabs) { tab in
                                        MovementTabContentWrapperView(realm: realm, key: tab.key, visitType: visitType, isEditable: true, locationAvailable: locationAvailable, extraData: extraData, model: model, dynamicForm: $dynamicForm, dynamicOptions: $dynamicOptions, materials: $materials, promoted: $promoted, stock: $stock, shopping: $shopping, transference: $transference, basicValid: $basicFormValid)
                                            .tag(tab.key)
                                            .tabItem {
                                                Text(tab.label.localized())
                                                Image(tab.icon)
                                            }
                                    }
                                }
                            }
                            HStack(alignment: .bottom) {
                                Spacer()
                                FAB(image: "ic-cloud") {
                                    validate()
                                }
                            }
                            .padding(.bottom, Globals.UI_FAB_VERTICAL + 50)
                            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
                        }
                    }
                }
            }
        }
        .shee(isPresented: $modalSave, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
            VStack {
                CustomCard {
                    Toggle(isOn: $scheduleNextVisit) {
                        Text("envScheduleNextVisit")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    VStack {
                        DatePicker(selection: $scheduleNextDate, displayedComponents: .date) {
                            Text("envDate")
                                .foregroundColor(.cTextHigh)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        DatePicker(selection: $scheduleNextTime, displayedComponents: .hourAndMinute) {
                            Text("envTime")
                                .foregroundColor(.cTextHigh)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .disabled(!scheduleNextVisit)
                }
                Spacer()
                CustomCard {
                    Text("envSaveAndGoTo")
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 13))
                    HStack {
                        Button {
                            save(goToPage: "MASTER")
                        } label: {
                            VStack {
                                Image("ic-home")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                    .foregroundColor(.cIcon)
                                Text("envHome")
                                    .foregroundColor(.cTextMedium)
                                    .lineLimit(2)
                                    .font(.system(size: 13))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        Button {
                            save(goToPage: "DIARY-VIEW")
                        } label: {
                            VStack {
                                Image("ic-diary")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                    .foregroundColor(.cIcon)
                                Text("envDiary")
                                    .foregroundColor(.cTextMedium)
                                    .lineLimit(2)
                                    .font(.system(size: 13))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
        }
        .toast(isPresenting: $showValidationError) {
            AlertToast(type: .error(.cDanger), title: NSLocalizedString("errFormEmpty", comment: ""))
        }
        .toast(isPresenting: $savedToast) {
            AlertToast(type: .complete(.cDone), title: NSLocalizedString("envSuccessfullySaved", comment: ""))
        }
        .onChange(of: tabRouter.current, perform: { newValue in
            if newValue == "MORE" {
                mainTabsLayout = false
                tabRouter.current = moreTabs[1].key
            }
            if newValue == "BACK" {
                mainTabsLayout = true
                tabRouter.current = "BASIC"
            }
        })
        .onAppear {
            locationService.start()
            initMovement()
        }
        .onDisappear {
            locationService.stop()
        }
    }
    
    func initMovement() {
        let tabs = MovementUtils.initTabs(data: MovementUtils.tabs(panelType: viewRouter.data.type, visitType: Utils.castString(value: viewRouter.data.options["visitType"]).lowercased()))
        mainTabs = tabs[0]
        moreTabs = tabs[1]
        tabRouter.current = "BASIC"
        
        let movementObjectId = viewRouter.option(key: "oId", default: "")
        let movementId = viewRouter.option(key: "id", default: "")
        
        if movementObjectId.isEmpty && movementId.isEmpty {
            if let oId = viewRouter.data.objectId {
                panel = PanelUtils.panel(type: viewRouter.data.type, objectId: oId)
                
                if reportType == 2 {
                    if let m = MovementDao(realm: realm).open(panelObjectId: oId, panelType: viewRouter.data.type) {
                        movement = Movement(value: m)
                    }
                } else {
                    movement.panelId = panel?.id ?? 0
                    movement.panelObjectId = oId
                    movement.panelType = viewRouter.data.type
                    movement.visitType = visitType.lowercased()
                    movement.date = Utils.currentDate()
                    movement.contactType = "P"
                    movement.cycleId = CycleDao(realm: realm).active().first?.id ?? 0
                }
                
                dynamicOptions.op = .create
                initForm()
            }
        } else {
            if let m = MovementDao(realm: realm).by(objectId: movementObjectId) {
                movement = Movement(value: m)
                dynamicOptions.op = .update
                initForm()
            } else {
                getMovement(id: movementId)
            }
        }
    }
    
    func initForm() {
        model.panelObjectId = movement.panelObjectId
        model.panelType = movement.panelType
        
        model.cycleId = movement.cycleId
        model.date = Utils.strToDate(value: movement.date, format: "yyyy-MM-dd")
        model.comment = movement.comment ?? ""
        model.targetNext = movement.target ?? ""
        model.duration = movement.duration ?? 0
        model.companionId = movement.companionId ?? 0
        model.contactType = movement.contactType
        model.contactedBy = movement.contactedBy ?? ""
        model.contacts = movement.dataContacts ?? ""
        model.requestAssistance = movement.rqAssistance == 1
        model.attachPanelLocation = movement.assocPanelLocation
        
        if movement.panelType == "F" {
            let pharmacy = PharmacyDao(realm: realm).by(objectId: movement.panelObjectId)
            extraData["pharmacyChain"] = pharmacy?.pharmacyChainId
        }
        
        initDynamic()
    }
    
    func initDynamic() {
        dynamicForm.tabs = DynamicUtils.initForm(data: dynamicData).sorted(by: { $0.key > $1.key })
        if !model.fields.isEmpty {
            DynamicUtils.fillForm(form: &dynamicForm, base: movement.additionalFields ?? "{}")
        }
        dynamicOptions.op = .create
        dynamicOptions.type = movement.visitType
        dynamicOptions.panelType = movement.panelType
    }
    
    func getMovement(id: String) {
        
    }
    
    func validate() {
        UIApplication.shared.endEditing()
        if DynamicUtils.validate(form: dynamicForm) && basicFormValid {
            modalSave = true
        } else {
            showValidationError = true
        }
    }
    
    func save(goToPage: String) {
        movement.cycleId = model.cycleId
        movement.date = Utils.dateFormat(date: model.date)
        movement.comment = model.comment
        movement.target = model.targetNext
        movement.duration = model.duration
        movement.companionId = model.companionId
        movement.contactType = model.contactType
        movement.contactedBy = model.contactedBy
        movement.dataContacts = model.contacts
        movement.rqAssistance = model.requestAssistance ? 1 : 0
        movement.assocPanelLocation = model.attachPanelLocation
        movement.additionalFields = DynamicUtils.toJSON(form: dynamicForm)
        
        fillNested()
        
        MovementDao(realm: realm).store(movement: movement)
        
        if scheduleNextVisit {
            let diary = Diary()
            diary.date = Utils.dateFormat(date: scheduleNextDate)
            diary.panelType = movement.panelType
            diary.panelObjectId = movement.panelObjectId
            diary.panelId = movement.panelId
            diary.type = "P"
            diary.contactType = "P"
            diary.transactionType = "CREATE"
            diary.hourStart = Utils.hourFormat(date: scheduleNextTime)
            DiaryDao(realm: realm).store(diary: diary)
        }
        
        modalSave = false
        goTo(page: goToPage)
    }
    
    func fillNested() {
        movement.dataPromoted = promoted.joined(separator: ",")
        
        movement.dataMaterial.removeAll()
        materials.forEach { m in
            let material = MovementMaterial()
            material.id = m.materialId
            material.category = m.materialCategoryId
            m.sets.forEach { s in
                let set = MovementMaterialSet()
                set.id = s.id
                set.quantity = s.quantity
                material.sets.append(set)
            }
            movement.dataMaterial.append(material)
        }
        
        movement.dataStock.removeAll()
        stock.forEach { s in
            let stock = MovementProductStock()
            stock.id = s.productId
            stock.quantity = s.quantity
            stock.hasStock = s.hasStock
            stock.noStockReason = s.noStockReason
            movement.dataStock.append(stock)
        }
        
        movement.dataShopping.removeAll()
        shopping.forEach { s in
            let shopping = MovementProductShopping()
            shopping.id = s.productId
            shopping.price = s.price
            s.competitors.forEach { c in
                let competitor = MovementProductShoppingCompetitor()
                competitor.id = c.id
                competitor.price = c.price
                shopping.competitors.append(competitor)
            }
            movement.dataShopping.append(shopping)
        }
        
        movement.dataTransference.removeAll()
        transference.forEach { t in
            let transference = MovementProductTransference()
            transference.id = t.productId
            transference.price = t.price
            transference.quantity = t.quantity
            transference.bonusProduct = t.bonusProduct
            transference.bonusQuantity = t.bonusQuantity
            movement.dataTransference.append(transference)
        }
    }
    
    func goTo(page: String) {
        savedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Globals.ENV_SAVE_DELAY) {
            viewRouter.currentPage = page
        }
    }
}

struct MovementFormTabBasicView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @StateObject var model: MovementModel
    @Binding var valid: Bool
    @Binding var dynamicForm: DynamicForm
    @Binding var dynamicOptions: DynamicFormFieldOptions
    var visitType: String
    var locationAvailable: Bool
    
    @StateObject var modelDuration = MovementDurationModel()
    
    @State private var requestAssistance = false
    @State private var attachPanelLocation = false
    
    @State private var modalInfo = false
    
    let reportType = Config.get(key: "MOV_REPORT_TYPE").value
    let contactTypes = Config.get(key: "MOV_CONTACT_TYPES").complement ?? ""
    let contactedByOptions = Config.get(key: "MOV_CONTACTED_BY_OPTS").complement ?? ""
    let baseForm = Config.get(key: "P_MOV_FORM").complement ?? "{}"
    
    @State private var ctComment = MovementFieldModel(required: false, visible: true)
    @State private var ctCompanion = MovementFieldModel(required: false, visible: true)
    @State private var ctContacts = MovementFieldModel(required: false, visible: false)
    @State private var ctDuration = MovementFieldModel(required: false, visible: true)
    @State private var ctHabeasData = MovementFieldModel(required: false, visible: false)
    @State private var ctTarget = MovementFieldModel(required: false, visible: true)
    
    @State private var slCycle: [String] = []
    @State private var slContactType: [String] = []
    @State private var slContactedBy: [String] = []
    @State private var slComment: [String] = []
    @State private var slTargetNext: [String] = []
    @State private var slContacts: [String] = []
    @State private var slCompanion: [String] = []
    @State private var slFailedReason: [String] = []
    
    @State private var modalCycle = false
    @State private var modalContactType = false
    @State private var modalContactedBy = false
    @State private var modalComment = false
    @State private var modalTargetNext = false
    @State private var modalDuration = false
    @State private var modalContacts = false
    @State private var modalCompanion = false
    
    @State private var actionSheet = false
    @State private var modalCamera = false
    @State private var modalDraw = false
    @State private var modalGallery = false
    
    @State private var modalFailedReason = false
    @State private var modalFailedForm = false
    
    @State private var initialValue = ""
    @State private var hdTable = ""
    @State private var commentFailed = ""
    @State private var uiImage: UIImage?
    
    let minReportDate = MovementUtils.minReportDate()
    
    private let pickerSources = Utils.jsonDictionary(string: Config.get(key: "PICKER_SOURCES").complement ?? "{}")
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Button {
                    modalInfo = true
                } label: {
                    Image("ic-info")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26, alignment: .center)
                        .foregroundColor(.cIcon)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                Button {
                    requestAssistance.toggle()
                } label: {
                    Image(requestAssistance ? "ic-notifications-active" : "ic-notifications")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26, alignment: .center)
                        .foregroundColor(requestAssistance ? .cDone : .cIcon)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .onChange(of: requestAssistance) { v in
                    model.requestAssistance = v
                }
                Button {
                    if locationAvailable {
                        attachPanelLocation.toggle()
                    }
                } label: {
                    Image(locationAvailable ? "ic-location" : "ic-location-disabled")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26, alignment: .center)
                        .foregroundColor(attachPanelLocation ? .cDone : .cIcon)
                }
                .onChange(of: attachPanelLocation) { v in
                    model.attachPanelLocation = v
                }
                .frame(maxWidth: .infinity, alignment: .center)
                if dynamicOptions.op == FormAction.create {
                    Button {
                        modalFailedReason = true
                    } label: {
                        Image("ic-warning")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26, alignment: .center)
                            .foregroundColor(.cWarning)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                if reportType == 2 && dynamicOptions.op == .update {
                    Button {
                        
                    } label: {
                        Image("ic-delete")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26, alignment: .center)
                            .foregroundColor(.cDanger)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.bottom, 10)
            CustomForm {
                CustomSection {
                    HStack {
                        Button {
                            modalCycle = true
                        } label: {
                            HStack {
                                VStack {
                                    Text(NSLocalizedString("envCycle", comment: ""))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(slCycle.isEmpty ? Color.cDanger : .cTextMedium)
                                        .font(.system(size: 14))
                                    Text(DynamicUtils.tableValue(key: "CYCLE", selected: slCycle, defaultValue: "envChoose".localized()))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.cTextHigh)
                                        .font(.system(size: 16))
                                }
                                Spacer()
                                Image("ic-arrow-expand-more")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                                    .foregroundColor(.cIcon)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .sheet(isPresented: $modalCycle) {
                            DialogSourcePickerView(selected: $slCycle, key: "CYCLE", multiple: false, title: "envCycle") { _ in
                                model.cycleId = Utils.castInt(value: slCycle[0])
                                modalCycle = false
                            }
                        }
                        HStack {
                            VStack(alignment: .leading) {
                                DatePicker("", selection: $model.date, in: minReportDate...Date(), displayedComponents: .date)
                                    .fixedSize()
                            }
                            Spacer()
                            Image("ic-calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 26)
                                .foregroundColor(.cIcon)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    HStack {
                        Button {
                            modalContactType = true
                        } label: {
                            HStack {
                                VStack {
                                    Text("envContactType")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.cTextMedium)
                                        .font(.system(size: 14))
                                    Text(DynamicUtils.jsonValue(data: contactTypes, selected: slContactType))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.cTextHigh)
                                        .font(.system(size: 16))
                                }
                                Spacer()
                                Image("ic-arrow-expand-more")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                                    .foregroundColor(.cIcon)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .sheet(isPresented: $modalContactType) {
                            DialogPlainPickerView(selected: $slContactType, data: contactTypes, multiple: false, title: "envContactType".localized()) { _ in
                                model.contactType = slContactType[0]
                                modalContactType = false
                                validate()
                            }
                        }
                        if model.contactType != "P" {
                            Button {
                                modalContactedBy = true
                            } label: {
                                HStack {
                                    VStack{
                                        Text(NSLocalizedString("envContactedBy", comment: ""))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(model.contactedBy.isEmpty ? Color.cDanger : .cTextMedium)
                                            .font(.system(size: 14))
                                        Text(DynamicUtils.jsonValue(data: contactedByOptions, selected: slContactedBy))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.cTextHigh)
                                            .font(.system(size: 16))
                                    }
                                    Spacer()
                                    Image("ic-arrow-expand-more")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35)
                                        .foregroundColor(.cIcon)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .sheet(isPresented: $modalContactedBy) {
                                DialogPlainPickerView(selected: $slContactedBy, data: contactedByOptions, multiple: true, title: "envContactedBy".localized()) { _ in
                                    model.contactedBy = slContactedBy.joined(separator: ",")
                                    modalContactedBy = false
                                    validate()
                                }
                            }
                        }
                    }
                }
                CustomSection {
                    if ctComment.visible {
                        if ctComment.controlType == "text-field" {
                            VStack {
                                Text("envComment")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor((model.comment.isEmpty && ctComment.required) ? .cDanger : .cTextMedium)
                                    .font(.system(size: 14))
                                VStack{
                                    TextEditor(text: $model.comment)
                                        .frame(height: 80)
                                }
                            }
                            .onChange(of: model.comment) { v in
                                validate()
                            }
                        } else {
                            Button {
                                modalComment = true
                            } label: {
                                HStack {
                                    VStack{
                                        Text(NSLocalizedString("envComment", comment: ""))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(model.comment.isEmpty && ctComment.required ? Color.cDanger : .cTextMedium)
                                            .font(.system(size: 14))
                                        Text(DynamicUtils.tableValue(key: "PREDEFINED-COMMENT", selected: slComment, defaultValue: "envChoose".localized()))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.cTextHigh)
                                            .font(.system(size: 16))
                                    }
                                    Spacer()
                                    Image("ic-arrow-expand-more")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35)
                                        .foregroundColor(.cIcon)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .sheet(isPresented: $modalComment) {
                                DialogSourcePickerView(selected: $slTargetNext, key: "PREDEFINED-COMMENT", multiple: false, title: "envComment".localized(), extraData: ["table": "movimientos", "field": "comentario"]) { _ in
                                    model.comment = DynamicUtils.tableValue(key: "PREDEFINED-COMMENT", selected: slTargetNext, defaultValue: "")
                                    modalComment = false
                                    validate()
                                }
                            }
                        }
                    }
                    if ctTarget.visible {
                        if ctTarget.controlType == "text-field" {
                            VStack {
                                Text("envTargetNext")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor((model.targetNext.isEmpty && ctTarget.required) ? .cDanger : .cTextMedium)
                                    .font(.system(size: 14))
                                VStack{
                                    TextEditor(text: $model.targetNext)
                                        .frame(height: 80)
                                }
                            }
                            .onChange(of: model.targetNext) { v in
                                validate()
                            }
                        } else {
                            Button {
                                modalTargetNext = true
                            } label: {
                                HStack {
                                    VStack{
                                        Text(NSLocalizedString("envTargetNext", comment: ""))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(model.targetNext.isEmpty && ctTarget.required ? Color.cDanger : .cTextMedium)
                                            .font(.system(size: 14))
                                        Text(DynamicUtils.tableValue(key: "PREDEFINED-COMMENT", selected: slTargetNext, defaultValue: "envChoose".localized()))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.cTextHigh)
                                            .font(.system(size: 16))
                                    }
                                    Spacer()
                                    Image("ic-arrow-expand-more")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35)
                                        .foregroundColor(.cIcon)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .sheet(isPresented: $modalTargetNext) {
                                DialogSourcePickerView(selected: $slTargetNext, key: "PREDEFINED-COMMENT", multiple: false, title: "envTargetNext".localized(), extraData: ["table": "movimientos", "field": "objetivo_proxima"]) { _ in
                                    model.targetNext = DynamicUtils.tableValue(key: "PREDEFINED-COMMENT", selected: slTargetNext, defaultValue: "")
                                    modalTargetNext = false
                                    validate()
                                }
                            }
                        }
                    }
                    if ctDuration.visible {
                        Button {
                            if isDurationSelectable() {
                                modalDuration = true
                            }
                        } label: {
                            VStack {
                                Text(NSLocalizedString("envDuration", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(model.duration <= 0 && ctDuration.required ? Color.cDanger : .cTextMedium)
                                    .font(.system(size: 14))
                                HStack {
                                    VStack {
                                        Text("\(Utils.zero(n: modelDuration.hour))")
                                            .foregroundColor(.cTextHigh)
                                            .font(.system(size: 26))
                                        Text("envHours")
                                            .foregroundColor(.cTextMedium)
                                            .font(.system(size: 13))
                                    }
                                    Text(":")
                                        .foregroundColor(.cTextMedium)
                                        .font(.system(size: 22))
                                    VStack {
                                        Text("\(Utils.zero(n: modelDuration.minute))")
                                            .foregroundColor(.cTextHigh)
                                            .font(.system(size: 26))
                                        Text("envMinutes")
                                            .foregroundColor(.cTextMedium)
                                            .font(.system(size: 13))
                                    }
                                    Text(":")
                                        .foregroundColor(.cTextMedium)
                                        .font(.system(size: 22))
                                    VStack {
                                        Text("\(Utils.zero(n: modelDuration.second))")
                                            .foregroundColor(.cTextHigh)
                                            .font(.system(size: 26))
                                        Text("envSeconds")
                                            .foregroundColor(.cTextMedium)
                                            .font(.system(size: 13))
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .shee(isPresented: $modalDuration, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
                            DialogDurationPickerView(modelDuration: modelDuration) {
                                model.duration = (modelDuration.hour * 60 * 60) + (modelDuration.minute * 60) + modelDuration.second
                                modalDuration = false
                                validate()
                            }
                            .interactiveDismissDisabled()
                        }
                    }
                    if ctHabeasData.visible {
                        VStack {
                            HStack {
                                Button(action: {
                                    
                                }) {
                                    Image("ic-external")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.cHighlighted)
                                        .frame(width: 24, height: 24, alignment: .center)
                                }
                                .frame(width: 44, height: 44, alignment: .center)
                                Text("envHabeasData")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor((ctHabeasData.required && model.habeasData.isEmpty) ? Color.cDanger : .cTextMedium)
                                Button(action: {
                                    
                                }) {
                                    Image("ic-delete")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.cDanger)
                                        .frame(width: 24, height: 24, alignment: .center)
                                }
                                .frame(width: 44, height: 44, alignment: .center)
                                .opacity(model.habeasData == "Y" ? 1 : 0)
                            }
                            ImageViewerWrapperView(value: $model.habeasData, defaultIcon: "ic-habeas-data", table: hdTable, field: "habeas_data", id: model.panelId, localId: model.panelObjectId) {
                                actionSheet = true
                            }
                        }
                        .actionSheet(isPresented: $actionSheet) {
                            ActionSheet(title: Text("envSelect"), message: nil, buttons: Widgets.mediaSourcePickerButtons(available: Utils.castString(value: pickerSources["HABEAS-DATA"], defaultValue: "D,C,G"), action: onSourceSelected))
                        }
                        .sheet(isPresented: $modalCamera) {
                            CustomImagePickerView(sourceType: .camera, uiImage: self.$uiImage, onSelectionDone: onSelectionDone)
                        }
                        .sheet(isPresented: $modalDraw) {
                            CanvasDrawerDialog(uiImage: self.$uiImage, title: "envHabeasData".localized(), onSelectionDone: onSelectionDone)
                        }
                        .sheet(isPresented: $modalGallery) {
                            CustomImagePickerView(sourceType: .photoLibrary, uiImage: self.$uiImage, onSelectionDone: onSelectionDone)
                        }
                    }
                    if ctContacts.visible {
                        Button {
                            modalContacts = true
                        } label: {
                            HStack {
                                VStack {
                                    Text(NSLocalizedString("envContacts", comment: ""))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(model.contacts.isEmpty && ctContacts.required ? Color.cDanger : .cTextMedium)
                                        .font(.system(size: 14))
                                    Text(DynamicUtils.tableValue(key: "USER", selected: slContacts, defaultValue: "envChoose".localized()))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.cTextHigh)
                                        .font(.system(size: 16))
                                }
                                Spacer()
                                Image("ic-arrow-expand-more")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                                    .foregroundColor(.cIcon)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .sheet(isPresented: $modalCompanion) {
                            DialogSourcePickerView(selected: $slCompanion, key: "COMPANION", multiple: false, title: "envCompanion") { _ in
                                model.contacts = ""
                                modalContacts = false
                                validate()
                            }
                        }
                    }
                    if ctCompanion.visible {
                        Button {
                            modalCompanion = true
                        } label: {
                            HStack {
                                VStack {
                                    Text(NSLocalizedString("envCompanion", comment: ""))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(model.companionId <= 0 && ctCompanion.required ? Color.cDanger : .cTextMedium)
                                        .font(.system(size: 14))
                                    Text(DynamicUtils.tableValue(key: "USER", selected: slCompanion, defaultValue: "envChoose".localized()))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.cTextHigh)
                                        .font(.system(size: 16))
                                }
                                Spacer()
                                Image("ic-arrow-expand-more")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                                    .foregroundColor(.cIcon)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .sheet(isPresented: $modalCompanion) {
                            DialogSourcePickerView(selected: $slCompanion, key: "COMPANION", multiple: false, title: "envCompanion") { _ in
                                model.companionId = Utils.castInt(value: slCompanion[0])
                                modalCompanion = false
                                validate()
                            }
                        }
                    }
                }
                ForEach($dynamicForm.tabs) { $tab in
                    DynamicFormView(form: $dynamicForm, tab: $tab, options: dynamicOptions)
                }
            }
        }
        .onAppear {
            initForm()
        }
        .shee(isPresented: $modalInfo, presentationStyle: .formSheet(properties: .init(detents: [.medium(), .large()]))) {
            if let p = PanelUtils.panel(type: model.panelType, objectId: model.panelObjectId) {
                PanelInfoDialog(panel: p)
            }
        }
        .sheet(isPresented: $modalFailedReason) {
            DialogSourcePickerView(selected: $slFailedReason, key: "MOVEMENT-FAIL-REASON", multiple: false, title: "envReason", extraData: ["panelType": model.panelType]) { _ in
                modalFailedReason = false
                modalFailedForm = true
            }
        }
        .shee(isPresented: $modalFailedForm, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
            VStack {
                Text("envVisitFailed")
                    .foregroundColor(.cTextMedium)
                    .padding(.vertical, 8)
                Spacer()
                CustomCard {
                    VStack {
                        Text("\("envComment".localized()) (\("envOptional".localized()))")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextMedium)
                            .font(.system(size: 14))
                        VStack{
                            TextEditor(text: $commentFailed)
                                .frame(height: 80)
                        }
                    }
                }
                .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
                Spacer()
                HStack {
                    Button(action: {
                        modalFailedForm = false
                    }) {
                        Text("envCancel")
                            .foregroundColor(.cTextHigh)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    Button(action: {
                        saveFailed()
                        modalFailedForm = false
                    }) {
                        Text("envSave")
                            .foregroundColor(.cTextHigh)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                }
            }
        }
    }
    
    func initForm() {
        initialValue = model.habeasData
        hdTable = PanelUtils.awsPathByPanelType(panelType: model.panelType)
        let splitTime = TimeUtils.splitTime(value: model.duration)
        modelDuration.hour = splitTime[0]
        modelDuration.minute = splitTime[1]
        modelDuration.second = splitTime[2]
        if let panelOptions = Utils.jsonDictionary(string: baseForm)[model.panelType] as? Dictionary<String, Any> {
            if let visitTypeOptions = panelOptions[visitType.lowercased()] as? Dictionary<String, Any> {
                ctComment = fillFieldOptions(data: visitTypeOptions, key: "comment")
                ctCompanion = fillFieldOptions(data: visitTypeOptions, key: "companion")
                ctContacts = fillFieldOptions(data: visitTypeOptions, key: "contacts")
                ctDuration = fillFieldOptions(data: visitTypeOptions, key: "duration")
                ctHabeasData = fillFieldOptions(data: visitTypeOptions, key: "habeas-data")
                ctTarget = fillFieldOptions(data: visitTypeOptions, key: "target")
            }
        }
        slContactType = model.contactType.components(separatedBy: ",")
        slContactedBy = model.contactedBy.components(separatedBy: ",")
        slCycle = String(model.cycleId).components(separatedBy: ",")
        
        validate()
    }
    
    func fillFieldOptions(data: Dictionary<String, Any>, key: String) -> MovementFieldModel {
        if let opts = data[key] as? Dictionary<String, Any> {
            return MovementFieldModel(required: Utils.castInt(value: opts["required"]) == 1, visible: Utils.castInt(value: opts["visible"]) == 1, controlType: Utils.castString(value: opts["type"]))
        }
        return MovementFieldModel(required: false, visible: true)
    }
    
    func onSourceSelected(s: String) {
        actionSheet = false
        switch s {
            case "C":
                modalCamera = true
            case "D":
                modalDraw = true
            case "G":
                modalGallery = true
            default:
                break;
        }
    }
    
    func onSelectionDone(_ done: Bool) {
        self.modalCamera = false
        self.modalDraw = false
        self.modalGallery = false
        model.habeasData = ""
        if done {
            MediaUtils.store(
                uiImage: uiImage,
                table: hdTable,
                field: "habeas_data",
                id: model.panelId,
                localId: model.panelObjectId
            )
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            model.habeasData = done ? "Y" : initialValue
            validate()
        }
    }
    
    func isDurationSelectable() -> Bool {
        let callLastStart = UserDefaults.standard.integer(forKey: "")
        if callLastStart > 0 {
            return false
        }
        if reportType == 2 && model.contactType == "P" {
            return false
        }
        return true
    }
    
    func saveFailed() {
        let movement = Movement()
        movement.panelType = model.panelType
        movement.panelId = model.panelId
        movement.panelObjectId = model.panelObjectId
        movement.executed = 0
        movement.movementFailReasonId = Utils.castInt(value: slFailedReason[0])
        movement.visitType = visitType
        movement.transactionStatus = model.panelId == 0 ? "PENDING" : ""
        movement.comment = commentFailed
        movement.date = Utils.currentDate()
        movement.realDate = Utils.currentDate()
        movement.hour = Utils.hourFormat(date: Date(), format: "HH:mm")
        movement.cycleId = CycleDao(realm: try! Realm()).active().first?.id ?? 0
        movement.transactionType = "CREATE"
        MovementDao(realm: try! Realm()).store(movement: movement)
        
        viewRouter.currentPage = "MASTER"
    }
    
    func validate() {
        valid = false
        if model.contactType != "P" && model.contactedBy.isEmpty {
            return
        }
        if ctComment.required && model.comment.isEmpty {
            return
        }
        if ctTarget.required && model.targetNext.isEmpty {
            return
        }
        if ctDuration.required && model.duration <= 0 {
            return
        }
        if ctHabeasData.required && model.habeasData.isEmpty {
            return
        }
        if ctContacts.required && model.contacts.isEmpty {
            return
        }
        if ctCompanion.required && model.companionId <= 0 {
            return
        }
        valid = true
    }
    
}

struct MovementTabContentWrapperView: View {
    var realm: Realm
    var key: String
    var visitType: String
    var isEditable: Bool
    var locationAvailable: Bool
    var extraData: [String: Any]
    
    @StateObject var model: MovementModel
    @Binding var dynamicForm: DynamicForm
    @Binding var dynamicOptions: DynamicFormFieldOptions
    
    @Binding var materials: [AdvertisingMaterialDeliveryMaterial]
    @Binding var promoted: [String]
    @Binding var stock: [MovementProductStockModel]
    @Binding var shopping: [MovementProductShoppingModel]
    @Binding var transference: [MovementProductTransferenceModel]
    
    @Binding var basicValid: Bool
    
    var body: some View {
        switch key {
            case "MATERIAL":
                MovementFormTabMaterialView(realm: realm, materials: $materials)
            case "PROMOTED":
                MovementFormTabPromotedView(realm: realm, isEditable: isEditable, extraData: extraData, selected: $promoted)
            case "SHOPPING":
                MovementFormTabShoppingView(realm: realm, items: $shopping)
            case "STOCK":
                MovementFormTabStockView(realm: realm, items: $stock)
            case "TRANSFERENCE":
                MovementFormTabTransferenceView(realm: realm, visitType: visitType, items: $transference)
            case "MORE", "BACK":
                ScrollView {
                    
                }
            default:
                MovementFormTabBasicView(model: model, valid: $basicValid, dynamicForm: $dynamicForm, dynamicOptions: $dynamicOptions, visitType: visitType, locationAvailable: locationAvailable)
        }
    }
    
}
