//
//  MedicListView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct DoctorListView: View {
    @ObservedResults(Doctor.self) var doctors
    
    let realm = try! Realm()
    
    @State private var menuIsPresented = false
    @State private var doctorTapped: Doctor = Doctor()
    @State private var selected = [ObjectId]()
    
    var body: some View {
        CustomPanelDoctorView(realm: realm, results: $doctors, selected: $selected) { panel in
            self.doctorTapped = panel
            menuIsPresented = true
        }
        .partialSheet(isPresented: $menuIsPresented) {
            PanelMenu(isPresented: self.$menuIsPresented, panel: doctorTapped)
        }
    }
}

struct DoctorSelectView: View {
    @ObservedResults(Doctor.self) var doctors
    
    let realm = try! Realm()
    
    @State private var selected = [ObjectId]()
    
    var body: some View {
        CustomPanelDoctorView(realm: realm, results: $doctors, selected: $selected) { panel in
            selected.appendToggle(panel.objectId)
        }
    }
}

struct CustomPanelDoctorView: View {
    @EnvironmentObject var masterRouter: MasterRouter
    
    var realm: Realm
    @ObservedResults var results: Results<Doctor>
    @Binding var selected: [ObjectId]
    let onItemTapped: (_ doctor: Doctor) -> Void
    
    private let sortOptions = ["name", "category", "city", "coverage", "institution", "specialty", "visits"]
    private let filterOptions = ["brick", "category", "city", "join_date", "recently_added", "specialty", "style", "zone"]
    
    @State private var sort: SortModel = SortModel(key: "name_form", ascending: true)
    @State private var filters: [DynamicFilter] = []
    
    var body: some View {
        if let filtered = filterRs() {
            CustomPanelListView(realm: realm, totalPanel: results.count, filtered: filtered, sortOptions: sortOptions, filtersDynamic: filterOptions, sort: $sort, filters: $filters) {
                ForEach(filtered, id: \.objectId) { element in
                    PanelItemDoctor(realm: realm, userId: JWTUtils.sub(), doctor: element) {
                        onItemTapped(element)
                    }
                    .background(selected.contains(element.objectId) ? Color.cBackground1dp : nil)
                }
            }
        }
    }
    
    func filterRs() -> [Doctor]? {
        var rs: [Doctor] = results.filter {
            self.masterRouter.search.isEmpty ? true :
            ($0.name ?? "").lowercased().contains(self.masterRouter.search.lowercased()) ||
            ($0.institution ?? "").lowercased().contains(self.masterRouter.search.lowercased()) ||
            $0.specialtyName(realm: realm).lowercased().contains(self.masterRouter.search.lowercased()) ||
            $0.cityName(realm: self.realm).lowercased().contains(self.masterRouter.search.lowercased())
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
                    case "specialty":
                        rs = rs.filter { d in
                            return df.values.contains(String(Utils.castInt(value: d.specialtyId)))
                        }
                    case "style":
                        rs = rs.filter { d in
                            return df.values.contains(String(Utils.castInt(value: d.styleId)))
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
                case "institution":
                    if sort.ascending {
                        return d1.institution ?? "" < d2.institution ?? ""
                    } else {
                        return d1.institution ?? "" > d2.institution ?? ""
                    }
                case "specialty":
                    if sort.ascending {
                        return d1.specialtyName(realm: realm) < d2.specialtyName(realm: realm)
                    } else {
                        return d1.specialtyName(realm: realm) > d2.specialtyName(realm: realm)
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
