//
//  ClientListView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct ClientListView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Binding var searchText: String
    @ObservedResults(Client.self, sortDescriptor: SortDescriptor(keyPath: "name", ascending: true)) var clients
    @State var menuIsPresented = false
    @State var panel: Panel & SyncEntity = GenericPanel()
    
    let realm = try! Realm()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                ZStack(alignment: .trailing) {
                    Text(String(format: NSLocalizedString("envTotalPanel", comment: ""), String(clients.count)))
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
                        ForEach(clients.filter {
                            self.searchText.isEmpty ? true :
                                ($0.name ?? "").lowercased().contains(self.searchText.lowercased()) ||
                                ($0.cityName(realm: self.realm)).lowercased().contains(self.searchText.lowercased())
                        }, id: \.objectId) { element in
                            PanelItem(panel: element).onTapGesture {
                                self.panel = element
                                self.menuIsPresented = true
                            }
                        }
                    }
                }
            }
            FAB(image: "ic-plus") {
                FormEntity(objectId: "").go(path: PanelUtils.formByPanelType(type: "C"), router: viewRouter)
            }
        }
        .partialSheet(isPresented: $menuIsPresented) {
            PanelMenu(isPresented: self.$menuIsPresented, panel: panel)
        }
    }
}
