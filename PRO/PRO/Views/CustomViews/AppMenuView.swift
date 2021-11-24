//
//  AppMenuView.swift
//  PRO
//
//  Created by VMO on 23/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI

struct PanelMenu: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @Binding var isPresented: Bool
    @State var panel: Panel & SyncEntity
    @State var infoIsPresented = false
    
    @State var headerColor = Color.cPrimary
    @State var headerIcon = "ic-home"
    
    var fontSize = CGFloat(15)
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            HStack {
                Text(panel.name ?? "")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .padding(.horizontal, 5)
                    .foregroundColor(.white)
                Image(headerIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34, alignment: .center)
                    .padding(4)
            }
            .background(headerColor)
            .frame(maxWidth: .infinity)
            LazyVGrid(columns: layout, spacing: 20) {
                Button(action: {
                    //self.isPresented = false
                    //FormEntity(id: panel.id, type: "C").go(path: "PANEL-CARD", router: viewRouter)
                    self.infoIsPresented = true
                }) {
                    VStack {
                        Image("ic-info")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cPrimary)
                        Text("envKeyInfo")
                            .foregroundColor(.cPrimary)
                            .lineLimit(1)
                            .font(.system(size: fontSize))
                    }
                }
                .sheet(isPresented: $infoIsPresented) {
                    KeyInfoView(panel: panel, headerColor: headerColor, headerIcon: headerIcon)
                }
                Button(action: {
                    self.isPresented = false
                    FormEntity(objectId: panel.objectId.stringValue, type: panel.type, options: [ "tab": "CARD" ]).go(path: "PANEL-CARD", router: viewRouter)
                }) {
                    VStack {
                        Image("ic-summary")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cPrimary)
                        Text("envDetail")
                            .foregroundColor(.cPrimary)
                            .lineLimit(1)
                            .font(.system(size: fontSize))
                    }
                }
                Button(action: {
                    self.isPresented = false
                    FormEntity(objectId: panel.objectId.stringValue, type: panel.type, options: [ "visitType": "normal" ]).go(path: "MOVEMENT-FORM", router: viewRouter)
                }) {
                    VStack {
                        Image("ic-visit")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cPrimary)
                        Text("envVisit")
                            .foregroundColor(.cPrimary)
                            .lineLimit(1)
                            .font(.system(size: fontSize))
                    }
                }
                if Config.get(key: "MOV_ALLOW_EXTRA").value == 1 {
                    Button(action: {
                        
                    }) {
                        VStack {
                            Image("ic-visit")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                .foregroundColor(.cPrimary)
                            Text("envExtraVisit")
                                .foregroundColor(.cPrimary)
                                .lineLimit(1)
                                .font(.system(size: fontSize))
                        }
                    }
                }
                Button(action: {
                    self.isPresented = false
                    FormEntity(objectId: panel.objectId.stringValue, type: panel.type, options: [ "tab": "RECORD" ]).go(path: "PANEL-CARD", router: viewRouter)
                }) {
                    VStack {
                        Image("ic-medical-history")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cPrimary)
                        Text("envRecord")
                            .foregroundColor(.cPrimary)
                            .lineLimit(1)
                            .font(.system(size: fontSize))
                    }
                }
                if panel.type != "M" {
                    Button(action: {
                        self.isPresented = false
                        FormEntity(objectId: panel.objectId.stringValue, type: panel.type, options: [ "tab": "CONTACTS" ]).go(path: "PANEL-CARD", router: viewRouter)
                    }) {
                        VStack {
                            Image("ic-client")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                .foregroundColor(.cPrimary)
                            Text("envContacts")
                                .foregroundColor(.cPrimary)
                                .lineLimit(1)
                                .font(.system(size: fontSize))
                        }
                    }
                }
                Button(action: {
                    self.isPresented = false
                    FormEntity(objectId: panel.objectId.stringValue, type: panel.type, options: [ "tab": "BASIC" ])
                        .go(path: PanelUtils.formByPanelType(panel: panel), router: viewRouter)
                }) {
                    VStack {
                        Image("ic-edit")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cPrimary)
                        Text("envEdit")
                            .foregroundColor(.cPrimary)
                            .lineLimit(1)
                            .font(.system(size: fontSize))
                    }
                }
                Button(action: {
                    
                }) {
                    VStack {
                        Image("ic-forbidden")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cPrimary)
                        Text("envDeactivate")
                            .foregroundColor(.cPrimary)
                            .lineLimit(1)
                            .font(.system(size: fontSize))
                    }
                }
                if panel.type == "M" {
                    Button(action: {
                    }) {
                        VStack {
                            Image("ic-signature")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                .foregroundColor(.cPrimary)
                            Text("envHData")
                                .foregroundColor(.cPrimary)
                                .lineLimit(1)
                                .font(.system(size: fontSize))
                        }
                    }
                }
            }
        }
        .onAppear {
            initUI()
        }
    }
    
    func initUI() {
        switch panel.type {
        case "M":
            self.headerColor = .cPanelMedic
            self.headerIcon = "ic-medic"
        case "F":
            self.headerColor = .cPanelPharmacy
            self.headerIcon = "ic-pharmacy"
        case "C":
            self.headerColor = .cPanelClient
            self.headerIcon = "ic-client"
        default:
            self.headerColor = .cPrimary
        }
    }
}

