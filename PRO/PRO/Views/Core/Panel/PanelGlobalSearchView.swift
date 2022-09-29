//
//  PanelGlobalSearchView.swift
//  PRO
//
//  Created by VMO on 11/09/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast
import SheeKit

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
    @State private var modalFormRequestActivation = false
    @State private var modalFormRequestMove = false
    @State private var modalInfo = false
    @State private var modalDelete = false
    
    @State private var actionSavedToast = false
    
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
                                                modalFormRequestActivation = true
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
                                            modalFormRequestMove = true
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
            PanelMenu(isPresented: self.$modalMenu, panel: $panelTapped, complementaryData: complementaryData) {
                modalInfo = true
            } onDeleteTapped: {
                modalDelete = true
            }
        }
        .shee(isPresented: $modalInfo, presentationStyle: .formSheet(properties: .init(detents: [.medium(), .large()]))) {
            PanelKeyInfoView(panel: panelTapped)
        }
        .shee(isPresented: $modalDelete, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
            PanelDeleteView(panel: panelTapped) {
                modalDelete = false
            }
        }
        .partialSheet(isPresented: $modalFormRequestActivation) {
            PanelGlobalFormActionView(panel: panelTapped, action: "activation") {
                modalFormRequestActivation = false
                actionSavedToast = true
            }
        }
        .partialSheet(isPresented: $modalFormRequestMove) {
            PanelGlobalFormActionView(panel: panelTapped, action: "move") {
                modalFormRequestMove = false
                actionSavedToast = true
            }
        }
        .toast(isPresenting: $actionSavedToast) {
            AlertToast(type: .complete(.cDone), title: NSLocalizedString("envSuccessfullySaved", comment: ""))
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

struct PanelGlobalFormActionView: View {
    var panel: Panel
    var action: String
    let onActionDone: () -> Void
    
    @State private var headerColor = Color.cPrimary
    @State private var headerIcon = "ic-home"
    
    @State private var reason = ""
    
    @State private var isProcessing = false
    
    @State private var toastMessage = ""
    @State private var toastShow = false
    
    var body: some View {
        VStack {
            HStack {
                Text(panel.name ?? "")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .padding(.horizontal, 5)
                    .foregroundColor(.cTextHigh)
                Image(headerIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(headerColor)
                    .frame(width: 34, height: 34, alignment: .center)
                    .padding(4)
            }
            if isProcessing {
                LottieView(name: "upload_animation", loopMode: .loop, speed: 1)
                    .frame(width: 300, height: 200)
            } else {
                CustomSection {
                    VStack {
                        Text("envRequest\(action.capitalized)".localized())
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.cTextMedium)
                    }
                    .padding(.vertical, 10)
                    VStack {
                        Text("envRequestReason")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor((reason.isEmpty) ? .cDanger : .cTextMedium)
                            .font(.system(size: 14))
                        VStack{
                            TextEditor(text: $reason)
                                .frame(height: 80)
                        }
                    }
                    if !reason.isEmpty {
                        Button {
                            save()
                        } label: {
                            Text("envSendRequest")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.cTextHigh)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                }
            }
        }
        .toast(isPresenting: $toastShow) {
            return AlertToast(type: .regular, title: toastMessage.localized())
        }
        .onAppear {
            ui()
        }
    }
    
    func ui() {
        self.headerColor = PanelUtils.colorByPanelType(panel: panel)
        self.headerIcon = PanelUtils.iconByPanelType(panel: panel)
    }
    
    func save() {
        isProcessing = true
        AppServer().postRequest(data: ["content": reason], path: "vm/panel/\(action == "move" ? "transference" : "reactivate")") { success, code, data in
            if success {
                onActionDone()
            } else {
                toastMessage = "errServerConection"
                toastShow = true
            }
            isProcessing = false
        }
    }
    
}
