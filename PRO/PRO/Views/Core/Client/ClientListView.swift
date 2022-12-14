//
//  ClientListView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import SheeKit

struct ClientListWrapperView: View {
    @EnvironmentObject var masterRouter: MasterRouter
    
    var body: some View {
        VStack {
            HeaderToggleView(search: $masterRouter.search, title: "modClients")
            ClientListView()
        }
    }
    
}

struct ClientListView: View {
    @ObservedResults(Client.self) var clients
    
    let realm = try! Realm()
    
    @State private var clientTapped: Panel = GenericPanel()
    @State private var complementaryData: [String: Any] = [:]
    @State private var selected = [ObjectId]()
    
    @State private var menuIsPresented = false
    @State private var modalInfo = false
    @State private var modalDelete = false
    @State private var modalVisitsFee = false
    
    var body: some View {
        CustomPanelClientView(realm: realm, results: $clients, selected: $selected) { panel in
            self.clientTapped = panel
            menuIsPresented = true
        }
        .sheet(isPresented: $menuIsPresented) {
            PanelMenu(isPresented: self.$menuIsPresented, panel: $clientTapped, complementaryData: complementaryData) {
                modalInfo = true
            } onDeleteTapped: {
                modalDelete = true
            } onVisitsFeeTapped: {
                modalVisitsFee = true
            }
        }
        .shee(isPresented: $modalInfo, presentationStyle: .formSheet(properties: .init(detents: [.medium(), .large()]))) {
            PanelKeyInfoView(panel: clientTapped)
        }
        .shee(isPresented: $modalDelete, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
            PanelDeleteView(panel: clientTapped) {
                modalDelete = false
            }
        }
        .shee(isPresented: $modalVisitsFee, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
            PanelVisitsFeeView(panel: clientTapped) {
                modalVisitsFee = false
            }
        }
    }
}

struct ClientSelectView: View {
    @ObservedResults(Client.self) var clients
    
    @Binding var selected: [ObjectId]
    let onSelectionDone: () -> Void
    
    let realm = try! Realm()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            CustomPanelClientView(realm: realm, results: $clients, selected: $selected, couldToggleMap: false, couldSelectAgent: false, couldGoToForm: false) { panel in
                selected.appendToggle(panel.objectId)
            }
            HStack(alignment: .bottom) {
                Spacer()
                FAB(image: "ic-done") {
                    onSelectionDone()
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
    }
}

struct CustomPanelClientView: View {
    @EnvironmentObject var masterRouter: MasterRouter
    
    var realm: Realm
    @ObservedResults var results: Results<Client>
    @Binding var selected: [ObjectId]
    var couldToggleMap = true
    var couldSelectAgent = true
    var couldGoToForm = true
    let onItemTapped: (_ client: Client) -> Void
    
    private let sortOptions = ["name", "category", "city", "coverage", "visits"]
    private let filterOptions = ["brick", "category", "city", "join_date", "recently_added", "zone"]
    
    @State private var sort: SortModel = SortModel(key: "name_form", ascending: true)
    @State private var filters: [DynamicFilter] = []
    @State private var userSelected = 0
    
    @State private var serverLoading = false
    @State private var serverResults = [Client]()
    
