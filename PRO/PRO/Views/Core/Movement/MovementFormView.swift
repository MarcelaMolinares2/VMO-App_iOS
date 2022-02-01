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
    
    var title = ""
    var icon = "ic-home"
    var color = Color.cPrimary
    var visitType = "NORMAL"
    
    @State private var locationRequired = Config.get(key: "MOV_LOCATION_REQUIRED").value == 1
    
    @State private var movement: Movement = Movement()
    @State private var panel: Panel?
    @State private var promotedProducts = [String]()
    
    var body: some View {
        VStack {
            HeaderToggleView(couldSearch: false, title: title, icon: Image(icon), color: color)
            Button(action: {
                print(movement)
                print(locationService.location ?? "")
            }) {
                Text("Test")
            }
            if locationRequired && locationService.location == nil {
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
                    switch tabRouter.current {
                        case "MATERIAL":
                            MovementFormTabMaterialView(selected: $movement.dataMaterial)
                        case "PROMOTED":
                            MovementFormTabPromotedView(selected: $promotedProducts)
                        case "SHOPPING":
                            MovementFormTabShoppingView(selected: $movement.dataShopping)
                        case "STOCK":
                            MovementFormTabStockView(selected: $movement.dataStock)
                        case "TRANSFERENCE":
                            MovementFormTabTransferenceView(selected: $movement.dataTransference, visitType: visitType)
                        default:
                            MovementFormTabBasicView(movement: $movement, location: locationService.location, panel: panel!, op: viewRouter.data.objectId.isEmpty ? "create" : "update", visitType: visitType)
                    }
                    MovementBottomNavigationView(tabRouter: tabRouter)
                }
            }
        }
        .onAppear {
            locationService.start()
            initForm()
        }
        .onDisappear {
            locationService.stop()
        }
    }
    
    func initForm() {
        panel = PanelUtils.panel(type: viewRouter.data.type, objectId: viewRouter.data.objectId)
        if viewRouter.data.objectId.isEmpty {
            movement.panelId = panel?.id ?? 0
            movement.panelObjectId = viewRouter.data.objectId
            movement.panelType = viewRouter.data.type
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
    @State private var options = DynamicFormFieldOptions(table: "movement", op: "")
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
                            .foregroundColor(.cWarning)
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
        options.op = op
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


struct MovementFormTabMaterialView: View {
    
    @Binding var selected: RealmSwift.List<MovementMaterial>
    
    var body: some View {
        ScrollView {
            VStack {
                Text("MATERIAL!!!!")
            }
        }
    }
    
}

struct MovementBottomNavigationView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @StateObject var tabRouter: TabRouter
    
    @State var mainTabs = [[String: Any]]()
    @State var moreTabs = [[String: Any]]()
    @State var bottomNavActive = "MAIN"
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                if bottomNavActive == "MAIN" {
                    Image("ic-visit")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(mainTabs.count + 1 + (moreTabs.isEmpty ? 0 : 1)), alignment: .center)
                        .foregroundColor(tabRouter.current == "BASIC" ? .cPrimary : .cAccent)
                        .onTapGesture {
                            tabRouter.current = "BASIC"
                        }
                    ForEach(mainTabs.indices, id: \.self) { index in
                        let key = Utils.castString(value: mainTabs[index]["key"])
                        Image(MovementUtils.iconTabs(key: key))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / CGFloat(mainTabs.count + 1 + (moreTabs.isEmpty ? 0 : 1)), alignment: .center)
                            .foregroundColor(tabRouter.current == key ? .cPrimary : .cAccent)
                            .onTapGesture {
                                tabRouter.current = key
                            }
                    }
                    if !moreTabs.isEmpty {
                        Image("ic-more")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / CGFloat(mainTabs.count + 2), alignment: .center)
                            .foregroundColor(.cAccent)
                            .onTapGesture {
                                bottomNavActive = "MORE"
                                tabRouter.current = "ROTATION"
                            }
                    }
                } else {
                    Image("ic-back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(moreTabs.count + 1), alignment: .center)
                        .foregroundColor(.cAccent)
                        .onTapGesture {
                            bottomNavActive = "MAIN"
                            tabRouter.current = "BASIC"
                        }
                    ForEach(moreTabs.indices, id: \.self) { index in
                        let key = Utils.castString(value: moreTabs[index]["key"])
                        Image(MovementUtils.iconTabs(key: key))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / CGFloat(moreTabs.count + 1), alignment: .center)
                            .foregroundColor(tabRouter.current == key ? .cPrimary : .cAccent)
                            .onTapGesture {
                                tabRouter.current = key
                            }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 46, maxHeight: 46)
        .onAppear {
            load()
        }
    }
    
    func load() {
        let tabs = MovementUtils.initTabs(data: MovementUtils.tabs(panelType: viewRouter.data.type, visitType: Utils.castString(value: viewRouter.data.options["visitType"]).lowercased()))
        mainTabs = tabs[0]
        moreTabs = tabs[1]
        tabRouter.current = "BASIC"
    }
    
    
}
