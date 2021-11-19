//
//  PharmacyListView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct PharmacyListView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @ObservedResults(Pharmacy.self, sortDescriptor: SortDescriptor(keyPath: "name", ascending: true)) var pharmacies
    @Binding var searchText: String
    @State var menuIsPresented = false
    @State var panel: Panel & SyncEntity = GenericPanel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                ZStack(alignment: .trailing) {
                    Text(String(format: NSLocalizedString("envTotalPanel", comment: ""), String(pharmacies.count)))
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 12))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    Button(action: {
                        
                    }) {
                        Text("envFilters")
                            .font(.system(size: 13))
                            .foregroundColor(.cTextLink)
                            .padding(.horizontal, 10)
                    }
                }
                ScrollView {
                    LazyVStack {
                        ForEach(pharmacies.filter {
                            self.searchText.isEmpty ? true :
                                ($0.name ?? "").lowercased().contains(self.searchText.lowercased()) ||
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
                FormEntity(objectId: "").go(path: PanelUtils.formByPanelType(type: "F"), router: viewRouter)
            }
        }
        .partialSheet(isPresented: $menuIsPresented) {
            PanelMenu(isPresented: self.$menuIsPresented, panel: panel)
        }
    }
}
