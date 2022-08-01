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
    
    private let sortOptions = ["name_form", "category", "city", "coverage", "institution", "specialty", "visits"]
    private let filterOptions = ["brick", "category", "city", "join_date", "recently_added", "specialty", "style", "zone"]
    
    @State private var sort: SortModel = SortModel(key: "name_form", ascending: true)
    @State private var filters: [DynamicFilter] = []
    
    var body: some View {
        if let filtered = filterRs() {
            CustomPanelListView(realm: realm, totalPanel: results.count, filtered: filtered, filtersDynamic: filterOptions, sort: $sort, filters: $filters) {
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
        let rs: [Doctor] = results.filter {
            self.masterRouter.search.isEmpty ? true :
            ($0.name ?? "").lowercased().contains(self.masterRouter.search.lowercased()) ||
            ($0.institution ?? "").lowercased().contains(self.masterRouter.search.lowercased()) ||
            $0.specialtyName(realm: realm).lowercased().contains(self.masterRouter.search.lowercased()) ||
            $0.cityName(realm: self.realm).lowercased().contains(self.masterRouter.search.lowercased())
        }
        return rs
    }
    
}