struct GlobalMenu: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Binding var isPresented: Bool
    
    @State var usrFullName = ""
    @State var usrEmail = ""
    @State var appVersion = ""
    @State var iconSize = CGFloat(30)
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    userSettings.successfullLogout()
                }) {
                    HStack {
                        Image("ic-logout")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.cDanger)
                        Text("envLogout")
                            .foregroundColor(.cDanger)
                    }
                    .padding(.leading, 10)
                }
                Spacer()
                Button(action: {
                    
                }) {
                    Image("ic-search")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 30, alignment: .center)
                        .foregroundColor(.cPrimary)
                }
                Button(action: {
                    
                }) {
                    Image("ic-location")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 30, alignment: .center)
                        .foregroundColor(.cPrimary)
                }
                Button(action: {
                    self.goTo(page: "MASTER")
                }) {
                    Image("ic-home")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 30, alignment: .center)
                        .foregroundColor(.cPrimary)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 30, maxHeight: 30)
            HStack {
                VStack {
                    Text(self.usrFullName)
                        .lineLimit(1)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(self.usrEmail)
                        .lineLimit(1)
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 10)
                Spacer()
                /*
                 KFImage(URL(string: "https://testing.vmocentral.com/assets/images/laboratories/\(UserDefaults.standard.string(forKey: Globals.LABORATORY_PATH) ?? "").png"))
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 0, maxWidth: 140, minHeight: 0, maxHeight: 80, alignment: .center)
                */
            }
            HStack {
                Button(action: {
                    
                }) {
                    VStack {
                        Image("ic-diary")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cPrimary)
                        Text("modDiary")
                            .foregroundColor(.cPrimary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Button(action: {
                    self.goTo(page: "ROUTE-VIEW")
                }) {
                    VStack {
                        Image("ic-people-route")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cPrimary)
                        Text("modPeopleRoute")
                            .foregroundColor(.cPrimary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Button(action: {
                    self.goTo(page: "PATIENT-LIST")
                }) {
                    VStack {
                        Image("ic-patient")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cPrimary)
                        Text("modPatient")
                            .foregroundColor(.cPrimary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Button(action: {
                    
                }) {
                    VStack {
                        Image("ic-report")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cPrimary)
                        Text("modReports")
                            .foregroundColor(.cPrimary)
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxHeight: 80)
            ScrollView {
                VStack {
                    Button(action: {
                    }) {
                        HStack {
                            Image("ic-visit")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: iconSize, minHeight: iconSize, maxHeight: iconSize, alignment: .center)
                                .foregroundColor(.cPrimary)
                                .padding(6)
                            Text("modBatchReport")
                                .foregroundColor(.cPrimary)
                                .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    Button(action: {
                        self.goTo(page: "POTENTIAL-LIST")
                    }) {
                        HStack {
                            Image("ic-medic")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: iconSize, minHeight: iconSize, maxHeight: iconSize, alignment: .center)
                                .foregroundColor(.cPrimary)
                                .padding(6)
                            Text("modPotentialProfessional")
                                .foregroundColor(.cPrimary)
                                .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    Button(action: {
                        self.goTo(page: "REQUEST-DAY")
                    }) {
                        HStack {
                            Image("ic-day-request")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: iconSize, maxHeight: iconSize, alignment: .center)
                                .foregroundColor(.cPrimary)
                                .padding(6)
                            Text("modRequestDays")
                                .foregroundColor(.cPrimary)
                                .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    Button(action: {
                        self.goTo(page: "REQUEST-MATERIAL")
                    }) {
                        HStack {
                            Image("ic-material")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: iconSize, maxHeight: iconSize, alignment: .center)
                                .foregroundColor(.cPrimary)
                                .padding(6)
                            Text("modRequestMaterial")
                                .foregroundColor(.cPrimary)
                                .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    Button(action: {
                        self.goTo(page: "MATERIAL-DELIVERY")
                    }) {
                        HStack {
                            Image("ic-material-delivery")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: iconSize, maxHeight: iconSize, alignment: .center)
                                .foregroundColor(.cPrimary)
                                .padding(6)
                            Text("modMaterialDelivery")
                                .foregroundColor(.cPrimary)
                                .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    Button(action: {
                    }) {
                        HStack {
                            Image("ic-expense")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: iconSize, maxHeight: iconSize, alignment: .center)
                                .foregroundColor(.cPrimary)
                                .padding(6)
                            Text("modExpenses")
                                .foregroundColor(.cPrimary)
                                .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    Button(action: {
                    }) {
                        HStack {
                            Image("ic-shopping-list")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: iconSize, maxHeight: iconSize, alignment: .center)
                                .foregroundColor(.cPrimary)
                                .padding(6)
                            Text("modTransference")
                                .foregroundColor(.cPrimary)
                                .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    Button(action: {
                        self.goTo(page: "SUPPORT")
                    }) {
                        HStack {
                            Image("ic-support")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: iconSize, maxHeight: iconSize, alignment: .center)
                                .foregroundColor(.cPrimary)
                                .padding(6)
                            Text("modSupport")
                                .foregroundColor(.cPrimary)
                                .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 240)
            Text(appVersion)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.cPrimary)
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        if let user = userSettings.userData() {
            self.usrFullName = user.name ?? ""
            self.usrEmail = user.email ?? ""
        }
        if let v = Utils.appVersion() {
            self.appVersion = "v. \(v)"
        }
    }
    
    func goTo(page: String) {
        viewRouter.currentPage = page
        self.isPresented = false
    }
}

struct PanelTypeMenu: View {
    let onPanelSelected: (_ type: String) -> Void
    
    @State var panelTypes: [String]
    @Binding var isPresented: Bool
    @State private var customGridItems: [GenericGridItem] = []
    @State var columns: [GridItem] = []
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(customGridItems, id: \.id) { item in
                    Button(action: {
                        onPanelSelected(item.id)
                    }) {
                        VStack {
                            Image(item.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                .foregroundColor(item.color)
                            Text(NSLocalizedString(item.name, comment: ""))
                                .foregroundColor(.cPrimary)
                                .lineLimit(1)
                                .font(.system(size: CGFloat(15)))
                        }
                    }
                    .padding([.top, .bottom], 10)
                }
            }
        }
        .padding(.bottom, 2)
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        var card = GenericGridItem(id: "", color: .cPrimary, icon: "none", name: "none")
        for item in panelTypes {
            card.id = item
            switch item {
                case "M":
                    card.color = .cPanelMedic
                    card.icon = "ic-medic"
                    card.name = "modMedic"
                case "F":
                    card.color = .cPanelPharmacy
                    card.icon = "ic-pharmacy"
                    card.name = "modPharmacy"
                case "C":
                    card.color = .cPanelClient
                    card.icon = "ic-client"
                    card.name = "modClient"
                case "P":
                    card.color = .cPanelPatient
                    card.icon = "ic-patient"
                    card.name = "modPatient"
                default:
                    print("default")
            }
            customGridItems.append(card)
            if columns.count < 4 {
                columns.append(GridItem(.flexible()))
            }
        }
    }
}

struct RouteBottomMenu: View {
    let onEdit: (_ group: Group) -> Void
    let onDelete: (_ group: Group) -> Void
    
    @State var group: Group
    @State private var customGridItems: [GenericGridItem] = []
    @State var columns: [GridItem] = []
    
    var body: some View {
        VStack {
            HStack {
                Text(group.name ?? "")
                Spacer()
            }
            .padding(10)
            .foregroundColor(.white)
            .background(Color.cPrimaryLight.opacity(1))
            HStack {
                Spacer()
                Button(action: {
                    onEdit(group)
                }) {
                    VStack {
                        Image("ic-edit")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cPrimaryLight)
                        Text(NSLocalizedString("envEdit", comment: ""))
                            .foregroundColor(.cPrimary)
                            .lineLimit(1)
                            .font(.system(size: CGFloat(15)))
                    }
                }
                .padding([.top, .bottom], 10)
                Spacer()
                Button(action: {
                    onDelete(group)
                }) {
                    VStack {
                        Image("ic-trash")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cPrimaryLight)
                        Text(NSLocalizedString("Delete", comment: ""))
                            .foregroundColor(.cPrimary)
                            .lineLimit(1)
                            .font(.system(size: CGFloat(15)))
                    }
                }
                .padding([.top, .bottom], 10)
                Spacer()
            }
            .padding(.bottom, 2)
        }
    }
}
