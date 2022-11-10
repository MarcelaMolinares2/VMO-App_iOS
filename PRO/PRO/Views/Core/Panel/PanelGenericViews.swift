//
//  PanelGenericViews.swift
//  PRO
//
//  Created by VMO on 18/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import GoogleMaps
import SheeKit

struct PanelFormHeaderView: View {
    var panel: Panel
    
    @State var headerColor = Color.cPrimary
    @State var headerIcon = "ic-home"
    
    var body: some View {
        HStack {
            Text((panel.name ?? "").capitalized)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .padding(.horizontal, 5)
                .foregroundColor(.cTextHigh)
            Image(headerIcon)
                .resizable()
                .scaledToFit()
                .foregroundColor(headerColor)
                .frame(width: 34, height: 34, alignment: .center)
                .padding(4)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            initUI()
        }
    }
    
    func initUI() {
        self.headerColor = PanelUtils.colorByPanelType(panel: panel)
        self.headerIcon = PanelUtils.iconByPanelType(panel: panel)
    }
    
}

class PanelFormLocationModel: ObservableObject {
    @Published var attachCurrentLocation = false
    @Published var address = ""
    @Published var complement = ""
}

struct PanelFormLocationView: View {
    
    @Binding var items: [PanelLocationModel]
    
    @ObservedObject private var locationManager = LocationManager()
    @ObservedObject private var panelFormLocationModel = PanelFormLocationModel()
    
    @State private var markers = [GMSMarker]()
    @State private var goToMyLocation = false
    @State private var fitToBounds = false
    @State private var processingNearLocation = false
    
    @State private var layout: WrapperLayout = .list
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                CustomMarkerMapView(markers: $markers, goToMyLocation: $goToMyLocation, fitToBounds: $fitToBounds) { marker in }
                    .onAppear {
                        refresh()
                    }
                VStack(spacing: 10) {
                    FAB(image: "ic-my-location") {
                        goToMyLocation = true
                    }
                    FAB(image: "ic-bounds") {
                        fitToBounds = true
                    }
                }
                .padding(.top, Globals.UI_FAB_VERTICAL)
                .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
            }
            VStack {
                Text("envAddresses")
                    .foregroundColor(.cTextMedium)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, minHeight: 30)
                    .background(Color.cBackground1dp)
                if layout == .form {
                    VStack(spacing: 10) {
                        if processingNearLocation {
                            LottieView(name: "location_animation", loopMode: .loop)
                                .frame(width: 300, height: 200)
                        } else {
                            if let lastLocation = locationManager.location {
                                if lastLocation.coordinate.latitude != 0 && lastLocation.coordinate.longitude != 0 {
                                    VStack {
                                        Toggle(isOn: $panelFormLocationModel.attachCurrentLocation) {
                                            Text("envAttachCurrentLocation")
                                                .foregroundColor(.cTextHigh)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .onChange(of: panelFormLocationModel.attachCurrentLocation) { v in
                                            if v {
                                                getNearAddress(location: lastLocation)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, Globals.UI_FORM_PADDING_HORIZONTAL)
                                }
                            }
                            VStack {
                                Text("envAddress")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(panelFormLocationModel.address.isEmpty ? Color.cDanger : .cTextMedium)
                                TextField("envAddress", text: $panelFormLocationModel.address)
                                    .cornerRadius(CGFloat(4))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding(.horizontal, Globals.UI_FORM_PADDING_HORIZONTAL)
                            VStack {
                                Text("envComplement")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                TextField("envComplementPlaceholder", text: $panelFormLocationModel.complement)
                                    .cornerRadius(CGFloat(4))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding(.horizontal, Globals.UI_FORM_PADDING_HORIZONTAL)
                            HStack {
                                Button(action: {
                                    clearForm()
                                    layout = .list
                                }) {
                                    Text("envDiscard")
                                        .foregroundColor(.cDanger)
                                        .font(.system(size: 15))
                                        .frame(maxWidth: .infinity, minHeight: 40)
                                }
                                Button(action: {
                                    addItem()
                                }) {
                                    Text("envAddItem")
                                        .foregroundColor(panelFormLocationModel.address.isEmpty ? .cTextDisabled : .cTextMedium)
                                        .font(.system(size: 15))
                                        .frame(maxWidth: .infinity, minHeight: 40)
                                }
                                .disabled(panelFormLocationModel.address.isEmpty)
                            }
                            .padding(.bottom, 5)
                        }
                    }
                } else {
                    VStack {
                        VStack(spacing: 10) {
                            ForEach($items) { $item in
                                HStack {
                                    Button(action: {
                                        items.forEach { plm in
                                            plm.type = ""
                                        }
                                        item.type = "DEFAULT"
                                    }) {
                                        Image("ic-done")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(item.type == "DEFAULT" ? .cDone : .cIconLight)
                                            .frame(width: 24, height: 24, alignment: .center)
                                    }
                                    .frame(width: 44, height: 44, alignment: .center)
                                    VStack {
                                        Text(item.address)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.cTextHigh)
                                        Text(item.complement.isEmpty ? "--" : item.complement)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.cTextMedium)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    Button(action: {
                                        delete(model: item)
                                    }) {
                                        Image("ic-delete")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.cDanger)
                                            .frame(width: 24, height: 24, alignment: .center)
                                    }
                                    .frame(width: 44, height: 44, alignment: .center)
                                }
                            }
                        }
                        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
                        Button(action: {
                            layout = .form
                        }) {
                            Text("envNewAddress")
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                    }
                    .padding(.bottom, 5)
                }
            }
        }
    }
    
    func addItem() {
        let location = PanelLocationModel()
        location.address = panelFormLocationModel.address
        location.complement = panelFormLocationModel.complement
        if panelFormLocationModel.attachCurrentLocation {
            if let lat = locationManager.location?.coordinate.latitude {
                location.latitude = Float(lat)
            }
            if let lng = locationManager.location?.coordinate.longitude {
                location.longitude = Float(lng)
            }
        }
        if items.isEmpty {
            location.type = "DEFAULT"
        }
        items.append(location)
        layout = .list
        clearForm()
        refresh()
    }
    
    func clearForm() {
        panelFormLocationModel.attachCurrentLocation = false
        panelFormLocationModel.address = ""
        panelFormLocationModel.complement = ""
    }
    
    func delete(model: PanelLocationModel) {
        items = items.filter { $0.uuid != model.uuid }
        if !items.isEmpty {
            if !items.contains(where: { plm in
                plm.type == "DEFAULT"
            }) {
                items.first!.type = "DEFAULT"
            }
        }
        refresh()
    }
    
    func refresh() {
        markers.removeAll()
        items.forEach { location in
            if location.latitude != 0 && location.longitude != 0 {
                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude)))
                marker.title = location.address
                markers.append(marker)
            }
        }
        if items.isEmpty {
            goToMyLocation = true
        } else {
            fitToBounds = true
        }
    }
    
    func getNearAddress(location: CLLocation) {
        processingNearLocation = true
        AppServer().postRequest(data: [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ], path: "vm/panel/location/near") { success, code, data in
            if success {
                if let response = data as? [String: Any] {
                    if let address = response["address"] {
                        panelFormLocationModel.address = Utils.castString(value: address)
                    }
                }
            }
            self.processingNearLocation = false
        }
    }
    
}

