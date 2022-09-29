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
                    FAB(image: self.masterRouter.tabCenter != "home" ? "ic-home" : (self.masterRouter.diaryLayout == .map ? "ic-home" : "ic-map")) {
                        if self.masterRouter.tabCenter != "home" {
                            self.masterRouter.diaryLayout = .main
                        } else {
                            switch self.masterRouter.diaryLayout {
                                case .main:
                                    self.masterRouter.diaryLayout = .map
                                default:
                                    self.masterRouter.diaryLayout = .main
                            }
                        }
                        self.masterRouter.tabCenter = "home"
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

struct DashboardMasterCenterView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var masterRouter: MasterRouter
    
    @State private var diaries: [Diary] = []
    @State private var itemWrappers: [DiaryItemWrapper] = []
    @State private var interval: Int = 30
    
    @State private var isProcessing = false
    @State private var movements: [MovementReport] = []
    
    private var realm = try! Realm()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if masterRouter.diaryLayout == .map {
                DiaryListMapView(items: $diaries) { diary in
                    
                }
            } else {
                ScrollView {
                    ForEach($itemWrappers) { $iw in
                        DiaryViewerWrapperItemView(realm: realm, iw: $iw, dateDiaries: $diaries, interval: $interval) { diary in
                            
                        }
                    }
                    if isProcessing {
                        LottieView(name: "sync_animation", loopMode: .loop, speed: 1)
                            .frame(width: 300, height: 200)
                    } else {
                        ForEach($movements) { $movement in
                            ReportMovementItemView(realm: realm, item: movement, userId: JWTUtils.sub())
                        }
                    }
                }
            }
            HStack(alignment: .bottom) {
                Spacer()
                VStack {
                    FAB(image: "ic-calendar") {
                        FormEntity(objectId: nil).go(path: "DIARY-VIEW", router: viewRouter)
                    }
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .onAppear {
            initForm()
        }
        .onChange(of: masterRouter.date) { newValue in
            refresh()
        }
    }
    
    func initForm() {
        itemWrappers.removeAll()
        let preferences = UserPreferenceDao(realm: realm).by(module: "DIARY")
        let hourStart = preferences.first { up in
            up.type == "HOUR_START"
        }?.value ?? "08:00"
        let hourEnd = preferences.first { up in
            up.type == "HOUR_END"
        }?.value ?? "22:00"
        interval = Utils.castInt(value: preferences.first { up in
            up.type == "INTERVAL"
        }?.value ?? "30")
        
        var currentTime = Utils.strToDate(value: hourStart, format: "HH:mm")
        let limitTime = Utils.strToDate(value: hourEnd, format: "HH:mm")
        
        while currentTime < limitTime {
            itemWrappers.append(DiaryItemWrapper(time: currentTime))
            currentTime = currentTime.addingTimeInterval(TimeInterval(Double(interval) * 60.0))
        }
        
        refresh()
    }
    
    func refresh() {
        diaries.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            diaries.append(contentsOf: DiaryDao(realm: realm).by(date: masterRouter.date).map { Diary(value: $0) })
        }
        
        isProcessing = true
        AppServer().postRequest(data: [
            "dateFrom": Utils.dateFormat(date: masterRouter.date),
            "dateTo": Utils.dateFormat(date: masterRouter.date),
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
            DispatchQueue.main.async {
                isProcessing = false
            }
        }
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
            case "home":
                DashboardMasterCenterView()
            default:
                ScrollView {
                    
                }
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
                    tabs.append(MasterDashboardTab(key: "home", icon: "", label: "", route: "home"))
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
