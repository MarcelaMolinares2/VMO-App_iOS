//
//  PanelGlobalSearchView.swift
//  PRO
//
//  Created by VMO on 11/09/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

class SearchBarViewModel: ObservableObject {
    @Published var text: String = ""
}

struct PanelGlobalSearchView: View {
    @StateObject private var model = SearchBarViewModel()

    @State private var layout: PanelGlobalSearchLayout = .list
    @State private var panels: [PanelReport] = []
    @State private var panelTapped: Panel = GenericPanel()
    @State private var complementaryData: [String: Any] = [:]
    
    @State private var modalMenu = false
    @State private var modalRequestActivation = false
    @State private var modalRequestMove = false
    
    var realm = try! Realm()
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modGeneralSearch")
            SearchBar(text: $model.text, placeholder: Text("Search")) {
                
            }
            .onReceive(
                model.$text
                    .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            ) {
                guard !$0.isEmpty else { return }
                search()
            }
            switch layout {
                case .list:
                    VStack {
                        Text(String(format: NSLocalizedString("envTotalPanel", comment: ""), String(panels.count)))
                            .foregroundColor(.cTextMedium)
                            .font(.system(size: 12))
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        ScrollView {
                            LazyVStack {
                                ForEach(panels) { panel in
                                    PanelItemReport(realm: realm, panel: panel) {
                                        self.panelTapped = panel
                                        if panel.findUser(userId: JWTUtils.sub()) != nil {
                                            if panel.inactive == "Y" {
                                                modalRequestActivation = true
                                            } else {
                                                switch panel.type {
                                                    case "M":
                                                        if let doctor = DoctorDao(realm: realm).by(id: panel.id) {
                                                            complementaryData["hd"] = doctor.habeasData
                                                            complementaryData["tv"] = doctor.tvConsent
                                                        }
                                                    default:
                                                        break
                                                }
                                                modalMenu = true
                                            }
                                        } else {
                                            modalRequestMove = true
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
                        }
                    }
                case .searching:
                    VStack {
                        Spacer()
                        LottieView(name: "search_animation", loopMode: .loop, speed: 1)
                            .frame(width: 300, height: 200)
                        Spacer()
                    }
                case .error:
                    NoConnectionView()
                        .onTapGesture {
                            search()
                        }
            }
        }
        .sheet(isPresented: $modalMenu) {
            PanelMenu(isPresented: self.$modalMenu, panel: $panelTapped, complementaryData: complementaryData)
        }
        .partialSheet(isPresented: $modalRequestActivation) {
            
        }
        .partialSheet(isPresented: $modalRequestMove) {
            
        }
    }
    
    func search() {
        panels.removeAll()
        if !model.text.isEmpty {
            layout = .searching
            AppServer().postRequest(data: ["s": model.text], path: "vm/panel/filter") { success, code, data in
                if success {
                    if let rs = data as? [String] {
                        for item in rs {
                            let decoded = try! JSONDecoder().decode(PanelReport.self, from: item.data(using: .utf8)!)
                            panels.append(decoded)
                        }
                    }
                    panels.sort { d1, d2 in
                        return d1.name ?? "" < d2.name ?? ""
                    }
                    layout = .list
                } else {
                    layout = .error
                }
            }
        }
    }
    
}
