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

struct PanelInfoDialog: View {
    
    @State var panel: Panel
    
    @State var headerColor = Color.cPrimary
    @State var headerIcon = "ic-home"
    
    var body: some View {
        VStack {
            HStack {
                Text(panel.name ?? "")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .padding(.horizontal, 5)
                    .foregroundColor(.white)
                Image(headerIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34, alignment: .center)
                    .padding(4)
            }
            .background(headerColor)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            initUI()
        }
    }
    
    func initUI() {
        self.headerColor = PanelUtils.colorByPanelType(panel: panel)
        self.headerIcon = PanelUtils.iconByPanelType(panel: panel)
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
                            FormEntity(objectId: "").go(path: PanelUtils.formByPanelType(type: panelType), router: viewRouter)
                        }
                    }
                }
                .padding(.bottom, Globals.UI_FAB_VERTICAL)
                .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
            }
            .partialSheet(isPresented: $modalSort) {
                DialogSortPickerView(data: sortOptions) { selected in
                    sort = selected
                    modalSort = false
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
    
    @State private var menuIsPresented = false
    @State private var panelTapped: Panel = GenericPanel()
    
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
            PanelMenu(isPresented: self.$menuIsPresented, panel: $panelTapped)
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
                        Text("envFTFVisit")
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
                        Text("envVirtualVisit")
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
                                            let label = DynamicUtils.tableValue(key: f.key, selected: [s]) ?? ""
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
    
    @State private var menuIsPresented = false
    @State private var panelTapped: Panel = GenericPanel()
    @State private var complementaryData: [String: Any] = [:]
    
    var body: some View {
        List {
            ForEach($members) { $detail in
                switch detail.type {
                    case "F":
                        if let pharmacy = PharmacyDao(realm: realm).by(objectId: detail.objectId) {
                            PanelItemPharmacy(realm: realm, userId: JWTUtils.sub(), pharmacy: pharmacy) {
                                self.panelTapped = pharmacy
                                menuIsPresented = true
                            }
                            .listRowBackground(Color.clear)
                        }
                    case "C":
                        if let client = ClientDao(realm: realm).by(objectId: detail.objectId) {
                            PanelItemClient(realm: realm, userId: JWTUtils.sub(), client: client) {
                                self.panelTapped = client
                                menuIsPresented = true
                            }
                            .listRowBackground(Color.clear)
                        }
                    case "P":
                        if let patient = PatientDao(realm: realm).by(objectId: detail.objectId) {
                            PanelItemPatient(realm: realm, userId: JWTUtils.sub(), patient: patient) {
                                self.panelTapped = patient
                                menuIsPresented = true
                            }
                            .listRowBackground(Color.clear)
                        }
                    case "T":
                        if let potential = PotentialDao(realm: realm).by(objectId: detail.objectId) {
                            PanelItemPotential(realm: realm, userId: JWTUtils.sub(), potential: potential) {
                                self.panelTapped = potential
                                menuIsPresented = true
                            }
                            .listRowBackground(Color.clear)
                        }
                    default:
                        if let doctor = DoctorDao(realm: realm).by(objectId: detail.objectId) {
                            PanelItemDoctor(realm: realm, userId: JWTUtils.sub(), doctor: doctor) {
                                complementaryData["hd"] = doctor.habeasData
                                complementaryData["tv"] = doctor.tvConsent
                                self.panelTapped = doctor
                                menuIsPresented = true
                            }
                            .listRowBackground(Color.clear)
                        }
                }
            }
            .onDelete { ixs in
                onDelete(ixs)
            }
        }
        .padding(0)
        .listStyle(.plain)
        .background(Color.clear)
        .sheet(isPresented: $menuIsPresented) {
            PanelMenu(isPresented: self.$menuIsPresented, panel: $panelTapped, complementaryData: complementaryData)
        }
    }
    
}