struct PanelFormVisitingHoursItemView: View {
    
    @ObservedObject var item: PanelVisitingHourModel
    
    @State private var modalHourAM = false
    @State private var modalHourPM = false
    
    var body: some View {
        HStack {
            Text(TimeUtils.day(item.dayOfWeek))
                .foregroundColor(.cTextHigh)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: {
                
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5.0)
                        .foregroundColor(item.amStatus ? .cDone : .cUnselected)
                    Text(String(format: NSLocalizedString("sepTo", comment: "%@ to %@"), Utils.hourFormat(date: item.amHourStart), Utils.hourFormat(date: item.amHourEnd)))
                        .frame(width: 100, height: 50)
                        .padding(.horizontal, 5)
                        .font(.system(size: 14))
                        .foregroundColor(item.amStatus ? .cTextOverColor : .cTextMedium)
                        .cornerRadius(5.0)
                }
            }
            .simultaneousGesture(
                LongPressGesture()
                    .onEnded { _ in
                        modalHourAM = true
                    }
            )
            .highPriorityGesture(
                TapGesture()
                    .onEnded {
                        item.amStatus.toggle()
                    }
            )
            .partialSheet(isPresented: $modalHourAM) {
                DialogTimeRangePicker(hourStart: $item.amHourStart, hourEnd: $item.amHourEnd, minHour: Utils.strToDate(value: "06:00", format: "HH:mm"), maxHour: Utils.strToDate(value: "13:00", format: "HH:mm")) { selected in
                    item.amHourStart = selected.first!
                    item.amHourEnd = selected.last!
                    modalHourAM = false
                    item.amStatus = true
                }
            }
            Button(action: {
                
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5.0)
                        .foregroundColor(item.pmStatus ? .cDone : .cUnselected)
                    Text(String(format: NSLocalizedString("sepTo", comment: "%@ to %@"), Utils.hourFormat(date: item.pmHourStart), Utils.hourFormat(date: item.pmHourEnd)))
                        .frame(width: 100, height: 50)
                        .padding(.horizontal, 5)
                        .font(.system(size: 14))
                        .foregroundColor(item.pmStatus ? .cTextOverColor : .cTextMedium)
                        .cornerRadius(5.0)
                }
            }
            .simultaneousGesture(
                LongPressGesture()
                    .onEnded { _ in
                        modalHourPM = true
                    }
            )
            .highPriorityGesture(
                TapGesture()
                    .onEnded {
                        item.pmStatus.toggle()
                    }
            )
            .partialSheet(isPresented: $modalHourPM) {
                DialogTimeRangePicker(hourStart: $item.pmHourStart, hourEnd: $item.pmHourEnd, minHour: Utils.strToDate(value: "13:00", format: "HH:mm"), maxHour: Utils.strToDate(value: "22:00", format: "HH:mm")) { selected in
                    item.pmHourStart = selected.first!
                    item.pmHourEnd = selected.last!
                    modalHourPM = false
                    item.pmStatus = true
                }
            }
        }
    }
    
}

struct PanelFormVisitingHoursView: View {
    
    @Binding var items: [PanelVisitingHourModel]
    
    var body: some View {
        VStack(spacing: 10) {
            Text("envVistingHoursMessageToggle")
                .foregroundColor(.cTextMedium)
                .font(.system(size: 14))
            Text("envVistingHoursMessageEdit")
                .foregroundColor(.cTextMedium)
                .font(.system(size: 14))
            ScrollView {
                ForEach($items) { $item in
                    PanelFormVisitingHoursItemView(item: item)
                }
                ScrollViewFABBottom()
            }
        }
    }
    
}

struct PanelFormContactControlView: View {
    
    @Binding var items: [PanelContactControlModel]
    
    var body: some View {
        ScrollView {
            ForEach($items) { $item in
                HStack {
                    Toggle(isOn: $item.status) {
                        Text(item.contactControlType.name)
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 6)
            }
        }
        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
    }
    
}

struct PanelRecordListView: View {
    var viewRouter: ViewRouter
    var panel: Panel
    
