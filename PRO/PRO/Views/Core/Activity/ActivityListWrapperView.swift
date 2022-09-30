//
//  ActivityListView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import GoogleMaps

struct ActivityListWrapperView: View {
    @EnvironmentObject var masterRouter: MasterRouter
    
    var body: some View {
        VStack {
            HeaderToggleView(search: $masterRouter.search, title: "modActivities")
            ActivityListView()
        }
    }
}

struct ActivityMapView: View{
    
    var items: [DifferentToVisit]
    
    let onEdit: (_ activity: DifferentToVisit) -> Void
    let onDetail: (_ activity: DifferentToVisit) -> Void
    
    @State private var markers = [GMSMarker]()
    @State private var goToMyLocation = false
    @State private var fitToBounds = false
    
    @State private var menuIsPresented = false
    @State private var activityTapped: DifferentToVisit = DifferentToVisit()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            CustomMarkerMapView(markers: $markers, goToMyLocation: $goToMyLocation, fitToBounds: $fitToBounds) { marker in
                if let dtv = marker.userData as? DifferentToVisit {
                    activityTapped = dtv
                    menuIsPresented = true
                }
            }
            .onAppear {
                markers.removeAll()
                items.forEach { dtv in
                    if dtv.latitude > 0 && dtv.longitude > 0 {
                        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(dtv.latitude), longitude: Double(dtv.longitude)))
                        marker.userData = dtv
                        markers.append(marker)
                    }
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
        .sheet(isPresented: $menuIsPresented) {
            ActivityBottomMenu(onEdit: onEdit, onDetail: onDetail, activity: activityTapped)
        }
    }
}

struct ActivityListView: View{
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var masterRouter: MasterRouter
    
    @ObservedResults(DifferentToVisit.self, sortDescriptor: SortDescriptor(keyPath: "dateFrom", ascending: false)) var activities

    @State private var layout: ViewLayout = .list
    @State private var activitySelected: DifferentToVisit = DifferentToVisit()
    
    @State private var userSelected: Int = 0
    
    @State private var serverLoading = false
    @State private var serverResults = [DifferentToVisit]()
    
    @State private var selectedUser = [String]()
    @State private var modalOptions = false
    @State private var modalUserOpen = false
    @State private var modalSummary = false
    
    var realm = try! Realm()
    
    var body: some View {
        VStack {
            if let filtered = filterRs() {
                if serverLoading {
                    VStack {
                        Spacer()
                        LottieView(name: "search_animation", loopMode: .loop, speed: 1)
                            .frame(width: 300, height: 200)
                        Spacer()
                    }
                } else {
                    if userSelected > 0 {
                        HStack {
                            VStack {
                                Image("ic-user")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22, alignment: .center)
                            }
                            .frame(width: 40, height: 40, alignment: .center)
                            let user = UserDao(realm: realm).by(id: userSelected)
                            Text((user?.name ?? "").capitalized)
                                .foregroundColor(.cTextHigh)
                                .lineLimit(1)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            Button(action: {
                                userSelected = 0
                                selectedUser = []
                            }) {
                                Image("ic-close")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20, alignment: .center)
                            }
                            .frame(width: 40, height: 40, alignment: .center)
                        }
                        .frame(height: 40)
                    }
                    ZStack(alignment: .bottomTrailing) {
                        switch layout {
                            case .map:
                                ActivityMapView(items: filtered, onEdit: onEdit, onDetail: onDetail)
                            default:
                                ScrollView {
                                    ForEach (filtered, id: \.objectId) { item in
                                        ActivityItemCardView(item: item).onTapGesture {
                                            self.activitySelected = item
                                            if item.userId == JWTUtils.sub() {
                                                self.modalOptions = true
                                            } else {
                                                onDetail(item)
                                            }
                                        }
                                    }
                                    ScrollViewFABBottom()
                                }
                        }
                        HStack(alignment: .bottom) {
                            VStack {
                                if let user = UserDao(realm: realm).logged() {
                                    if !user.hierarchy.isEmpty {
                                        FAB(image: "ic-user") {
                                            modalUserOpen = true
                                        }
                                    }
                                }
                                FAB(image: (layout == .list) ? "ic-map": "ic-list") {
                                    layout = layout == .list ? .map : .list
                                }
                            }
                            Spacer()
                            FAB(image: "ic-plus") {
                                FormEntity(objectId: nil).go(path: "DTV-FORM", router: viewRouter)
                            }
                        }
                        .padding(.bottom, Globals.UI_FAB_VERTICAL)
                        .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
                    }
                }
            }
        }
        .partialSheet(isPresented: $modalOptions) {
            ActivityBottomMenu(onEdit: onEdit, onDetail: onDetail, activity: activitySelected)
        }
        .sheet(isPresented: $modalUserOpen) {
            DialogSourcePickerView(selected: $selectedUser, key: "USER-HIERARCHY", multiple: false, title: NSLocalizedString("envAgent", comment: "Agent")) { selected in
                modalUserOpen = false
                if !selected.isEmpty {
                    if userSelected != Utils.castInt(value: selected[0]) {
                        userSelected = Utils.castInt(value: selected[0])
                        onAgentChanged()
                    }
                }
            }
        }
        .sheet(isPresented: $modalSummary) {
            ActivitySummaryView(activity: $activitySelected, modalSummary: $modalSummary)
        }
    }
    
    func filterRs() -> [DifferentToVisit]? {
        var rs: [DifferentToVisit]
        if userSelected > 0 {
            rs = serverResults
        } else {
            rs = Array(activities)
        }
        if !masterRouter.search.isEmpty {
            rs = rs.filter {
                $0.comment.lowercased().contains(self.masterRouter.search.lowercased())
            }
        }
        rs.sort { d1, d2 in
            return Utils.strToDate(value: d1.dateFrom) > Utils.strToDate(value: d2.dateFrom)
        }
        return rs
    }
    
    func onAgentChanged() {
        serverLoading = true
        serverResults.removeAll()
        
        AppServer().postRequest(data: [
            "id_usuario" : userSelected
        ], path: "vm/activity/filter") { success, code, data in
            serverLoading = false
            if success {
                if let rs = data as? [String] {
                    for item in rs {
                        let decoded = try! JSONDecoder().decode(DifferentToVisit.self, from: item.data(using: .utf8)!)
                        serverResults.append(decoded)
                    }
                }
            }
            print(serverResults)
        }
    }
    
    func onEdit(_ activity: DifferentToVisit) {
        self.modalOptions = false
        FormEntity(objectId: activity.objectId).go(path: "DTV-FORM", router: viewRouter)
    }
    
    func onDetail(_ activity: DifferentToVisit) {
        self.modalOptions = false
        modalSummary = true
    }
}

struct ActivityItemCardView: View{
    var item: DifferentToVisit
    
    var body: some View {
        VStack {
            CustomCard {
                Text(item.comment)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.cTextHigh)
                    .font(.system(size: 16))
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(Utils.dateFormat(value: item.dateFrom, toFormat: "dd MMM yy")) \(NSLocalizedString("envTo", comment: "to")) \(Utils.dateFormat(value: item.dateTo, toFormat: "dd MMM yy"))")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(.cTextMedium)
                    .font(.system(size: 14))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 5)
            }
        }
        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
    }
    
}
