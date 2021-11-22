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
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Binding var searchText: String
    //@ObservedObject var data = BindableResults(results: try! Realm().objects(Doctor.self).sorted(byKeyPath: "firstName"))
    @ObservedResults(Doctor.self, sortDescriptor: SortDescriptor(keyPath: "firstName", ascending: true)) var doctors
    @State var menuIsPresented = false
    @State var panel: Panel & SyncEntity = GenericPanel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                PanelListHeader(total: doctors.count) {
                    
                }
                ScrollView {
                    LazyVStack {
                        ForEach(doctors.filter {
                            self.searchText.isEmpty ? true :
                                ($0.name ?? "").lowercased().contains(self.searchText.lowercased()) ||
                                ($0.institution ?? "").lowercased().contains(self.searchText.lowercased()) ||
                                //($0.specialty?.name ?? "").lowercased().contains(self.searchText.lowercased()) ||
                                ($0.city?.name ?? "").lowercased().contains(self.searchText.lowercased())
                        }, id: \.objectId) { element in
                            PanelItem(panel: element).onTapGesture {
                                self.panel = element
                                self.menuIsPresented = true
                            }
                        }
                    }
                }
            }
            FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                FormEntity(objectId: "").go(path: PanelUtils.formByPanelType(type: "M"), router: viewRouter)
            }
        }
        .partialSheet(isPresented: $menuIsPresented) {
            PanelMenu(isPresented: self.$menuIsPresented, panel: panel)
        }
    }
}
