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
    var content: () -> Content
    @State var layout: PanelLayout = .list
    @State private var filteredCount = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                PanelListHeader(total: totalPanel, filtered: filtered.count) {
                    
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
