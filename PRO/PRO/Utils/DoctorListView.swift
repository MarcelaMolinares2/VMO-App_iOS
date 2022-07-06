//
//  MedicListView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import GoogleMaps

struct DoctorListView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var masterRouter: MasterRouter
    
    //@ObservedObject var data = BindableResults(results: try! Realm().objects(Doctor.self).sorted(byKeyPath: "firstName"))
    @ObservedResults(Doctor.self, sortDescriptor: SortDescriptor(keyPath: "firstName", ascending: true)) var doctors
    @State var menuIsPresented = false
    @State var panel: Panel & SyncEntity = GenericPanel()
    
    @State var layout: PanelLayout = .list
    
    let realm = try! Realm()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                PanelListHeader(total: doctors.count) {
                    
                }
                if layout == .list {
                    ScrollView {
                        LazyVStack {
                            ForEach(doctors.filter {
                                self.masterRouter.search.isEmpty ? true :
                                ($0.name ?? "").lowercased().contains(self.masterRouter.search.lowercased()) ||
                                ($0.institution ?? "").lowercased().contains(self.masterRouter.search.lowercased()) ||
                                //($0.specialty?.name ?? "").lowercased().contains(self.searchText.lowercased()) ||
                                $0.cityName(realm: self.realm).lowercased().contains(self.masterRouter.search.lowercased())
                            }, id: \.objectId) { element in
                                PanelItem(panel: element).onTapGesture {
                                    self.panel = element
                                    self.menuIsPresented = true
                                }
                            }
                        }
                    }
                } else {
                    Text("---")
                    //PanelListMapView(markers: <#T##Binding<[GMSMarker]>#>)
                }
            }
            HStack {
                FAB(image: "ic-map") {
                    
                }
                Spacer()
                FAB(image: "ic-plus") {
                    FormEntity(objectId: "").go(path: PanelUtils.formByPanelType(type: "M"), router: viewRouter)
                }
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 10)
        }
        .partialSheet(isPresented: $menuIsPresented) {
            PanelMenu(isPresented: self.$menuIsPresented, panel: panel)
        }
    }
}