    @State private var isProcessing = false
    @State private var movements: [MovementReport] = []
    
    @State private var movementSelected: MovementReport = MovementReport()
    @State private var modalMovement = false
    @State private var modalMovementSummary = false
    
    let realm = try! Realm()
    
    var body: some View {
        VStack {
            if isProcessing {
                Spacer()
                LottieView(name: "sync_animation", loopMode: .loop, speed: 1)
                    .frame(width: 300, height: 200)
                Spacer()
            } else {
                ScrollView {
                    ForEach($movements) { $movement in
                        Button {
                            movementSelected = movement
                            if MovementUtils.isCycleActive(realm: realm, id: movement.cycle?.id ?? 0) && movement.reportedBy == JWTUtils.sub() && movement.executed == 1 {
                                modalMovement = true
                            } else {
                                modalMovementSummary = true
                            }
                        } label: {
                            ReportMovementItemView(realm: realm, item: movement, userId: JWTUtils.sub())
                        }
                    }
                    ScrollViewFABBottom()
                }
            }
        }
        .shee(isPresented: $modalMovement, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
            MovementBottomMenu(movement: movementSelected) {
                FormEntity(objectId: nil, type: "", options: [ "oId": movementSelected.objectId.stringValue, "id": String(movementSelected.serverId) ]).go(path: "MOVEMENT-FORM", router: viewRouter)
            } onSummary: {
                modalMovement = false
                modalMovementSummary = true
            }
        }
        .sheet(isPresented: $modalMovementSummary) {
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        movements.removeAll()
        
        isProcessing = true
        AppServer().postRequest(data: [
            "panel_id": panel.id,
            "panel_type": panel.type,
            "user_id": JWTUtils.sub()
        ], path: "vm/movement/mobile") { success, code, data in
            if success {
                if let rs = data as? [String] {
                    for item in rs {
                        let decoded = try! JSONDecoder().decode(MovementReport.self, from: item.data(using: .utf8)!)
                        movements.append(decoded)
                    }
                }
            }
            MovementDao(realm: realm).by(type: panel.type, objectId: panel.objectId).forEach { m in
                if m.transactionStatus != "OPEN" {
                    movements.append(m.report(realm: realm))
                }
            }
            movements.sort { mr1, mr2 in
                if mr1.date == mr2.date {
                    return mr1.hour > mr2.hour
                }
                return mr1.date > mr2.date
            }
            DispatchQueue.main.async {
                isProcessing = false
            }
        }
    }
    
}

struct PanelListHeader: View {
    
    var total: Int
    var filtered: Int
    let onFilterTapped: () -> Void
    let onSortTapped: () -> Void
    
    var body: some View {
        HStack {
            VStack {
                Text(String(format: NSLocalizedString("envTotalPanel", comment: ""), String(total)))
                    .foregroundColor(.cTextMedium)
                    .font(.system(size: 12))
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                if total != filtered {
                    Text(String(format: NSLocalizedString("envShowingNResults", comment: ""), String(filtered)))
                        .foregroundColor(.cTextHigh)
                        .font(.system(size: 12))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
            }
            Spacer()
            HStack {
                Button(action: {
                    onFilterTapped()
                }) {
                    Text("envFilters")
                        .font(.system(size: 15))
                        .foregroundColor(.cTextLink)
                        .padding(.horizontal, 10)
                }
                .frame(height: 44, alignment: .center)
                Button(action: {
                    onSortTapped()
                }) {
                    Image("ic-sort")
                        .resizable()
                        .foregroundColor(.cIcon)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30, alignment: .center)
                        .padding(8)
                }
                .frame(width: 44, height: 44, alignment: .center)
            }
        }
        .frame(height: 44)
    }
    
}

struct BottomNavigationBarDynamic: View {
    let onTabSelected: (_ tab: String) -> Void
    
    @Binding var currentTab: String
    @Binding var tabs: [DynamicFormTab]
    var staticTabs: [String] = []
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { i in
                    Image("ic-dynamic-tab-\(i)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(tabs.count + 1), alignment: .center)
                        .foregroundColor(currentTab == tabs[i].key ? .cPrimary : .cAccent)
                        .onTapGesture {
                            onTabSelected(tabs[i].key)
                        }
                }
                if staticTabs.contains("LOCATIONS") {
                    Image("ic-map")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(tabs.count + 1), alignment: .center)
                        .foregroundColor(currentTab == "LOCATIONS" ? .cPrimary : .cAccent)
                        .onTapGesture {
                            onTabSelected("LOCATIONS")
                        }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 46, maxHeight: 46)
    }
    
}

struct CustomPanelListView<Content: View>: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var realm: Realm
    var panelType: String
    var totalPanel: Int
    var filtered: [Panel]
    var sortOptions: [String]
    var filtersDynamic: [String]
    @Binding var sort: SortModel
    @Binding var filters: [DynamicFilter]
    @Binding var userSelected: Int
    var couldToggleMap = true
    var couldSelectAgent = true
    var couldGoToForm = true
    let onAgentChanged: () -> Void
    var content: () -> Content
    @State var layout: ViewLayout = .list
    @State private var filteredCount = 0
    @State private var modalSort = false
    @State private var selectedUser = [String]()
    @State private var modalUserOpen = false
    