    var body: some View {
        if let filtered = filterRs() {
            if serverLoading {
                VStack {
                    Spacer()
                    LottieView(name: "search_animation", loopMode: .loop, speed: 1)
                        .frame(width: 300, height: 200)
                    Spacer()
                }
            } else {
                CustomPanelListView(realm: realm, panelType: "C", totalPanel: userSelected > 0 ? serverResults.count : results.count, filtered: filtered, sortOptions: sortOptions, filtersDynamic: filterOptions, sort: $sort, filters: $filters, userSelected: $userSelected, couldToggleMap: couldToggleMap, couldSelectAgent: couldSelectAgent, couldGoToForm: couldGoToForm, onAgentChanged: {
                    loadAgentPanel()
                }) {
                    ForEach(filtered, id: \.objectId) { element in
                        PanelItemClient(realm: realm, userId: userSelected <= 0 ? JWTUtils.sub() : userSelected, client: element) {
                            onItemTapped(element)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .background(selected.contains(element.objectId) ? Color.cBackground3dp : nil)
                    }
                }
            }
        }
    }
    
    func loadAgentPanel() {
        serverLoading = true
        serverResults.removeAll()
        AppServer().postRequest(data: ["user_ids" : userSelected], path: "vm/client/filter") { success, code, data in
            serverLoading = false
            if success {
                if let rs = data as? [String] {
                    for item in rs {
                        let decoded = try! JSONDecoder().decode(Client.self, from: item.data(using: .utf8)!)
                        serverResults.append(decoded)
                    }
                }
            }
        }
    }
    
    func filterRs() -> [Client]? {
        var rs: [Client]
        if userSelected > 0 {
            rs = serverResults
        } else {
            rs = Array(results)
        }
        filters.forEach { df in
            if !df.values.isEmpty {
                switch df.key {
                    case "contact_type":
                        rs = rs.filter { d in
                            if df.values.contains("P") {
                                return d.visitFTF == 1
                            } else {
                                return d.visitVirtual == 1
                            }
                        }
                    case "visits":
                        rs = rs.filter { d in
                            if df.values.contains("N") {
                                return d.mainUser()?.visitsCycle ?? 0 <= 0
                            } else if df.values.contains("P") {
                                return d.mainUser()?.visitsCycle ?? 0 > 0 && d.mainUser()?.visitsCycle ?? 0 < d.mainUser()?.visitsFee ?? 0
                            } else {
                                return d.mainUser()?.visitsCycle ?? 0 > 0 && d.mainUser()?.visitsCycle ?? 0 >= d.mainUser()?.visitsFee ?? 0
                            }
                        }
                    case "brick":
                        rs = rs.filter { d in
                            return df.values.contains(String(Utils.castInt(value: d.brickId)))
                        }
                    case "category":
                        rs = rs.filter { d in
                            return !d.categories.filter { pc in
                                df.values.contains(String(Utils.castInt(value: pc.categoryId)))
                            }.isEmpty
                        }
                    case "city":
                        rs = rs.filter { d in
                            return df.values.contains(String(Utils.castInt(value: d.cityId)))
                        }
                    case "zone":
                        rs = rs.filter { d in
                            return df.values.contains(String(Utils.castInt(value: d.zoneId)))
                        }
                    default:
                        break
                }
            }
        }
        if !masterRouter.search.isEmpty {
            rs = rs.filter {
                ($0.name ?? "").lowercased().contains(self.masterRouter.search.lowercased()) ||
                $0.cityName(realm: self.realm).lowercased().contains(self.masterRouter.search.lowercased())
            }
        }
        rs.sort { d1, d2 in
            switch sort.key {
                case "category":
                    if sort.ascending {
                        return d1.mainCategory(realm: realm) < d2.mainCategory(realm: realm)
                    } else {
                        return d1.mainCategory(realm: realm) > d2.mainCategory(realm: realm)
                    }
                case "city":
                    if sort.ascending {
                        return d1.cityName(realm: realm) < d2.cityName(realm: realm)
                    } else {
                        return d1.cityName(realm: realm) > d2.cityName(realm: realm)
                    }
                case "coverage":
                    if sort.ascending {
                        return d1.coverage(userId: 0) < d2.coverage(userId: 0)
                    } else {
                        return d1.coverage(userId: 0) > d2.coverage(userId: 0)
                    }
                case "visits":
                    if sort.ascending {
                        return d1.visitsInCycle() ?? 0 < d2.visitsInCycle() ?? 0
                    } else {
                        return d1.visitsInCycle() ?? 0 > d2.visitsInCycle() ?? 0
                    }
                default:
                    if sort.ascending {
                        return d1.name ?? "" < d2.name ?? ""
                    } else {
                        return d1.name ?? "" > d2.name ?? ""
                    }
            }
        }
        return rs
    }
    
}
