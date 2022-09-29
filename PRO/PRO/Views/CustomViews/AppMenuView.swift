//
//  AppMenuView.swift
//  PRO
//
//  Created by VMO on 23/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import SheeKit

struct PanelMenu: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @Binding var isPresented: Bool
    @Binding var panel: Panel
    var complementaryData: [String: Any] = [:]
    
    let onInfoTapped: () -> Void
    let onDeleteTapped: () -> Void
    
    @State var modalHabeasData = false
    @State var modalSummary = false
    
    @State var headerColor = Color.cPrimary
    @State var headerIcon = "ic-home"
    
    var fontSize = CGFloat(15)
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let reportType = Config.get(key: "MOV_REPORT_TYPE", defaultValue: 1)
    let allowExtra = Config.get(key: "MOV_ALLOW_EXTRA")
    let extraAlwaysOn = Config.get(key: "MOV_EXTRA_ALWAYS_ON")
    let moduleTV = Config.get(key: "MOD_TV")
    let moduleCC = Config.get(key: "VM-MOD-CC")
    
    @State private var couldVisit = false
    @State private var couldVisitExtra = false
    @State private var visitError = false
    @State private var visitText = ""
    @State private var visitErrorText = ""

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
            .frame(maxWidth: .infinity)
            if visitError {
                VStack {
                    Text(visitErrorText)
                        .foregroundColor(.cTextHigh)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                }
                .frame(maxWidth: .infinity)
                .background(Color.cWarning)
            }
            if panel.hasDeleteRequest() {
                VStack {
                    Text("envMarkedForDelete")
                        .foregroundColor(.cTextHigh)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                }
                .frame(maxWidth: .infinity)
                .background(Color.cError)
            }
            PanelItemMapView(item: panel)
            VStack {
                LazyVGrid(columns: layout, spacing: 20) {
                    Button(action: {
                        self.isPresented = false
                        onInfoTapped()
                    }) {
                        VStack {
                            Image("ic-info")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                .foregroundColor(.cIcon)
                            Text("envKeyInfo")
                                .foregroundColor(.cTextMedium)
                                .lineLimit(2)
                                .font(.system(size: fontSize))
                        }
                    }
                    Button(action: {
                        modalSummary = true
                    }) {
                        VStack {
                            Image("ic-summary")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                .foregroundColor(.cIcon)
                            Text("envDetail")
                                .foregroundColor(.cTextMedium)
                                .lineLimit(2)
                                .font(.system(size: fontSize))
                        }
                    }
                    .sheet(isPresented: $modalSummary) {
                        PanelSummaryView(panel: panel) {
                            modalSummary = false
                        }
                        .interactiveDismissDisabled()
                    }
                    Button(action: {
                        self.isPresented = false
                        FormEntity(objectId: panel.objectId, type: panel.type, options: [ "tab": "BASIC" ])
                            .go(path: PanelUtils.formByPanelType(panel: panel), router: viewRouter)
                    }) {
                        VStack {
                            Image("ic-edit")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                .foregroundColor(.cIcon)
                            Text("envEdit")
                                .foregroundColor(.cTextMedium)
                                .lineLimit(2)
                                .font(.system(size: fontSize))
                        }
                    }
                    Button(action: {
                        self.isPresented = false
                        onDeleteTapped()
                    }) {
                        VStack {
                            Image("ic-forbidden")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                .foregroundColor(.cIcon)
                            Text("envDeactivate")
                                .foregroundColor(.cTextMedium)
                                .lineLimit(2)
                                .font(.system(size: fontSize))
                        }
                    }
                    if panel.type == "M" {
                        if moduleCC.value == 1 {
                            Button(action: {
                                
                            }) {
                                VStack {
                                    Image("ic-send")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                        .foregroundColor(.cIcon)
                                    Text("envSendContactDetail")
                                        .foregroundColor(.cTextMedium)
                                        .lineLimit(2)
                                        .font(.system(size: fontSize))
                                }
                            }
                        }
                        Button(action: {
                            if Utils.castString(value: complementaryData["hd"]) == "Y" {
                                modalHabeasData = true
                            }
                        }) {
                            VStack {
                                Image("ic-signature")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                    .foregroundColor(.cIcon)
                                Text(Utils.castString(value: complementaryData["hd"]) == "Y" ? NSLocalizedString("envHabeasData", comment: "Habeas Data") : NSLocalizedString("envHabeasDataNR", comment: "HD not registered"))
                                    .foregroundColor(.cTextMedium)
                                    .lineLimit(2)
                                    .font(.system(size: fontSize))
                            }
                            .popover(isPresented: $modalHabeasData) {
                                ImageViewerDialog(table: "doctor", field: "habeas_data", id: panel.id, localId: panel.objectId)
                            }
                        }
                    }
                    if couldVisit {
                        Button(action: {
                            self.isPresented = false
                            FormEntity(objectId: panel.objectId, type: panel.type, options: [ "visitType": "normal" ]).go(path: "MOVEMENT-FORM", router: viewRouter)
                        }) {
                            VStack {
                                Image("ic-visit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                    .foregroundColor(.cIcon)
                                Text(visitText)
                                    .foregroundColor(.cTextMedium)
                                    .lineLimit(2)
                                    .font(.system(size: fontSize))
                            }
                        }
                    }
                    if couldVisitExtra {
                        Button(action: {
                            
                        }) {
                            VStack {
                                Image("ic-visit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                    .foregroundColor(.cIcon)
                                Text("envExtraVisit")
                                    .foregroundColor(.cTextMedium)
                                    .lineLimit(2)
                                    .font(.system(size: fontSize))
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            if panel.type == "M" && moduleTV.value == 1 {
                VStack {
                    Text("envValueTransference")
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 13))
                    LazyVGrid(columns: layout, spacing: 20) {
                        Button(action: {
                            
                        }) {
                            VStack {
                                Image("ic-tv-report")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                    .foregroundColor(.cIcon)
                                Text("envToReport")
                                    .foregroundColor(.cTextMedium)
                                    .lineLimit(2)
                                    .font(.system(size: fontSize))
                            }
                        }
                        Button(action: {
                            
                        }) {
                            VStack {
                                Image("ic-tv-signature")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                    .foregroundColor(.cIcon)
                                Text("envConsent")
                                    .foregroundColor(.cTextMedium)
                                    .lineLimit(2)
                                    .font(.system(size: fontSize))
                            }
                        }
                        if Utils.castInt(value: complementaryData["tv"]) == 1 {
                            Button(action: {
                                
                            }) {
                                VStack {
                                    Image("ic-gallery")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                        .foregroundColor(.cIcon)
                                    Text("envOpenConsent")
                                        .foregroundColor(.cTextMedium)
                                        .lineLimit(2)
                                        .font(.system(size: fontSize))
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .onAppear {
            initUI()
        }
    }
    
    func initUI() {
        self.headerColor = PanelUtils.colorByPanelType(panel: panel)
        self.headerIcon = PanelUtils.iconByPanelType(panel: panel)
        
        var couldStartVisit = false
        if reportType.value == 2 {
            if MovementUtils.existsMovementOpen(objectId: panel.objectId, type: panel.type) {
                couldVisit = true
                visitText = "envResumeVisit"
            } else {
                couldStartVisit = true
            }
        } else {
            couldStartVisit = true
        }
        if couldStartVisit {
            let couldVisitByNumber = panel.couldVisitByNumber()
            let couldVisitToday = panel.couldVisitToday()
            if couldVisitToday && couldVisitByNumber {
                couldVisit = true
                visitText = reportType.value == 2 ? NSLocalizedString("envStartVisit", comment: "Start visit") : NSLocalizedString("envVisit", comment: "Visit")
            } else {
                visitError = true
                if !couldVisitToday {
                    visitErrorText = NSLocalizedString("envVisitedToday", comment: "The panel member was visited today")
                } else if !couldVisitByNumber {
                    visitErrorText = String(format: NSLocalizedString("envMaximumVisits", comment: "Maximum visits (%@/%@)"), String(panel.mainUser()?.visitsCycle ?? 0), String(panel.mainUser()?.visitsFee ?? 0))
                } else {
                    visitErrorText = NSLocalizedString("envVisitNotAllowed", comment: "Visit not allowed")
                }
            }
        }
        
        if allowExtra.value == 1 {
            let mainUser = panel.mainUser()
            if (mainUser?.visitsCycle ?? 0) < (mainUser?.visitsFee ?? 0) {
                if extraAlwaysOn.value == 1 {
                    couldVisitExtra = true
                }
            } else {
                couldVisitExtra = true
            }
        }
    }
    
}

struct PanelMenuRequestActivation: View {
    var panel: Panel
    let onActionSelected: () -> Void
    
    @State private var headerColor = Color.cPrimary
    @State private var headerIcon = "ic-home"
    
    let layout = [
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
                    .foregroundColor(.cTextHigh)
                Image(headerIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(headerColor)
                    .frame(width: 34, height: 34, alignment: .center)
                    .padding(4)
            }
            VStack {
                LazyVGrid(columns: layout, spacing: 20) {
                    Button(action: {
                        onActionSelected()
                    }) {
                        VStack {
                            Image("ic-power-on")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                .foregroundColor(.cIcon)
                            Text("envRequestActivation")
                                .foregroundColor(.cTextMedium)
                                .lineLimit(2)
                                .font(.system(size: 15))
                        }
                    }
                }
            }
        }
        .onAppear {
            ui()
        }
    }
    
    func ui() {
        self.headerColor = PanelUtils.colorByPanelType(panel: panel)
        self.headerIcon = PanelUtils.iconByPanelType(panel: panel)
    }
    
}

struct PanelMenuRequestMove: View {
    var panel: Panel
    let onActionSelected: () -> Void
    
    @State private var headerColor = Color.cPrimary
    @State private var headerIcon = "ic-home"
    
    let layout = [
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
                    .foregroundColor(.cTextHigh)
                Image(headerIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(headerColor)
                    .frame(width: 34, height: 34, alignment: .center)
                    .padding(4)
            }
            VStack {
                LazyVGrid(columns: layout, spacing: 20) {
                    Button(action: {
                        onActionSelected()
                    }) {
                        VStack {
                            Image("ic-swap")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                .foregroundColor(.cIcon)
                            Text("envRequestMove")
                                .foregroundColor(.cTextMedium)
                                .lineLimit(2)
                                .font(.system(size: 15))
                        }
                    }
                }
            }
        }
        .onAppear {
            ui()
        }
    }
    
    func ui() {
        self.headerColor = PanelUtils.colorByPanelType(panel: panel)
        self.headerIcon = PanelUtils.iconByPanelType(panel: panel)
    }
    
}

struct GlobalMenu: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Binding var isPresented: Bool
    let onLocationTapped: () -> Void
    
    @State var usrFullName = ""
    @State var usrEmail = ""
    @State var appVersion = ""
    @State var iconSize = CGFloat(30)
    
    @State var topMenu: [Menu] = []
    @State var bottomMenu: [Menu] = []
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    userSettings.successfullLogout()
                    self.isPresented = false
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
                    self.goTo(page: "PANEL-GLOBAL-SEARCH-VIEW")
                }) {
                    Image("ic-search")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 28, alignment: .center)
                        .foregroundColor(.cPrimary)
                }
                Button(action: {
                    onLocationTapped()
                }) {
                    Image("ic-location")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 28, alignment: .center)
                        .foregroundColor(.cPrimary)
                }
                Button(action: {
                    self.goTo(page: "MASTER")
                }) {
                    Image("ic-home")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 28, alignment: .center)
                        .foregroundColor(.cPrimary)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 30, maxHeight: 30)
            .padding(.vertical, 10)
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
                ForEach(topMenu, id: \.objectId) { menu in
                    Button(action: {
                        print(menu.routerLink)
                        self.goTo(page: "\(menu.routerLink.uppercased())-VIEW", menuId: menu.id)
                    }) {
                        VStack {
                            Image(menu.icon.replacingOccurrences(of: "_", with: "-"))
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                .foregroundColor(.cPrimary)
                            Text(NSLocalizedString("env\(menu.languageTag.capitalized.replacingOccurrences(of: "-", with: ""))", comment: ""))
                                .foregroundColor(.cPrimary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            ScrollView {
                VStack {
                    ForEach(bottomMenu, id: \.objectId) { menu in
                        Button(action: {
                            print(menu.routerLink)
                            self.goTo(page: "\(menu.routerLink.uppercased())-VIEW", menuId: menu.id)
                        }) {
                            HStack {
                                Image(menu.icon.replacingOccurrences(of: "_", with: "-"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: iconSize, minHeight: iconSize, maxHeight: iconSize, alignment: .center)
                                    .foregroundColor(.cPrimary)
                                    .padding(6)
                                Text(NSLocalizedString("env\(menu.languageTag.capitalized.replacingOccurrences(of: "-", with: ""))", comment: ""))
                                    .foregroundColor(.cPrimary)
                                    .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
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
            self.usrFullName = user.name
            self.usrEmail = user.email ?? ""
            loadMenu(userType: user.type)
        }
        if let v = Utils.appVersion() {
            self.appVersion = "v. \(v)"
        }
    }
    
    func loadMenu(userType: Int) {
        let menu = MenuDao(realm: try! Realm()).by(userType: userType)
        topMenu = Array(menu[..<4])
        bottomMenu = Array(menu[4...])
    }
    
    func goTo(page: String, menuId: Int = 0) {
        viewRouter.parentMenuId = menuId
        viewRouter.currentPage = page
        self.isPresented = false
    }
}

struct PanelTypeSelectView: View {
    var types: [String]
    let onPanelTypeSelected: (_ type: String) -> Void
    
    @State private var customGridItems: [GenericGridItem] = []
    @State private var columns: [GridItem] = []
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(customGridItems, id: \.id) { item in
                    Button(action: {
                        onPanelTypeSelected(item.id)
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
        for item in types {
            customGridItems.append(GenericGridItem(id: item, color: PanelUtils.colorByPanelType(panelType: item), icon: PanelUtils.iconByPanelType(panelType: item), name: PanelUtils.titleByPanelType(panelType: item)))
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
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text(group.name)
                    .foregroundColor(.cTextHigh)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            LazyVGrid(columns: layout, spacing: 20) {
                Button(action: {
                    onEdit(group)
                }) {
                    VStack {
                        Image("ic-edit")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cIcon)
                        Text(NSLocalizedString("envEdit", comment: ""))
                            .foregroundColor(.cTextMedium)
                            .lineLimit(2)
                            .font(.system(size: CGFloat(15)))
                    }
                }
                Button(action: {
                    onDelete(group)
                }) {
                    VStack {
                        Image("ic-trash")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cIcon)
                        Text(NSLocalizedString("Delete", comment: ""))
                            .foregroundColor(.cTextMedium)
                            .lineLimit(2)
                            .font(.system(size: CGFloat(15)))
                    }
                }
            }
        }
    }
}

struct ActivityBottomMenu: View {
    let onEdit: (_ group: DifferentToVisit) -> Void
    let onDetail: (_ group: DifferentToVisit) -> Void
    
    @State var activity: DifferentToVisit
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            VStack {
                Text("envComment")
                    .foregroundColor(.cTextMedium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 13))
                Text(activity.comment)
                    .foregroundColor(.cTextHigh)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 10)
            LazyVGrid(columns: layout, spacing: 20) {
                Button(action: {
                    onDetail(activity)
                }) {
                    VStack {
                        Image("ic-summary")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cIcon)
                        Text(NSLocalizedString("envDetail", comment: ""))
                            .foregroundColor(.cTextMedium)
                            .lineLimit(2)
                            .font(.system(size: CGFloat(15)))
                    }
                }
                Button(action: {
                    onEdit(activity)
                }) {
                    VStack {
                        Image("ic-edit")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                            .foregroundColor(.cIcon)
                        Text(NSLocalizedString("envEdit", comment: ""))
                            .foregroundColor(.cTextMedium)
                            .lineLimit(2)
                            .font(.system(size: CGFloat(15)))
                    }
                }
            }
        }
    }
}

struct ExpensePhotoBottomMenu: View {
    
    let onEdit: (_ uiImage: UIImage) -> Void
    let onDelete: (_ uiImage: UIImage) -> Void
    
    var uiImage: UIImage
    
    @State var scale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            VStack {
                Image(uiImage: self.uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 200, alignment: .center)
                    .gesture(MagnificationGesture()
                        .onChanged { value in
                            self.scale = value.magnitude
                        }
                    )
                    //.clipShape(Circle())
            }
            HStack {
                Spacer()
                Button(action: {
                    onEdit(uiImage)
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
                    .padding(10)
                    .clipped()
                }
                Spacer()
                Button(action: {
                    onDelete(uiImage)
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
                    .padding(10)
                    .clipped()
                }
            }
            //.frame(height: UIScreen.main.bounds.size.height / 4)
        }
    }
}

//DEPRECATED


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
            card.color = PanelUtils.colorByPanelType(panelType: item)
            card.icon = PanelUtils.iconByPanelType(panelType: item)
            card.name = PanelUtils.titleByPanelType(panelType: item)
            customGridItems.append(card)
            if columns.count < 4 {
                columns.append(GridItem(.flexible()))
            }
        }
    }
}
