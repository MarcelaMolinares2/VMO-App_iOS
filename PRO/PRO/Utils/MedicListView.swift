//
//  MedicListView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct MedicListView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Binding var searchText: String
    @ObservedObject var data = BindableResults(results: try! Realm().objects(Doctor.self).sorted(byKeyPath: "firstName"))
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                ZStack(alignment: .trailing) {
                    Text("Total en panel: \(data.results.count)")
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 12))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    Button(action: {
                        
                    }) {
                        Text("Filtros")
                            .font(.system(size: 13))
                            .foregroundColor(.cTextLink)
                            .padding(.horizontal, 10)
                    }
                }
                ScrollView {
                    LazyVStack {
                        ForEach(data.results.filter {
                            self.searchText.isEmpty ? true :
                                ($0.name ?? "").lowercased().contains(self.searchText.lowercased()) ||
                                ($0.institution ?? "").lowercased().contains(self.searchText.lowercased()) ||
                                //($0.specialty?.name ?? "").lowercased().contains(self.searchText.lowercased()) ||
                                ($0.city?.name ?? "").lowercased().contains(self.searchText.lowercased())
                        }, id: \.id) { element in
                            PanelItem(panel: element)
                        }
                    }
                }
            }
            FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                FormEntity(id: 0).go(path: "MEDIC-FORM", router: viewRouter)
            }
        }
    }
}
