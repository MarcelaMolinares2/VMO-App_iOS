//
//  ReportVisitView.swift
//  PRO
//
//  Created by VMO on 20/09/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import GoogleMaps

struct ReportVisitView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var userSelected = 0
    @State private var isProcessing = false
    @State private var modalPicker = false
    @State private var selectedDates: [String] = [Utils.dateFormat(date: Date()), Utils.dateFormat(date: Date())]
    
    @State private var movements: [MovementReport] = []
    
    let realm = try! Realm()
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "envVisitReport") {
                viewRouter.currentPage = "REPORTS-VIEW"
            }
            Button(action: {
                modalPicker = true
            }) {
                HStack {
                    Image("")
                        .resizable()
                        .foregroundColor(.cIcon)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30, alignment: .center)
                        .padding(8)
                    Spacer()
                    Text(String(format: "sepTo".localized(), Utils.dateFormat(value: selectedDates[0], toFormat: "dd MMM", fromFormat: "yyyy-MM-dd"), Utils.dateFormat(value: selectedDates[1], toFormat: "dd MMM", fromFormat: "yyyy-MM-dd")))
                        .foregroundColor(.cTextHigh)
                    Spacer()
                    Image("ic-calendar")
                        .resizable()
                        .foregroundColor(.cIcon)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30, alignment: .center)
                        .padding(8)
                }
                .padding(.horizontal, 10)
            }
            .frame(height: 44, alignment: .center)
            if isProcessing {
                VStack {
                    Spacer()
                    LottieView(name: "sync_animation", loopMode: .loop, speed: 1)
                        .frame(width: 300, height: 200)
                    Spacer()
                }
            } else {
                CustomReportListView(realm: realm, hasMap: true, userSelected: $userSelected) {
                    ForEach($movements) { $movement in
                        ReportMovementItemView(realm: realm, item: movement, userId: userSelected)
                    }
                } map: {
                    VStack {
                        ReportVisitMapView(items: $movements)
                    }
                } onAgentChanged: {
                    refresh()
                }
            }
        }
        .sheet(isPresented: $modalPicker) {
            DialogDateRangePicker(selected: $selectedDates) { _ in
                modalPicker = false
                refresh()
            }
        }
        .onAppear {
            refresh()
        }
    }

    func refresh() {
        isProcessing = true
        movements.removeAll()
        let userId = userSelected > 0 ? userSelected : JWTUtils.sub()
        AppServer().postRequest(data: [
            "dateFrom": selectedDates[0],
            "dateTo": selectedDates[1],
            "user_id": userId
        ], path: "vm/movement/mobile") { success, code, data in
            if success {
                if let rs = data as? [String] {
                    for item in rs {
                        let decoded = try! JSONDecoder().decode(MovementReport.self, from: item.data(using: .utf8)!)
                        movements.append(decoded)
                    }
                }
            }
            DispatchQueue.main.async {
                //locations.reverse()
                isProcessing = false
            }
        }
    }
}

struct ReportMovementItemView: View {
    let realm: Realm
    let item: MovementReport
    let userId: Int
    
    @State private var headerColor: Color = Color.white
    @State private var headerIcon: String = ""
    
    var body: some View {
        VStack {
            VStack {
                HStack(alignment: .top) {
                    HStack {
                        Image(headerIcon)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(headerColor)
                            .frame(width: 26, height: 26, alignment: .center)
                            .padding(4)
                        VStack {
                            Text((item.panel?.name ?? "").capitalized)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(String(format: "envMovementReportInfo".localized(), Utils.dateFormat(value: item.date, toFormat: "dd MMM yy", fromFormat: "yyyy-MM-dd"), String(item.cycle?.name ?? 0), String(item.cycle?.year ?? 0)))
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 12))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(item.executed == 1 ? item.comment : (item.comment.isEmpty ? MovementFailReasonDao(realm: realm).by(id: item.movementFailReasonId ?? 0)?.content ?? "" : item.comment))
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 13))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 5)
                    VStack(alignment: .trailing, spacing: 2) {
                        if let user = item.panel?.findUser(userId: userId) {
                            Text("\(user.visitsCycle)/\(user.visitsFee)")
                                .font(.system(size: 14))
                                .frame(width: 30, height: 20, alignment: .center)
                                .background(PanelUtils.visitsBackground(user: user))
                                .foregroundColor(.white)
                        } else {
                            Text("--/--")
                                .font(.system(size: 14))
                                .frame(width: 30, height: 20, alignment: .center)
                                .background(Color.cBackground3dp)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(minWidth: 30)
                }
                HStack {
                    Spacer()
                    Text(item.contactType)
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 18))
                    HStack {
                        ForEach(item.contactedBy.components(separatedBy: ","), id:\.self) { c in
                            Text(c)
                                .foregroundColor(.cTextMedium)
                        }
                    }
                }
            }
            .background(Color.cBackground1dp)
        }
        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
        .padding(.vertical, 5)
        .onAppear {
            self.headerColor = PanelUtils.colorByPanelType(panelType: item.panelType)
            self.headerIcon = PanelUtils.iconByPanelType(panelType: item.panelType)
        }
    }
    
}

struct ReportMovementPanelItemView: View {
    let item: MovementReport
    
    var body: some View {
        VStack {
            VStack {
                Text("")
                    .foregroundColor(.cTextMedium)
                    .font(.system(size: 14))
                Text("")
                    .foregroundColor(.cTextMedium)
                    .font(.system(size: 13))
                HStack {
                    Text(String(format: "envMovementReportInfo".localized(), Utils.dateFormat(value: item.date, toFormat: "dd MMM yy", fromFormat: "yyyy-MM-dd")))
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 12))
                    Spacer()
                    Text(item.contactType)
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 18))
                    HStack {
                        ForEach(item.contactedBy.components(separatedBy: ","), id:\.self) { c in
                            Text(c)
                        }
                    }
                }
            }
            .cornerRadius(10)
        }
        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
        .onAppear {
            
        }
    }
    
}

struct ReportVisitMapView: View {
    @Binding var items: [MovementReport]
    
    @State private var markers = [GMSMarker]()
    @State private var goToMyLocation = false
    @State private var fitToBounds = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            CustomMarkerMapView(markers: $markers, goToMyLocation: $goToMyLocation, fitToBounds: $fitToBounds) { _ in
            }
            .onAppear {
                markers.removeAll()
                items.forEach { location in
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude)))
                    //marker.title = Utils.dateFormat(value: location.date, toFormat: "dd MMM yyy - HH:mm")
                    markers.append(marker)
                }
                fitToBounds = true
            }
            VStack(spacing: 10) {
                FAB(image: "ic-my-location") {
                    goToMyLocation = true
                }
                FAB(image: "ic-bounds") {
                    fitToBounds = true
                }
            }
            .padding(.top, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
    }
    
}
