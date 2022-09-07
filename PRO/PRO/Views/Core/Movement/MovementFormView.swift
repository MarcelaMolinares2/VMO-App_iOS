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
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modVisit") {
                viewRouter.currentPage = "MASTER"
            }
            if locationRequired && locationService.location == nil || (locationService.location?.coordinate.latitude == 0 && locationService.location?.coordinate.longitude == 0) {
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
                                        MovementTabContentWrapperView(realm: realm, key: tab.key, visitType: visitType, isEditable: true, extraData: extraData, materials: $materials, promoted: $promoted, stock: $stock, shopping: $shopping, transference: $transference)
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
                                        MovementTabContentWrapperView(realm: realm, key: tab.key, visitType: visitType, isEditable: true, extraData: extraData, materials: $materials, promoted: $promoted, stock: $stock, shopping: $shopping, transference: $transference)
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
    }
}

struct MovementFormTabBasicView: View {
    
    @Binding var movement: Movement
    @State var location: CLLocation?
    @State var panel: Panel
    var op: String
    var visitType: String
    
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "movement", op: .view)
    @State private var formAssistance = false
    @State private var formInPoint = false
    
    @State private var showInfoDialog = false
    
    @State private var basicFormOpts = Config.get(key: "MOV_LOCATION_REQUIRED").value == 1
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Image("ic-info")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(5), alignment: .center)
                        .foregroundColor(.cInfo)
                        .onTapGesture {
                            showInfoDialog = true
                        }
                    Image(formAssistance ? "ic-notification-fill" : "ic-notification")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(5), alignment: .center)
                        .foregroundColor(formAssistance ? .cToggleActive : .cAccent)
                        .onTapGesture {
                            toggleAssistance()
                        }
                    Image(location == nil ? "ic-location-disabled" : "ic-location")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(5), alignment: .center)
                        .foregroundColor(formInPoint ? .cToggleActive : .cAccent)
                        .onTapGesture {
                            if location != nil {
                                toggleInPoint()
                            }
                        }
                    if true {
                        Image("ic-warning")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / CGFloat(5), alignment: .center)
                            .foregroundColor(.cError)
                            .onTapGesture {
                                
                            }
                    }
                    if true {
                        Image("ic-delete")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / CGFloat(5), alignment: .center)
                            .foregroundColor(.cDanger)
                            .onTapGesture {
                                
                            }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 38, maxHeight: 38)
            Form {
                Section {
                    HStack {
                        HStack{
                            VStack{
                                Text(NSLocalizedString("envCycle", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))
                                Text((movement.cycleId <= 0) ? NSLocalizedString("envChoose", comment: "") : "----")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 16))
                            }
                            Spacer()
                            Image("ic-arrow-expand-more")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35)
                                .foregroundColor(.cTextMedium)
                        }
                        .padding(10)
                        HStack{
                            VStack{
                                Text(NSLocalizedString("envFrom", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))
                                DatePicker("", selection: $movement.tmpDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                    .clipped()
                                    .accentColor(.cTextHigh)
                                    .background(Color.white)
                                    .onChange(of: movement.tmpDate, perform: { value in
                                        
                                    })
                            }
                            .padding(10)
                            Spacer()
                            Image("ic-day-request")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 35)
                                .foregroundColor(.cTextMedium)
                                .padding(10)
                        }
                    }
                    VStack {
                    }
                    VStack {
                        HStack {
                            Text("AAAAA")
                            Text("DDDDD")
                        }
                    }
                    VStack {
                        HStack {
                            Text("AAAAA")
                            Text("DDDDD")
                        }
                    }
                    VStack {
                        HStack {
                            Text("AAAAA")
                            Text("DDDDD")
                        }
                    }
                    VStack {
                        HStack {
                            Text("AAAAA")
                            Text("DDDDD")
                        }
                    }
                    VStack {
                        HStack {
                            Text("AAAAA")
                            Text("DDDDD")
                        }
                    }
                    VStack {
                        HStack {
                            Text("AAAAA")
                            Text("DDDDD")
                        }
                    }
                    VStack {
                        HStack {
                            Text("AAAAA")
                            Text("DDDDD")
                        }
                    }
                    VStack {
                        HStack {
                            Text("AAAAA")
                            Text("DDDDD")
                        }
                    }
                }
                ForEach(form.tabs, id: \.id) { tab in
                    DynamicFormView(form: $form, tab: $form.tabs[0], options: options)
                }
            }
        }
        .onAppear {
            initForm()
        }
        .partialSheet(isPresented: $showInfoDialog) {
            PanelInfoDialog(panel: panel)
        }
    }
    
    func initForm() {
        options.objectId = movement.objectId
        options.item = movement.id
        options.op = .create
        options.type = visitType.lowercased()
        options.panelType = panel.type
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_MOV_FORM_ADDITIONAL").complement ?? "")

        initDynamic(data: dynamicData)
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        plainData = try! Utils.objToJSON(movement)
        additionalData = (movement.additionalFields ?? "").isEmpty ? (movement.additionalFields ?? "{}") : "{}"
        
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        if !plainData.isEmpty {
            DynamicUtils.fillForm(form: &form, base: plainData, additional: additionalData)
        }
    }
    
    func toggleAssistance() {
        formAssistance.toggle()
        movement.rqAssistance = formAssistance ? 1 : 0
    }
    
    func toggleInPoint() {
        formInPoint.toggle()
        movement.assocPanelLocation = formInPoint
    }
    
}

struct MovementTabContentWrapperView: View {
    var realm: Realm
    var key: String
    var visitType: String
    var isEditable: Bool
    var extraData: [String: Any]
    
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
                ScrollView {
                    
                }
        }
    }
    
}