    var body: some View {
        if layout == .filter {
            PanelFilterView(filtersDynamic: filtersDynamic, filters: $filters) {
                layout = .list
            }
        } else {
            ZStack(alignment: .bottom) {
                VStack {
                    if userSelected > 0 {
                        HStack {
                            VStack {
                                Image("ic-user")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22, alignment: .center)
                            }
                            .frame(width: 40, height: 40, alignment: .center)
                            let user = UserDao(realm: realm).by(id: userSelected)
                            Text((user?.name ?? "").capitalized)
                                .foregroundColor(.cTextHigh)
                                .lineLimit(1)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            Button(action: {
                                userSelected = 0
                            }) {
                                Image("ic-close")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20, alignment: .center)
                            }
                            .frame(width: 40, height: 40, alignment: .center)
                        }
                        .frame(height: 40)
                    }
                    PanelListHeader(total: totalPanel, filtered: filtered.count) {
                        layout = .filter
                    } onSortTapped: {
                        modalSort = true
                    }
                    if layout == .list {
                        ScrollView {
                            LazyVStack(content: content)
                        }
                    } else {
                        PanelListMapView(items: filtered)
                    }
                }
                HStack(alignment: .bottom) {
                    VStack {
                        if let user = UserDao(realm: realm).logged() {
                            if !user.hierarchy.isEmpty && couldSelectAgent {
                                FAB(image: "ic-user") {
                                    modalUserOpen = true
                                }
                            }
                        }
                        if couldToggleMap {
                            if layout == .map {
                                FAB(image: "ic-list") {
                                    layout = .list
                                }
                            } else {
                                FAB(image: "ic-map") {
                                    layout = .map
                                }
                            }
                        }
                    }
                    Spacer()
                    if couldGoToForm {
                        FAB(image: "ic-plus") {
                            FormEntity(objectId: nil).go(path: PanelUtils.formByPanelType(type: panelType), router: viewRouter)
                        }
                    }
                }
                .padding(.bottom, Globals.UI_FAB_VERTICAL)
                .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
            }
            .shee(isPresented: $modalSort, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
                VStack {
                    DialogSortPickerView(data: sortOptions) { selected in
                        sort = selected
                        modalSort = false
                    }
                }
            }
            .sheet(isPresented: $modalUserOpen) {
                DialogSourcePickerView(selected: $selectedUser, key: "USER-HIERARCHY", multiple: false, title: NSLocalizedString("envAgent", comment: "Agent")) { selected in
                    modalUserOpen = false
                    if !selected.isEmpty {
                        if userSelected != Utils.castInt(value: selected[0]) {
                            userSelected = Utils.castInt(value: selected[0])
                            onAgentChanged()
                        }
                    }
                }
            }
        }
    }
    
}

struct PanelListMapView: View {
    
    var items: [Panel]
    
    @State private var markers = [GMSMarker]()
    @State private var goToMyLocation = false
    @State private var fitToBounds = false
    
    @State private var panelTapped: Panel = GenericPanel()
    
    @State private var menuIsPresented = false
    @State private var modalInfo = false
    @State private var modalDelete = false
    @State private var modalVisitsFee = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            CustomMarkerMapView(markers: $markers, goToMyLocation: $goToMyLocation, fitToBounds: $fitToBounds) { marker in
                if let p = marker.userData as? Panel {
                    panelTapped = p
                    menuIsPresented = true
                }
            }
                .onAppear {
                    markers.removeAll()
                    items.forEach { panel in
                        if let location = panel.mainLocation() {
                            if let lat = location.latitude, let lng = location.longitude {
                                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lng)))
                                marker.userData = panel
                                markers.append(marker)
                            }
                        }
                    }
                    fitToBounds = true
                }
            VStack(spacing: 10) {
                FAB(image: "ic-my-location") {
                    goToMyLocation = true
                }
                FAB(image: "ic-bounds") {
                    fitToBounds = true
                }
            }
            .padding(.top, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .sheet(isPresented: $menuIsPresented) {
            PanelMenu(isPresented: self.$menuIsPresented, panel: $panelTapped) {
                modalInfo = true
            } onDeleteTapped: {
                modalDelete = true
            } onVisitsFeeTapped: {
                modalVisitsFee = true
            }
        }
        .shee(isPresented: $modalInfo, presentationStyle: .formSheet(properties: .init(detents: [.medium(), .large()]))) {
            PanelKeyInfoView(panel: panelTapped)
        }
        .shee(isPresented: $modalDelete, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
            PanelDeleteView(panel: panelTapped) {
                modalDelete = false
            }
        }
        .shee(isPresented: $modalVisitsFee, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
            PanelVisitsFeeView(panel: panelTapped) {
                modalVisitsFee = false
            }
        }
    }
    
}

struct PanelItemMapView: View {
    
    var item: Panel
    
    @State private var markers = [GMSMarker]()
    @State private var goToMyLocation = false
    @State private var fitToBounds = false
    
    var body: some View {
        CustomMarkerMapView(markers: $markers, goToMyLocation: $goToMyLocation, fitToBounds: $fitToBounds) { marker in }
            .onAppear {
                markers.removeAll()
                item.locations.forEach { location in
                    if let lat = location.latitude, let lng = location.longitude {
                        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lng)))
                        marker.title = location.address
                        markers.append(marker)
                    }
                }
                fitToBounds = true
            }
    }
    
}

struct PanelFilterView: View {
    
    private let filtersStatic = [
        DynamicFilter(key: "contact_type", label: "contact_type", controlType: "", sourceType: "", values: []),
        DynamicFilter(key: "visits", label: "visits", controlType: "", sourceType: "", values: [])
    ]
    var filtersDynamic: [String]
    
    @Binding var filters: [DynamicFilter]
    
    let onApplyTapped: () -> Void
    
