//
//  DashboardPanelView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct DashboardView: View {
    @EnvironmentObject var masterRouter: MasterRouter
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if userSettings.initStatus {
                DashboardTabWrapperView(tab: "center", route: $masterRouter.tabCenter)
                VStack {
                    FAB(image: self.masterRouter.tabCenter == "LIST" ? "ic-map" : (self.masterRouter.tabCenter == "MAP" ? "ic-diary" : "ic-home"), size: 60, margin: 32) {
                        switch self.masterRouter.tabCenter {
                            case "LIST":
                                self.masterRouter.tabCenter = "MAP"
                            default:
                                self.masterRouter.tabCenter = "LIST"
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
    
}

struct DashboardExtraView: View {
    @EnvironmentObject var masterRouter: MasterRouter
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        DashboardTabWrapperView(tab: "right", route: $masterRouter.tabRight)
    }
    
}

struct DashboardTabContentWrapperView: View {
    var key: String
    
    var body: some View {
        switch key {
            case "client":
                ClientListView()
            case "doctor":
                DoctorListView()
            case "patient":
                PatientListView()
            case "pharmacy":
                PharmacyListView()
            case "potential":
                PotentialListView()
            case "dashboard":
                DashboardTabView()
            case "birthdays":
                BirthdayTabView()
            default:
                DiaryListTabView()
        }
    }
    
}

struct DashboardTabWrapperView: View {
    var tab: String
    @Binding var route: String
    
    @State var tabs = [MasterDashboardTab]()
    
    var body: some View {
        TabView(selection: $route) {
            ForEach(tabs, id: \.key) { tab in
                DashboardTabContentWrapperView(key: tab.key)
                    .tag(tab.key)
                    .tabItem {
                        Text(tab.label.localized())
                        Image(tab.icon)
                    }
            }
        }
        .tabViewStyle(DefaultTabViewStyle())
        .onAppear {
            loadTabs()
        }
    }
    
    private func loadTabs() {
        let gTabs = generateTabs()
        if gTabs.count > 4 && gTabs.count < 10 {
            if tab == "center" {
                tabs = Array(gTabs[..<5])
            } else {
                tabs = Array(gTabs[5...])
            }
        }
    }
    
    private func generateTabs() -> [MasterDashboardTab] {
        var tabs = [MasterDashboardTab]()
        let json = Config.get(key: "DASHBOARD_MENU").complement ?? "[]"
        let dict = Utils.jsonDictionary(string: json)
        let type = UserDao(realm: try! Realm()).logged()?.type ?? 0
        if let array = dict["\(type)"] as? Array<Any> {
            for (index, element) in array.enumerated() {
                if index == 2 {
                    tabs.append(MasterDashboardTab(key: "home", icon: "ic-home", label: "", route: "home"))
                }
                if let d = element as? Dictionary<String, String> {
                    var icon = "ic-home"
                    switch Utils.castString(value: d["key"]) {
                        case "client":
                            icon = "ic-client"
                        case "doctor":
                            icon = "ic-doctor"
                        case "patient":
                            icon = "ic-patient"
                        case "pharmacy":
                            icon = "ic-pharmacy"
                        case "potential":
                            icon = "ic-potential"
                        default:
                            icon = "ic-home"
                    }
                    tabs.append(MasterDashboardTab(key: Utils.castString(value: d["key"]), icon: icon, label: "envTab\(Utils.castString(value: d["label"]).capitalized)", route: Utils.castString(value: d["route"])))
                }
            }
        }
        return tabs
    }
    
}

struct DashboardWrapperView: View {
    @Binding var route: String
    
    var body: some View {
        switch route {
            case "MEDIC":
                DoctorListView()
            /*case "CLIENT":
                ClientListView(searchText: self.$searchText)
            case "PHARMACY":
                PharmacyListView(searchText: self.$searchText)
            case "ACTIVITY":
                ActivityListView(searchText: self.$searchText)*/
            case "DIARY-MAP":
                GoogleMapsView()
                    .edgesIgnoringSafeArea(.all)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            default:
                DiaryListTabView()
        }
    }
    
}
