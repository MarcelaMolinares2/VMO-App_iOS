//
//  ReportLocationView.swift
//  PRO
//
//  Created by VMO on 20/09/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import GoogleMaps

struct ReportLocationView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var userSelected = 0
    @State private var isProcessing = false
    @State private var modalPicker = false
    @State private var selectedDates: [String] = [Utils.dateFormat(date: Date()), Utils.dateFormat(date: Date())]
    
    @State private var locations: [AgentLocation] = []
    
    let realm = try! Realm()
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "envLocationReport") {
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
                    ForEach($locations) { $location in
                        ReportLocationItemView(item: location)
                    }
                } map: {
                    VStack {
                        ReportLocationMapView(items: $locations)
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
        locations.removeAll()
        let userId = userSelected > 0 ? userSelected : JWTUtils.sub()
        AppServer().getRequest(path: "vm/location/by/user/\(userId)/\(selectedDates[0])/\(selectedDates[1])") { success, code, data in
            if success {
                if let rs = data as? [String] {
                    for item in rs {
                        let decoded = try! JSONDecoder().decode(AgentLocation.self, from: item.data(using: .utf8)!)
                        locations.append(decoded)
                    }
                }
            }
            DispatchQueue.main.async {
                locations.reverse()
                isProcessing = false
            }
        }
    }
}

struct ReportLocationItemView: View {
    let item: AgentLocation
    
    @State private var marker = GMSMarker()
    
    var body: some View {
        VStack {
            VStack {
                CustomMarkerStaticMapView(marker: $marker)
                    .frame(height: 150)
                HStack {
                    Spacer()
                    Text(Utils.dateFormat(value: item.date, toFormat: "dd MMM yyy - HH:mm"))
                        .foregroundColor(.cTextHigh)
                }
            }
            .cornerRadius(10)
        }
        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
        .onAppear {
            marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(item.latitude), longitude: Double(item.longitude)))
        }
    }
    
}

struct ReportLocationMapView: View {
    @Binding var items: [AgentLocation]
    
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
                    marker.title = Utils.dateFormat(value: location.date, toFormat: "dd MMM yyy - HH:mm")
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