    @State private var modalPresented = false
    @State private var filterSelected: DynamicFilter?
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    cleanAll()
                }) {
                    Text("envClean")
                        .foregroundColor(.cDanger)
                }
                Spacer()
                Button(action: {
                    onApplyTapped()
                }) {
                    Text("envApply")
                        .foregroundColor(.cTextHigh)
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 5)
            VStack {
                Text("envVisits")
                    .foregroundColor(.cTextMedium)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 10) {
                    Button(action: {
                        updateFilterValues(key: "visits", value: ["N"])
                    }) {
                        Text("envNotVisited")
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44.0)
                            .foregroundColor(.cTextHigh)
                            .background(matchValue(key: "visits", value: "N") ? Color.cSelected : Color.cUnselected)
                            .cornerRadius(25.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(Color.cSelected, lineWidth: 1)
                                    .foregroundColor(.cPrimary)
                            )
                    }
                    Button(action: {
                        updateFilterValues(key: "visits", value: ["P"])
                    }) {
                        Text("envToVisit")
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44.0)
                            .foregroundColor(.cTextHigh)
                            .background(matchValue(key: "visits", value: "P") ? Color.cSelected : Color.cUnselected)
                            .cornerRadius(25.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(Color.cSelected, lineWidth: 1)
                                    .foregroundColor(.cPrimary)
                            )
                    }
                    Button(action: {
                        updateFilterValues(key: "visits", value: ["V"])
                    }) {
                        Text("envVisited")
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44.0)
                            .foregroundColor(.cTextHigh)
                            .background(matchValue(key: "visits", value: "V") ? Color.cSelected : Color.cUnselected)
                            .cornerRadius(25.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(Color.cSelected, lineWidth: 1)
                                    .foregroundColor(.cPrimary)
                            )
                    }
                }
                .padding(.horizontal, 2)
            }
            .padding(.vertical, 5)
            VStack {
                Text("envContactType")
                    .foregroundColor(.cTextMedium)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 10) {
                    Button(action: {
                        updateFilterValues(key: "contact_type", value: ["P"])
                    }) {
                        Text("envFTF")
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44.0)
                            .foregroundColor(.cTextHigh)
                            .background(matchValue(key: "contact_type", value: "P") ? Color.cSelected : Color.cUnselected)
                            .cornerRadius(25.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(Color.cSelected, lineWidth: 1)
                                    .foregroundColor(.cPrimary)
                            )
                    }
                    Button(action: {
                        updateFilterValues(key: "contact_type", value: ["V"])
                    }) {
                        Text("envVirtual")
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44.0)
                            .foregroundColor(.cTextHigh)
                            .background(matchValue(key: "contact_type", value: "V") ? Color.cSelected : Color.cUnselected)
                            .cornerRadius(25.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(Color.cSelected, lineWidth: 1)
                                    .foregroundColor(.cPrimary)
                            )
                    }
                }
                .padding(.horizontal, 2)
            }
            .padding(.vertical, 5)
            ScrollView {
                VStack {
                    ForEach(filters.indices, id: \.self) { i in
                        let f = filters[i]
                        if !filterStaticAdded(key: f.key) {
                            Button(action: {
                                filters[i].modalOpen = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(TextUtils.serializeEnv(s: f.key))
                                            .foregroundColor(.cTextMedium)
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        VStack {
                                            if hasValues(key: f.key) {
                                                if f.controlType == "date-range" {
                                                    Text(TextUtils.dateRange(values: f.values))
                                                        .foregroundColor(.cTextHigh)
                                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                                } else {
                                                    ChipsContainerView(chips: $filters[i].chips)
                                                }
                                            } else {
                                                Text("envSelect")
                                                    .foregroundColor(.cTextHigh)
                                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    if hasValues(key: f.key) {
                                        VStack {
                                            Button(action: {
                                                updateFilterValues(key: f.key, value: [])
                                            }) {
                                                Image("ic-delete")
                                                    .resizable()
                                                    .foregroundColor(.cDanger)
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 22, height: 22, alignment: .center)
                                                    .padding(8)
                                            }
                                            .frame(width: 44, height: 44, alignment: .center)
                                            Spacer()
                                        }
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                            .sheet(isPresented: $filters[i].modalOpen) {
                                if f.controlType == "date-range" {
                                    DialogDateRangePicker(selected: $filters[i].values) { _ in
                                        filters[i].modalOpen = false
                                    }
                                } else {
                                    DialogSourcePickerView(selected: $filters[i].values, key: f.key, multiple: true, title: TextUtils.serializeEnv(s: f.key)) { selected in
                                        filters[i].modalOpen = false
                                        filters[i].chips.removeAll()
                                        selected.forEach { s in
                                            let label = DynamicUtils.tableValue(key: f.key, selected: [s])
                                            if !label.isEmpty {
                                                filters[i].chips.append(ChipItem(label: label, image: "", onApplyTapped: {
                                                    
                                                }))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .onAppear {
            generateFilters()
        }
    }
    
    func generateFilters() {
        filtersStatic.forEach { df in
            if !filterAdded(key: df.key) {
                filters.append(df)
            }
        }
        filtersDynamic.forEach { f in
            if !filterAdded(key: f) {
                var controlType = "list"
                if ["join_date", "last_update", "recently_added"].contains(f) {
                    controlType = "date-range"
                }
                filters.append(
                    DynamicFilter(key: f, label: f, controlType: controlType, sourceType: "table", values: [])
                )
            }
        }
    }
    
    func filterAdded(key: String) -> Bool {
        return filters.first { df in
            df.key == key
        } != nil
    }
    
    func filterStaticAdded(key: String) -> Bool {
        return filtersStatic.first { df in
            df.key == key
        } != nil
    }
    
    func hasValues(key: String) -> Bool {
        if let filter = filters.first(where: { df in df.key == key }) {
            return !filter.values.isEmpty
        }
        return false
    }
    
    func matchValue(key: String, value: String) -> Bool {
        if let filter = filters.first(where: { df in df.key == key }) {
            return filter.values.contains(value)
        }
        return false
    }
    
    func updateFilterValues(key: String, value: [String]) {
        if let ix = filters.firstIndex(where: { df in df.key == key }) {
            filters[ix].values = value
        }
    }
    
    func cleanAll() {
        filters.indices.forEach { ix in
            filters[ix].values = []
        }
    }
    
}

struct PanelItemGenericSwitchView: View {
    var realm: Realm
    @Binding var members: [PanelItemModel]
    let onDelete: (_ ixs: IndexSet) -> Void
    
    @State private var panelTapped: Panel = GenericPanel()
    @State private var complementaryData: [String: Any] = [:]
    
    @State private var menuIsPresented = false
    @State private var modalInfo = false
    @State private var modalDelete = false
    @State private var modalVisitsFee = false
    
    var body: some View {
        List {
            ForEach($members) { $detail in
                switch detail.type {
                    case "F":
                        if let pharmacy = PharmacyDao(realm: realm).by(objectId: detail.objectId) {
                            HStack(alignment: .top) {
                                Image("ic-pharmacy")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 32)
                                    .foregroundColor(Color.cPanelPharmacy)
                                PanelItemPharmacy(realm: realm, userId: JWTUtils.sub(), pharmacy: pharmacy) {
                                    self.panelTapped = pharmacy
                                    menuIsPresented = true
                                }
                            }
                            .padding(.vertical, 5)
                            .listRowBackground(Color.clear)
                        }
                    case "C":
                        if let client = ClientDao(realm: realm).by(objectId: detail.objectId) {
                            HStack(alignment: .top) {
                                Image("ic-client")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 32)
                                    .foregroundColor(Color.cPanelClient)
                                PanelItemClient(realm: realm, userId: JWTUtils.sub(), client: client) {
                                    self.panelTapped = client
                                    menuIsPresented = true
                                }
                            }
                            .padding(.vertical, 5)
                            .listRowBackground(Color.clear)
                        }
                    case "P":
                        if let patient = PatientDao(realm: realm).by(objectId: detail.objectId) {
                            HStack(alignment: .top) {
                                Image("ic-patient")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 32)
                                    .foregroundColor(Color.cPanelPatient)
                                PanelItemPatient(realm: realm, userId: JWTUtils.sub(), patient: patient) {
                                    self.panelTapped = patient
                                    menuIsPresented = true
                                }
                            }
                            .padding(.vertical, 5)
                            .listRowBackground(Color.clear)
                        }
                    case "T":
                        if let potential = PotentialDao(realm: realm).by(objectId: detail.objectId) {
                            HStack(alignment: .top) {
                                Image("ic-potential")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 32)
                                    .foregroundColor(Color.cPanelPotential)
                                PanelItemPotential(realm: realm, userId: JWTUtils.sub(), potential: potential) {
                                    self.panelTapped = potential
                                    menuIsPresented = true
                                }
                            }
                            .padding(.vertical, 5)
                            .listRowBackground(Color.clear)
                        }
                    default:
                        if let doctor = DoctorDao(realm: realm).by(objectId: detail.objectId) {
                            HStack(alignment: .top) {
                                Image("ic-doctor")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 32)
                                    .foregroundColor(Color.cPanelMedic)
                                PanelItemDoctor(realm: realm, userId: JWTUtils.sub(), doctor: doctor) {
                                    complementaryData["hd"] = doctor.habeasData
                                    complementaryData["tv"] = doctor.tvConsent
                                    self.panelTapped = doctor
                                    menuIsPresented = true
                                }
                            }
                            .padding(.vertical, 5)
                            .listRowBackground(Color.clear)
                        }
                }
            }
            .onDelete { ixs in
                onDelete(ixs)
            }
            ScrollViewFABBottom()
                .deleteDisabled(true)
            ScrollViewFABBottom()
                .deleteDisabled(true)
        }
        .padding(0)
        .listStyle(.plain)
        .background(Color.clear)
        .sheet(isPresented: $menuIsPresented) {
            PanelMenu(isPresented: self.$menuIsPresented, panel: $panelTapped, complementaryData: complementaryData) {
                modalInfo = true
            } onDeleteTapped: {
                modalDelete = true
            } onVisitsFeeTapped: {
                modalVisitsFee = true
            }
        }
        .shee(isPresented: $modalInfo, presentationStyle: .formSheet(properties: .init(detents: [.medium(), .large()]))) {
            PanelKeyInfoView(panel: panelTapped)
        }
        .shee(isPresented: $modalDelete, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
            PanelDeleteView(panel: panelTapped) {
                modalDelete = false
            }
        }
        .shee(isPresented: $modalVisitsFee, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
            PanelVisitsFeeView(panel: panelTapped) {
                modalVisitsFee = false
            }
        }
    }
    
}

struct PanelSelectWrapperView: View {
    var realm: Realm
    var types: [String]
    @Binding var members: [PanelItemModel]
    
    @Binding var modalPanelType: Bool
    
    @State private var slDoctors = [ObjectId]()
    @State private var slPharmacies = [ObjectId]()
    @State private var slClients = [ObjectId]()
    @State private var slPatients = [ObjectId]()
    @State private var slPotentials = [ObjectId]()
    
    @State private var modalPanelDoctor = false
    @State private var modalPanelPharmacy = false
    @State private var modalPanelClient = false
    @State private var modalPanelPatient = false
    @State private var modalPanelPotential = false
    
    var body: some View {
        PanelItemGenericSwitchView(realm: realm, members: $members) { ixs in
            members.remove(atOffsets: ixs)
        }
        .sheet(isPresented: $modalPanelDoctor) {
            DoctorSelectView(selected: $slDoctors, onSelectionDone: refreshItems)
        }
        .sheet(isPresented: $modalPanelPharmacy) {
            PharmacySelectView(selected: $slPharmacies, onSelectionDone: refreshItems)
        }
        .sheet(isPresented: $modalPanelClient) {
            ClientSelectView(selected: $slClients, onSelectionDone: refreshItems)
        }
        .sheet(isPresented: $modalPanelPatient) {
            PatientSelectView(selected: $slPatients, onSelectionDone: refreshItems)
        }
        .sheet(isPresented: $modalPanelPotential) {
            PotentialSelectView(selected: $slPotentials, onSelectionDone: refreshItems)
        }
        .partialSheet(isPresented: $modalPanelType) {
            PanelTypeSelectView(types: types) { type in
                slDoctors = members.filter { $0.type == "M" }.map { $0.objectId }
                slPharmacies = members.filter { $0.type == "F" }.map { $0.objectId }
                slClients = members.filter { $0.type == "C" }.map { $0.objectId }
                slPatients = members.filter { $0.type == "P" }.map { $0.objectId }
                slPotentials = members.filter { $0.type == "T" }.map { $0.objectId }
                switch type {
                    case "F":
                        modalPanelPharmacy = true
                    case "C":
                        modalPanelClient = true
                    case "P":
                        modalPanelPatient = true
                    case "T":
                        modalPanelPotential = true
                    default:
                        modalPanelDoctor = true
                }
                modalPanelType = false
            }
        }
    }
    
    func refreshItems() {
        members.removeAll()
        slDoctors.forEach { el in
            members.append(PanelItemModel(objectId: el, type: "M"))
        }
        slPharmacies.forEach { el in
            members.append(PanelItemModel(objectId: el, type: "F"))
        }
        slClients.forEach { el in
            members.append(PanelItemModel(objectId: el, type: "C"))
        }
        slPatients.forEach { el in
            members.append(PanelItemModel(objectId: el, type: "P"))
        }
        slPotentials.forEach { el in
            members.append(PanelItemModel(objectId: el, type: "T"))
        }
        modalPanelDoctor = false
        modalPanelPharmacy = false
        modalPanelClient = false
        modalPanelPatient = false
        modalPanelPotential = false
    }
    
}

struct PanelFormDuplicationAdviceView: View {
    
    var body: some View {
        HStack {
            Text("envDuplicationWarning")
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .padding(.horizontal, 5)
                .foregroundColor(.cTextHigh)
            Image("ic-warning")
                .resizable()
                .scaledToFit()
                .foregroundColor(.cWarning)
                .frame(width: 34, height: 34, alignment: .center)
                .padding(4)
        }
        .frame(maxWidth: .infinity)
    }
    
}

struct CustomPanelFormWrapperView: View {
    @StateObject var tabRouter = TabRouter()
    
    var tabs: [String]
    @Binding var form: DynamicForm
    @Binding var options: DynamicFormFieldOptions
    @Binding var contactControl: [PanelContactControlModel]
    @Binding var locations: [PanelLocationModel]
    @Binding var visitingHours: [PanelVisitingHourModel]
    
    @Binding var savedToast: Bool
    
    let onFABSaveTapped: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $tabRouter.current) {
                ForEach($form.tabs) { $tab in
                    CustomForm {
                        DynamicFormView(form: $form, tab: $tab, options: options)
                        ScrollViewFABBottom()
                    }
                    .tag(tab.key)
                    .tabItem {
                        Text(NSLocalizedString("envTab\(tab.key.capitalized)", comment: ""))
                        Image("ic-dynamic-tab-\(tab.key.lowercased())")
                    }
                }
                if tabs.contains("visiting-hours") {
                    PanelFormVisitingHoursView(items: $visitingHours)
                        .tag("visiting-hours")
                        .tabItem {
                            Text("envTabVisitingHours")
                            Image("ic-calendar")
                        }
                }
                if tabs.contains("locations") {
                    PanelFormLocationView(items: $locations)
                        .tag("locations")
                        .tabItem {
                            Text("envTabLocations")
                            Image("ic-map")
                        }
                }
                if tabs.contains("contact-control") {
                    PanelFormContactControlView(items: $contactControl)
                        .tag("contact-control")
                        .tabItem {
                            Text("envTabContactControl")
                            Image("ic-contact-control")
                        }
                }
            }
            .tabViewStyle(DefaultTabViewStyle())
            HStack(alignment: .bottom) {
                Spacer()
                if !["locations"].contains(tabRouter.current) {
                    if !savedToast {
                        FAB(image: "ic-cloud") {
                            self.onFABSaveTapped()
                        }
                    }
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL + 50)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .onAppear {
            tabRouter.current = "BASIC"
        }
    }
    
}

struct CustomPanelListDuplicatesView<Content: View>: View {
    @Binding var form: DynamicForm
    var content: () -> Content
    let onSaveAnywayTapped: () -> Void
    
    var body: some View {
        VStack {
            VStack {
                Text("envDuplicatesMesssage")
                    .foregroundColor(.cTextHigh)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
            .padding(.vertical, 10)
            ScrollView {
                LazyVStack(content: content)
            }
            .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
            if DynamicUtils.validate(form: form) {
                Button(action: {
                    onSaveAnywayTapped()
                }) {
                    Text("envSaveAnyway")
                        .foregroundColor(.cTextLink)
                        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                }
            }
        }
    }
    
}

struct PanelKeyInfoView: View {
    var panel: Panel
    
    var body: some View {
        VStack {
            PanelFormHeaderView(panel: panel)
            VStack {
                PanelItemMapView(item: panel)
                    .frame(height: 160)
                ScrollView {
                    VStack {
                        PanelKeyInfoVisitView(panel: panel)
                        Divider()
                        PanelKeyInfoSummaryView(panel: panel)
                    }
                    .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
                }
            }
        }
    }
    
}

struct PanelKeyInfoVisitView: View {
    var panel: Panel
    
    var body: some View {
        VStack {
            VStack {
                Text(NSLocalizedString("envComment", comment: ""))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.cTextMedium)
                    .font(.system(size: 14))
                Text(panel.lastMovement?.comment ?? "--")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.cTextHigh)
                    .font(.system(size: 16))
            }
            VStack {
                Text(NSLocalizedString("envTargetNextVisit", comment: ""))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.cTextMedium)
                    .font(.system(size: 14))
                Text(panel.lastMovement?.targetNext ?? "--")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.cTextHigh)
                    .font(.system(size: 16))
            }
        }
    }
}

struct PanelKeyInfoSummaryView: View {
    var panel: Panel
    
    let realm = try! Realm()
    
    @State private var form: DynamicForm = DynamicForm(tabs: [])
    @State private var options: DynamicFormFieldOptions = DynamicFormFieldOptions(table: "", op: .view, panelType: "")
    var body: some View {
        VStack {
            ForEach($form.tabs) { $tab in
                DynamicFormSummaryView(form: $form, tab: $tab, options: options)
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        options.objectId = panel.objectId
        options.item = panel.id
        options.op = .view
        options.panelType = panel.type
        
        let infoFields = Config.get(key: PanelUtils.infoFieldsKeyByPanelType(panelType: panel.type)).complement ?? ""
        if !infoFields.isEmpty {
            form.tabs.append(DynamicFormTab(key: "", title: "", groups: [DynamicFormGroup(title: "envKeyInformation".localized(), fields: [])]))
            var tmpForm: DynamicForm = DynamicForm(tabs: [])
            PanelUtils.dynamicFormByPanel(realm: realm, panel: panel, form: &tmpForm, options: &options)
            
            infoFields.components(separatedBy: ",").forEach { key in
                if let field = tmpForm.find(key: key) {
                    form.tabs[0].groups[0].fields.append(field)
                }
            }
        }
    }
}

struct PanelVisitsFeeView: View {
    var panel: Panel
    let onActionDone: () -> Void
    
    @State private var fee = 0
    
    let realm = try! Realm()
    
    var body: some View {
        VStack {
            PanelFormHeaderView(panel: panel)
            CustomCard {
                Spacer()
                Text("envVisitsNumber")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor((fee < 0) ? Color.cDanger : .cTextMedium)
                TextField("envVisitsNumber", value: $fee, formatter: NumberFormatter())
                    .cornerRadius(CGFloat(4))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                Button {
                    save()
                } label: {
                    Text("envSave")
                        .foregroundColor(.cDanger)
                        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                }
                .disabled(fee < 1)
                .opacity(fee < 1 ? 0.4 : 1)
            }
        }
        .padding()
        .onAppear {
            load()
        }
    }
    
    func load() {
        fee = panel.mainUser()?.visitsFee ?? 1
    }
    
    func save() {
        switch panel.type {
            case "M":
                let doctorDao = DoctorDao(realm: realm)
                if let doctor = doctorDao.by(objectId: panel.objectId) {
                    try! realm.write {
                        doctor.mainUser()?.visitsFee = fee
                    }
                }
            default:
                break
        }
        onActionDone()
    }
    
}

struct PanelDeleteView: View {
    var panel: Panel
    let onActionDone: () -> Void
    
    @State private var controlType = Config.get(key: "PANEL_DELETE_CONTROL_TYPE").value
    @State private var reason = ""
    
    @State private var selected = [String]()
    @State private var modalReasonOpen = false
    
    var realm = try! Realm()
    
    var body: some View {
        VStack {
            PanelFormHeaderView(panel: panel)
            CustomCard {
                Spacer()
                Text("envPanelInactivationMessage")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.cTextHigh)
                    .font(.system(size: 14))
                Spacer()
                if controlType == 0 {
                    Button(action: {
                        modalReasonOpen = true
                    }, label: {
                        HStack {
                            VStack{
                                Text(NSLocalizedString("envReason", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor((reason.isEmpty) ? .cDanger : .cTextMedium)
                                    .font(.system(size: 14))
                                Text(reason.isEmpty ? "envChoose" : reason)
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
                    })
                    .sheet(isPresented: $modalReasonOpen) {
                        DialogSourcePickerView(selected: $selected, key: "PANEL-DELETE-REASON", multiple: false, title: "envReason".localized(), extraData: ["panelType": panel.type]) { selected in
                            modalReasonOpen = false
                            if !selected.isEmpty {
                                let panelDeleteReason = PanelDeleteReasonDao(realm: realm).by(id: Utils.castInt(value: selected[0]))
                                reason = panelDeleteReason?.content ?? ""
                            }
                        }
                    }
                } else {
                    VStack {
                        Text("envReason")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor((reason.isEmpty) ? .cDanger : .cTextMedium)
                            .font(.system(size: 14))
                        VStack{
                            TextEditor(text: $reason)
                                .frame(height: 80)
                        }
                    }
                }
                Spacer()
                Button {
                    save()
                } label: {
                    Text("envRequestInactivation")
                        .foregroundColor(.cDanger)
                        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                }
                .disabled(reason.isEmpty)
                .opacity(reason.isEmpty ? 0.4 : 1)
            }
        }
        .padding()
    }
    
    func save() {
        DeleteDao(realm: realm).panel(panel: panel, reason: reason)
        onActionDone()
    }
    
}
