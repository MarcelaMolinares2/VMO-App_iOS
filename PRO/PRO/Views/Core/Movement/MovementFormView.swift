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

class MovementModel: ObservableObject {
    @Published var date: Date = Date()
    @Published var comment: String = ""
    @Published var fields: String = ""
    
    @Published var requestAssistance = false
    @Published var attachPanelLocation = false
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
    
    @State private var movement: Movement = Movement()
    @State private var panel: Panel?
    
    @State private var materials = [AdvertisingMaterialDeliveryMaterial]()
    @State private var promoted = [String]()
    @State private var stock = [MovementProductStockModel]()
    @State private var shopping = [MovementProductShoppingModel]()
    @State private var transference = [MovementProductTransferenceModel]()
    
    @State private var mainTabsLayout = true
    
    @State var mainTabs = [MovementTab]()
    @State var moreTabs = [MovementTab]()
    
    @State private var extraData: [String: Any] = [:]
    
    @State private var dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_MOV_FORM_ADDITIONAL").complement ?? "")
    @State private var dynamicForm = DynamicForm(tabs: [DynamicFormTab]())
    @State private var dynamicOptions = DynamicFormFieldOptions(table: "move", op: .view)
    
    @State private var model = MovementModel()
    
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
                                        MovementTabContentWrapperView(realm: realm, key: tab.key, visitType: visitType, isEditable: true, locationAvailable: locationAvailable, extraData: extraData, model: $model, dynamicForm: $dynamicForm, dynamicOptions: $dynamicOptions, materials: $materials, promoted: $promoted, stock: $stock, shopping: $shopping, transference: $transference)
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
                                        MovementTabContentWrapperView(realm: realm, key: tab.key, visitType: visitType, isEditable: true, locationAvailable: locationAvailable, extraData: extraData, model: $model, dynamicForm: $dynamicForm, dynamicOptions: $dynamicOptions, materials: $materials, promoted: $promoted, stock: $stock, shopping: $shopping, transference: $transference)
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
                                    //validate()
                                }
                            }
                            .padding(.bottom, Globals.UI_FAB_VERTICAL + 50)
                            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
                        }
                    }
                }
            }
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
            initForm()
        }
        .onDisappear {
            locationService.stop()
        }
    }
    
    func initForm() {
        let tabs = MovementUtils.initTabs(data: MovementUtils.tabs(panelType: viewRouter.data.type, visitType: Utils.castString(value: viewRouter.data.options["visitType"]).lowercased()))
        mainTabs = tabs[0]
        moreTabs = tabs[1]
        tabRouter.current = "BASIC"
        
        if let oId = viewRouter.data.objectId {
            panel = PanelUtils.panel(type: viewRouter.data.type, objectId: oId)
            movement.panelId = panel?.id ?? 0
            movement.panelObjectId = oId
            movement.panelType = viewRouter.data.type
            
            if movement.panelType == "F" {
                let pharmacy = PharmacyDao(realm: realm).by(objectId: oId)
                extraData["pharmacyChain"] = pharmacy?.pharmacyChainId
            }
        } else {
            //doctor = Movement(value: try! MovementDao(realm: try! Realm()).by(objectId: ObjectId(string: viewRouter.data.objectId)) ?? Doctor())
        }
        
        initDynamic()
    }
    
    func initDynamic() {
        dynamicForm.tabs = DynamicUtils.initForm(data: dynamicData).sorted(by: { $0.key > $1.key })
        if !model.fields.isEmpty {
            DynamicUtils.fillForm(form: &dynamicForm, base: model.fields)
        }
        dynamicOptions.op = .create
    }
}

struct MovementFormTabBasicView: View {
    @Binding var model: MovementModel
    @Binding var dynamicForm: DynamicForm
    @Binding var dynamicOptions: DynamicFormFieldOptions
    var visitType: String
    var locationAvailable: Bool
    
    @State private var requestAssistance = false
    @State private var attachPanelLocation = false
    
    @State private var modalInfo = false
    
    let reportType = Config.get(key: "MOV_REPORT_TYPE").value
    
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
            CustomForm {
                ForEach($dynamicForm.tabs) { $tab in
                    DynamicFormView(form: $dynamicForm, tab: $tab, options: dynamicOptions)
                }
            }
        }
        .onAppear {
            initForm()
        }
        .partialSheet(isPresented: $modalInfo) {
            //PanelInfoDialog(panel: panel)
        }
    }
    
    func initForm() {
    }
    
}

struct MovementTabContentWrapperView: View {
    var realm: Realm
    var key: String
    var visitType: String
    var isEditable: Bool
    var locationAvailable: Bool
    var extraData: [String: Any]
    
    @Binding var model: MovementModel
    @Binding var dynamicForm: DynamicForm
    @Binding var dynamicOptions: DynamicFormFieldOptions
    
    @Binding var materials: [AdvertisingMaterialDeliveryMaterial]
    @Binding var promoted: [String]
    @Binding var stock: [MovementProductStockModel]
    @Binding var shopping: [MovementProductShoppingModel]
    @Binding var transference: [MovementProductTransferenceModel]
    
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
                MovementFormTabBasicView(model: $model, dynamicForm: $dynamicForm, dynamicOptions: $dynamicOptions, visitType: visitType, locationAvailable: locationAvailable)
        }
    }
    
}
