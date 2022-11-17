//
//  MovementSummaryView.swift
//  PRO
//
//  Created by VMO on 9/11/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import GoogleMaps
import RealmSwift

struct MovementSummaryView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    
    @Binding var movementReport: MovementReport
    @Binding var modalSummary: Bool

    @State private var movement: Movement = Movement()
    @State private var panel: Panel?
    
    @State private var isProcessing = false
    @State private var mainTabsLayout = true
    
    @State var mainTabs = [MovementTab]()
    @State var moreTabs = [MovementTab]()
    
    let realm = try! Realm()
    
    var body: some View {
        VStack {
            if isProcessing {
                Spacer()
                LottieView(name: "sync_animation", loopMode: .loop, speed: 1)
                    .frame(width: 300, height: 200)
                Spacer()
            } else {
                if let p = panel {
                    VStack {
                        PanelFormHeaderView(panel: p)
                    }
                    .background(Color.cBackground1dp)
                }
                ZStack(alignment: .bottom) {
                    if mainTabsLayout {
                        TabView(selection: $tabRouter.current) {
                            ForEach(mainTabs) { tab in
                                MovementSummaryTabContentWrapperView(realm: realm, key: tab.key, movement: $movement)
                                    .tag(tab.key)
                                    .tabItem {
                                        Text(tab.label.localized())
                                        Image(tab.icon)
                                    }
                            }
                        }
                        .tabViewStyle(DefaultTabViewStyle())
                    } else {
                        TabView(selection: $tabRouter.current) {
                            ForEach(moreTabs) { tab in
                                MovementSummaryTabContentWrapperView(realm: realm, key: tab.key, movement: $movement)
                                    .tag(tab.key)
                                    .tabItem {
                                        Text(tab.label.localized())
                                        Image(tab.icon)
                                    }
                            }
                        }
                        .tabViewStyle(DefaultTabViewStyle())
                    }
                    HStack(alignment: .bottom) {
                        Spacer()
                        if MovementUtils.isCycleActive(realm: realm, id: movement.cycleId) && movementReport.reportedBy == JWTUtils.sub() && movement.executed == 1 && !["NOTES"].contains(tabRouter.current) {
                            FAB(image: "ic-edit") {
                                FormEntity(objectId: nil, type: "", options: [ "oId": movement.objectId.stringValue, "id": String(movement.id) ]).go(path: "MOVEMENT-FORM", router: viewRouter)
                            }
                        }
                    }
                    .padding(.bottom, Globals.UI_FAB_VERTICAL + 50)
                    .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
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
            load()
        }
    }
    
    func load() {
        isProcessing = true
        if let m = MovementDao(realm: realm).by(objectId: movementReport.objectId.stringValue) {
            movement = Movement(value: m)
            panel = PanelUtils.panel(type: movement.panelType, objectId: movement.panelObjectId, id: movement.panelId)
            initForm()
        } else {
            getMovement(id: String(movementReport.serverId))
        }
    }
    
    func getMovement(id: String) {
        AppServer().postRequest(data: [:], path: "vm/movement/mobile/detail/\(id)") { success, code, data in
            if success {
                print(data)
                if let rs = data as? Dictionary<String, Any> {
                    let item = Utils.dictionaryToJSON(data: rs)
                    if let decoded = try? JSONDecoder().decode(Movement.self, from: item.data(using: .utf8)!) {
                        movement = decoded
                        panel = movement.panel
                        DispatchQueue.main.async {
                            print(movement)
                            initForm()
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                isProcessing = false
            }
        }
    }
    
    func initForm() {
        let tabs = MovementUtils.initTabs(data: MovementUtils.tabs(panelType: movement.panelType, visitType: movement.visitType.lowercased()), summary: true)
        mainTabs = tabs[0]
        moreTabs = tabs[1]
        tabRouter.current = "BASIC"
    }
}

struct MovementSummaryBasicView: View {
    let realm: Realm
    @Binding var movement: Movement
    
    @State private var dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_MOV_FORM_ADDITIONAL").complement ?? "")
    @State private var dynamicForm = DynamicForm(tabs: [DynamicFormTab]())
    @State private var dynamicOptions = DynamicFormFieldOptions(table: "movement", op: .view)
    
    let contactTypes = Config.get(key: "MOV_CONTACT_TYPES").complement ?? ""
    
    var body: some View {
        VStack {
            MovementSummaryMapView(item: movement.report(realm: realm))
                .frame(maxHeight: 200)
            ScrollView {
                CustomForm {
                    HStack {
                        VStack {
                            Text(Utils.dateFormat(value: movement.date, toFormat: "dd MMM yyy", fromFormat: "yyyy-MM-dd"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.leading)
                            Text(movement.hour)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.trailing)
                        }
                        Spacer()
                        Text(DynamicUtils.jsonValue(data: contactTypes, selected: [movement.contactType]))
                            .foregroundColor(.cTextHigh)
                            .font(.system(size: 14))
                            .multilineTextAlignment(.leading)
                    }
                    Divider()
                    CustomSection {
                        VStack {
                            Text("envComment".localized())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            Text(movement.comment ?? "--")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.leading)
                        }
                        Divider()
                        VStack {
                            Text("envTargetNext".localized())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            Text(movement.target ?? "--")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    CustomSection {
                        HStack {
                            VStack {
                                Text("envCycle".localized())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))
                                let cycle = CycleDao(realm: realm).by(id: movement.cycleId)
                                Text(cycle?.displayName ?? "--")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextHigh)
                                    .font(.system(size: 14))
                                    .multilineTextAlignment(.leading)
                            }
                            VStack {
                                Text("envVisitDuration".localized())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))
                                let splitTime = TimeUtils.splitTime(value: movement.duration ?? 0)
                                Text(String(format: "sepHour".localized(), Utils.zero(n: splitTime[0]), Utils.zero(n: splitTime[1]), Utils.zero(n: splitTime[2])))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextHigh)
                                    .font(.system(size: 14))
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        Divider()
                        VStack {
                            Text("envContacts".localized())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            Text("--")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.leading)
                        }
                        VStack {
                            Text("envCompanion".localized())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            let companion = UserDao(realm: realm).by(id: movement.companionId ?? 0)
                            Text(companion?.name ?? "--")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    ForEach($dynamicForm.tabs) { $tab in
                        DynamicFormSummaryView(form: $dynamicForm, tab: $tab, options: dynamicOptions)
                    }
                    ScrollViewFABBottom()
                }
            }
        }
        .onAppear{
            load()
        }
    }
    
    func load() {
        dynamicOptions.objectId = movement.objectId
        dynamicOptions.item = movement.id
        
        dynamicForm.tabs = DynamicUtils.initForm(data: dynamicData).sorted(by: { $0.key > $1.key })
        
        if let fields = movement.additionalFields {
            if !fields.isEmpty {
                DynamicUtils.fillForm(form: &dynamicForm, base: fields)
            }
        }
    }
}

struct MovementTimelineView: View {
    
    var body: some View {
        VStack {
            ScrollView {
                
            }
            HStack {
                Spacer()
                Button(action: {
                }) {
                    Image("ic-send-message")
                        .resizable()
                        .foregroundColor(.cDanger)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26, alignment: .center)
                }
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
            }
        }
    }
    
}

struct MovementSummaryMapView: View {
    
    var item: MovementReport
    
    @State private var markers = [GMSMarker]()
    @State private var goToMyLocation = false
    @State private var fitToBounds = false
    
    var body: some View {
        CustomMarkerMapView(markers: $markers, goToMyLocation: $goToMyLocation, fitToBounds: $fitToBounds) { marker in }
            .onAppear {
                markers.removeAll()
                if item.latitude > 0 && item.longitude > 0 {
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(item.latitude), longitude: Double(item.longitude)))
                    markers.append(marker)
                }
                fitToBounds = true
            }
    }
    
}

