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
        self.headerIcon = PanelUtils.imageByPanelType(panel: panel)
    }
    
}

struct CustomPanelListView<Content: View>: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var realm: Realm
    var totalPanel: Int
    var filtered: [Panel]
    var filtersDynamic: [String]
    @Binding var sort: SortModel
    @Binding var filters: [DynamicFilter]
    var content: () -> Content
    @State var layout: PanelLayout = .list
    @State private var filteredCount = 0
    
    var body: some View {
        if layout == .filter {
            PanelFilterView(filtersDynamic: filtersDynamic, filters: $filters) {
                layout = .list
            }
        } else {
            ZStack(alignment: .bottom) {
                VStack {
                    PanelListHeader(total: totalPanel, filtered: filtered.count) {
                        layout = .filter
                    } onSortTapped: {
                        
                    }
                    if layout == .list {
                        ScrollView {
                            LazyVStack(content: content)
                        }
                    } else {
                        PanelListMapView(items: filtered)
                    }
                }
                HStack {
                    if layout == .map {
                        FAB(image: "ic-list") {
                            layout = .list
                        }
                    } else {
                        FAB(image: "ic-map") {
                            layout = .map
                        }
                    }
                    Spacer()
                    FAB(image: "ic-plus") {
                        FormEntity(objectId: "").go(path: PanelUtils.formByPanelType(type: "M"), router: viewRouter)
                    }
                }
                .padding(.bottom, Globals.UI_FAB_VERTICAL)
                .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
            }
        }
    }
    
}

struct PanelListMapView: View {
    
    var items: [Panel]
    
    @State private var markers = [GMSMarker]()
    
    var body: some View {
        CustomMarkerMapView(markers: $markers)
            .onAppear {
                markers.removeAll()
                items.forEach { panel in
                    if let location = panel.mainLocation() {
                        if let lat = location.latitude, let lng = location.longitude {
                            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lng)))
                            markers.append(marker)
                        }
                    }
                }
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
                                if f.controlType == "date-range" {
                                    
                                } else {
                                    filters[i].modalOpen = true
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("env\(f.key.components(separatedBy: "_").map { $0.capitalized }.joined(separator: ""))")
                                            .foregroundColor(.cTextMedium)
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        VStack {
                                            if hasValues(key: f.key) {
                                                if f.controlType == "date-range" {
                                                    
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
                                DialogSourcePickerView(selected: $filters[i].values, key: f.key, multiple: true, title: NSLocalizedString("env\(f.key.components(separatedBy: "_").map { $0.capitalized }.joined(separator: ""))", comment: "")) { selected in
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
