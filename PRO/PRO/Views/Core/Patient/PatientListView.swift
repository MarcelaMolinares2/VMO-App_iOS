//
//  PatientListView.swift
//  PRO
//
//  Created by VMO on 18/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift


struct PatientListView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @ObservedResults(Patient.self) var patients
    @State var searchText: String = ""
    @State var menuIsPresented = false
    @State var panel: Panel & SyncEntity = GenericPanel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                HeaderToggleView(couldSearch: true, title: "modPatient", icon: Image("ic-patient"), color: Color.cPanelPatient)
                ZStack(alignment: .trailing) {
                    Text(String(format: NSLocalizedString("envTotalPanel", comment: ""), String(patients.count)))
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
                        ForEach(patients.filter {
                            self.searchText.isEmpty ? true :
                                ($0.name ?? "").lowercased().contains(self.searchText.lowercased())
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
                FormEntity(objectId: "").go(path: PanelUtils.formByPanelType(type: "P"), router: viewRouter)
            }
        }
        .partialSheet(isPresented: $menuIsPresented) {
            PanelMenu(isPresented: self.$menuIsPresented, panel: panel)
        }
    }
    
}