struct MovementSummaryTabMaterialView: View {
    var realm: Realm
    @Binding var materials: RealmSwift.List<MovementMaterial>
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach($materials, id: \.self) { $mm in
                    if let material = MaterialPlainDao(realm: realm).by(id: mm.id) {
                        CustomCard {
                            Text((material.name ?? "").capitalized)
                                .foregroundColor(.cTextHigh)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .lineLimit(2)
                            ForEach(mm.sets, id: \.self) { materialSet in
                                Divider()
                                HStack {
                                    Text(String(format: "envMaterialSet".localized(), materialSet.materialSet.label))
                                        .foregroundColor(.cTextHigh)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(2)
                                    Text(String(format: "envQuantityShortenV".localized(), String(materialSet.quantity)))
                                        .foregroundColor(.cTextHigh)
                                        .lineLimit(1)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 100, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
        }
    }
    
}

struct MovementSummaryTabPromotedView: View {
    var realm: Realm
    var ids: [String]
    
    let groupByBrand: Bool = Config.get(key: "MOV_PROMOTED_ONLY_BRAND").value == 1
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(ids, id: \.self) { id in
                    if groupByBrand {
                        if let brand = ProductBrandDao(realm: realm).by(id: id) {
                            CustomCard {
                                Text(brand.name.capitalized)
                                    .foregroundColor(.cTextHigh)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(2)
                            }
                        }
                    } else {
                        if let product = ProductDao(realm: realm).by(id: id) {
                            CustomCard {
                                Text(product.name.capitalized)
                                    .foregroundColor(.cTextHigh)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
        }
    }
    
}

struct MovementSummaryTabShoppingView: View {
    var realm: Realm
    @Binding var products: RealmSwift.List<MovementProductShopping>
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(products, id: \.self) { p in
                    if let product = ProductDao(realm: realm).by(id: p.id) {
                        CustomCard {
                            Text(product.name.capitalized)
                                .foregroundColor(.cTextHigh)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .lineLimit(2)
                            Divider()
                            HStack {
                                Text("")
                                    .foregroundColor(.cTextHigh)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(2)
                                Text(FormatUtils.currency(value: p.price))
                                    .foregroundColor(.cTextHigh)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100, alignment: .trailing)
                            }
                            ForEach(p.competitors, id: \.self) { c in
                                Divider()
                                HStack {
                                    Text(c.id.capitalized)
                                        .foregroundColor(.cTextHigh)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(2)
                                    Text(FormatUtils.currency(value: c.price))
                                        .foregroundColor(.cTextHigh)
                                        .lineLimit(1)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 100, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
        }
    }
    
}

struct MovementSummaryTabStockView: View {
    var realm: Realm
    @Binding var products: RealmSwift.List<MovementProductStock>
    
    @State private var dataReasons = Config.get(key: "MOV_STOCK_NE_REASONS").complement ?? "{}"
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(products, id: \.self) { p in
                    if let product = ProductDao(realm: realm).by(id: p.id) {
                        CustomCard {
                            HStack {
                                Text(product.name.capitalized)
                                    .foregroundColor(.cTextHigh)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(2)
                                if p.hasStock {
                                    Spacer()
                                    Text(String(format: "envQuantityShortenV".localized(), String(p.quantity)))
                                        .foregroundColor(.cTextHigh)
                                        .lineLimit(1)
                                        .multilineTextAlignment(.trailing)
                                        .frame(alignment: .trailing)
                                }
                            }
                            Divider()
                            HStack {
                                Image("ic-done-all")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(p.hasStock ? .cDone : .cError)
                                Text("envPresenceAtPointOfSale")
                                    .foregroundColor(.cTextHigh)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(2)
                            }
                            if !p.hasStock {
                                Text("envReason".localized())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))
                                Text(DynamicUtils.jsonValue(data: dataReasons, selected: [p.noStockReason]))
                                    .foregroundColor(.cTextHigh)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
        }
    }
    
}

struct MovementSummaryTabTransferenceView: View {
    var realm: Realm
    @Binding var products: RealmSwift.List<MovementProductTransference>
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(products, id: \.self) { p in
                    if let product = ProductDao(realm: realm).by(id: p.id) {
                        CustomCard {
                            Text(product.name.capitalized)
                                .foregroundColor(.cTextHigh)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .lineLimit(2)
                            Divider()
                            HStack {
                                Text(String(format: "envQuantityShortenV".localized(), String(p.quantity)))
                                    .foregroundColor(.cTextHigh)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.leading)
                                    .frame(alignment: .leading)
                                Spacer()
                                Text(String(format: "envPriceV".localized(), FormatUtils.currency(value: p.price)))
                                    .foregroundColor(.cTextHigh)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.trailing)
                                    .frame(alignment: .trailing)
                            }
                            if let bonusProduct = ProductDao(realm: realm).by(id: p.bonusProduct) {
                                Divider()
                                HStack {
                                    Text(bonusProduct.name.capitalized)
                                        .foregroundColor(.cTextMedium)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .frame(alignment: .leading)
                                    Spacer()
                                    Text(String(format: "envQuantityShortenV".localized(), String(p.bonusQuantity)))
                                        .foregroundColor(.cTextHigh)
                                        .lineLimit(1)
                                        .multilineTextAlignment(.trailing)
                                        .frame(alignment: .trailing)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
        }
    }
    
}

struct MovementSummaryTabContentWrapperView: View {
    var realm: Realm
    var key: String
    
    @Binding var movement: Movement
    
    var body: some View {
        switch key {
            case "MATERIAL":
                MovementSummaryTabMaterialView(realm: realm, materials: $movement.dataMaterial)
            case "PROMOTED":
                MovementSummaryTabPromotedView(realm: realm, ids: movement.dataPromoted.components(separatedBy: ","))
            case "SHOPPING":
                MovementSummaryTabShoppingView(realm: realm, products: $movement.dataShopping)
            case "STOCK":
                MovementSummaryTabStockView(realm: realm, products: $movement.dataStock)
            case "TRANSFERENCE":
                MovementSummaryTabTransferenceView(realm: realm, products: $movement.dataTransference)
            case "NOTES":
                MovementTimelineView()
            case "MORE", "BACK":
                ScrollView {
                    
                }
            default:
                MovementSummaryBasicView(realm: realm, movement: $movement)
        }
    }
    
}
