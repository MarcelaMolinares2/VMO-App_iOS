//
//  DashboardPanelView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import SheeKit

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
    
    @State private var diarySelected: Diary = Diary()
    @State private var modalDiary = false
    
    @State private var movementSelected: MovementReport = MovementReport()
    @State private var modalMovement = false
    @State private var modalMovementSummary = false
    
    private var realm = try! Realm()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if masterRouter.diaryLayout == .map {
                DiaryListMapView(items: $diaries) { diary in
                    if diary.type == "P" {
                        diarySelected = diary
                        modalDiary = true
                    }
                }
            } else {
                ScrollView {
                    ForEach($itemWrappers) { $iw in
                        DiaryViewerWrapperItemView(realm: realm, iw: $iw, dateDiaries: $diaries, interval: $interval) { diary in
                            if diary.type == "P" {
                                diarySelected = diary
                                modalDiary = true
                            }
                        }
                    }
                    Divider()
                        .padding(.vertical, 10)
                    if isProcessing {
                        LottieView(name: "sync_animation", loopMode: .loop, speed: 1)
                            .frame(width: 300, height: 200)
                    } else {
                        ForEach($movements) { $movement in
                            Button {
                                if MovementUtils.isCycleActive(realm: realm, id: movement.cycle?.id ?? 0) && movement.reportedBy == JWTUtils.sub() && movement.executed == 1 {
                                    modalMovement = true
                                } else {
                                    modalMovementSummary = true
                                }
                            } label: {
                                ReportMovementItemView(realm: realm, item: movement, userId: JWTUtils.sub())
                            }
                        }
                    }
                    ScrollViewFABBottom()
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
        .shee(isPresented: $modalDiary, presentationStyle: .formSheet(properties: .init(detents: [.medium(), .large()]))) {
            DiaryReportView(viewRouter: viewRouter, realm: realm, diary: diarySelected)
        }
        .shee(isPresented: $modalMovement, presentationStyle: .formSheet(properties: .init(detents: [.medium(), .large()]))) {
            MovementBottomMenu(movement: movementSelected) {
                FormEntity(objectId: nil, type: "", options: [ "oId": movementSelected.objectId, "id": movementSelected.id ]).go(path: "MOVEMENT-FORM", router: viewRouter)
            } onSummary: {
                modalMovementSummary = true
            }
        }
        .sheet(isPresented: $modalMovementSummary) {
            
        }
        .onAppear {
            initForm()
        }
        .onChange(of: masterRouter.date) { newValue in
            refresh()
        }
        .onChange(of: masterRouter.diaryLayout) { newValue in
            if newValue == .main {
                refresh()
            }
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
        movements.removeAll()
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
            MovementDao(realm: realm).by(date: masterRouter.date).forEach { m in
                if m.transactionStatus != "OPEN" {
                    movements.append(m.report(realm: realm))
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

struct DiaryReportView: View {
    let viewRouter: ViewRouter
    let realm: Realm
    let diary: Diary
    
    @State private var visitType = 0//1 - Normal, 2 - Start Visit, 3 - Resume, 4 - Extra
    @State private var visitErrorText = ""
    
    let reportType = Config.get(key: "MOV_REPORT_TYPE", defaultValue: 1).value
    let allowExtra = Config.get(key: "MOV_ALLOW_EXTRA").value == 1
    let extraAlwaysOn = Config.get(key: "MOV_EXTRA_ALWAYS_ON").value == 1
    
    var body: some View {
        let panel = PanelUtils.panel(type: diary.panelType, objectId: diary.panelObjectId, id: diary.panelId)
        VStack {
            if let p = panel {
                let headerColor = PanelUtils.colorByPanelType(panel: p)
                let headerIcon = PanelUtils.iconByPanelType(panel: p)
                HStack {
                    Text(p.name ?? "")
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
                PanelItemMapView(item: p)
                    .frame(maxHeight: 200)
            }
            ScrollView {
                
            }
            VStack {
                switch visitType {
                    case 1:
                        Button {
                            goToVisit(type: "normal")
                        } label: {
                            HStack {
                                Image("ic-visit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 34, height: 34)
                                    .foregroundColor(.cIcon)
                                Text("envReportVisit")
                                    .foregroundColor(.cTextHigh)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 15)
                        }
                    case 2:
                        Button {
                            goToVisit(type: "normal")
                        } label: {
                            HStack {
                                Image("ic-visit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 34, height: 34)
                                    .foregroundColor(.cHighlighted)
                                Text("envStartVisit")
                                    .foregroundColor(.cHighlighted)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 15)
                        }
                    case 3:
                        Button {
                            goToVisit(type: "normal")
                        } label: {
                            HStack {
                                Image("ic-visit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 34, height: 34)
                                    .foregroundColor(.cHighlighted)
                                Text("envResumeVisit")
                                    .foregroundColor(.cHighlighted)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 15)
                        }
                    case 4:
                        Button {
                            goToVisit(type: "extra")
                        } label: {
                            HStack {
                                Image("ic-visit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 34, height: 34)
                                    .foregroundColor(.cWarning)
                                Text("envReportExtraVisit")
                                    .foregroundColor(.cWarning)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 15)
                        }
                    default:
                        VStack {
                            Text(visitErrorText)
                                .foregroundColor(.cTextHigh)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.cWarning)
                }
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        if let panel = PanelUtils.panel(type: diary.panelType, objectId: diary.panelObjectId, id: diary.panelId) {
            var couldStartVisit = false
            if reportType == 2 {
                if MovementUtils.existsMovementOpen(objectId: panel.objectId, type: panel.type) {
                    visitType = 3
                } else {
                    couldStartVisit = true
                }
            } else {
                couldStartVisit = true
            }
            if couldStartVisit {
                let couldVisitByNumber = panel.couldVisitByNumber()
                let couldVisitToday = panel.couldVisitToday()
                if couldVisitToday && couldVisitByNumber {
                    visitType = reportType == 2 ? 2 : 1
                } else {
                    if !couldVisitToday {
                        visitErrorText = NSLocalizedString("envVisitedToday", comment: "The panel member was visited today")
                    } else if !couldVisitByNumber {
                        visitErrorText = String(format: NSLocalizedString("envMaximumVisits", comment: "Maximum visits (%@/%@)"), String(panel.mainUser()?.visitsCycle ?? 0), String(panel.mainUser()?.visitsFee ?? 0))
                    } else {
                        visitErrorText = NSLocalizedString("envVisitNotAllowed", comment: "Visit not allowed")
                    }
                }
            }
            if allowExtra {
                let mainUser = panel.mainUser()
                if (mainUser?.visitsCycle ?? 0) < (mainUser?.visitsFee ?? 0) {
                    if extraAlwaysOn {
                        visitType = 4
                    }
                } else {
                    visitType = 4
                }
            }
        }
    }
    
    func goToVisit(type: String) {
        if let panel = PanelUtils.panel(type: diary.panelType, objectId: diary.panelObjectId, id: diary.panelId) {
            FormEntity(objectId: panel.objectId, type: panel.type, options: [ "visitType": type ]).go(path: "MOVEMENT-FORM", router: viewRouter)
        }
    }
    
}
