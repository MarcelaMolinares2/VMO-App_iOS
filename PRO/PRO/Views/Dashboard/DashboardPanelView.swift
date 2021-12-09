//
//  DashboardPanelView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import PartialSheet

struct DashboardPanelView: View {
    
    @EnvironmentObject var partialSheetManager: PartialSheetManager
    @ObservedObject var dashboardRouter = DashboardRouter()
    @StateObject var headerRouter = TabRouter()
    @State private var homeImage = "ic-map"
    @State var menuIsPresented = false
    @State private var currentDate = Date()
    @State var title = ""
    @State var searchText = ""
    
    init() {
        _homeImage = State<String>(initialValue: dashboardRouter.currentPage)
    }
    
    var body: some View {
        VStack {
            if dashboardRouter.currentPage == "MAP" {
                GoogleMapsView()
                    .edgesIgnoringSafeArea(.all)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            } else {
                HStack {
                    Button(action: {
                        self.menuIsPresented = true
                    }) {
                        Image("logo-header")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70)
                    }
                    Spacer()
                    if self.dashboardRouter.currentPage == "LIST" {
                        HStack {
                            Button(action: {
                                self.currentDate = Utils.addDaysToDate(days: -1, to: self.currentDate)
                            }) {
                                Image("ic-arrow-double-left")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60)
                                    .padding(10)
                                    .foregroundColor(.cPrimary)
                            }
                            Text(Utils.dateFormat(date: self.currentDate, format: "d MMM"))
                                .foregroundColor(.cPrimaryDark)
                                .frame(maxWidth: .infinity)
                            Button(action: {
                                self.currentDate = Utils.addDaysToDate(days: 1, to: self.currentDate)
                            }) {
                                Image("ic-arrow-double-right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60)
                                    .padding(10)
                                    .foregroundColor(.cPrimary)
                            }
                        }
                    } else {
                        HStack {
                            if headerRouter.current == "TITLE" {
                                Text(NSLocalizedString("envSearch", comment: "") + " " + NSLocalizedString(title, comment: "").lowercased())
                                    .foregroundColor(.cPrimaryDark)
                                    .multilineTextAlignment(.center)
                                    .onTapGesture {
                                        self.headerRouter.current = "SEARCH"
                                    }
                            } else {
                                SearchBar(headerRouter: self.headerRouter, text: $searchText, placeholder: Text(NSLocalizedString("envSearch", comment: "") + " " + NSLocalizedString(self.title, comment: "").lowercased()))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    Spacer()
                    if self.headerRouter.current == "TITLE" {
                        Button(action: {
                            
                        }) {
                            Image("ic-dashboard")
                                .resizable()
                                .foregroundColor(.cPrimary)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, alignment: .center)
                                .padding(6)
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: 44)
                switch dashboardRouter.currentPage {
                case "MEDIC":
                    DoctorListView(searchText: self.$searchText)
                case "CLIENT":
                    ClientListView(searchText: self.$searchText)
                case "PHARMACY":
                    PharmacyListView(searchText: self.$searchText)
                case "ACTIVITY":
                    ActivityListView(searchText: self.$searchText)
                default:
                    DiaryListTabView()
                }
            }
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Image("ic-medic")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / 5, alignment: .center)
                        .foregroundColor(self.dashboardRouter.currentPage == "MEDIC" ? .cPanelMedic : .cAccent)
                        .onTapGesture {
                            self.toTab(page: "MEDIC", title: "modMedic")
                        }
                    Image("ic-pharmacy")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / 5)
                        .foregroundColor(self.dashboardRouter.currentPage == "PHARMACY" ? .cPanelPharmacy : .cAccent)
                        .onTapGesture {
                            self.toTab(page: "PHARMACY", title: "modPharmacy")
                        }
                    ZStack {
                        Circle()
                            .foregroundColor(.cPrimary)
                            .frame(width: 58, height: 58)
                        Image(
                            self.dashboardRouter.currentPage == "LIST" ? "ic-map" : (self.dashboardRouter.currentPage == "MAP" ? "ic-diary" : "ic-home")
                        )
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(14)
                            .foregroundColor(.cIconLight)
                            .onTapGesture {
                                switch self.dashboardRouter.currentPage {
                                case "MAP":
                                    self.dashboardRouter.currentPage = "LIST"
                                case "LIST":
                                    self.dashboardRouter.currentPage = "MAP"
                                default:
                                    self.dashboardRouter.currentPage = "LIST"
                                }
                            }
                    }
                    .offset(y: -15)
                    .frame(width: geometry.size.width / 5)
                    Image("ic-client").resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / 5)
                        .foregroundColor(self.dashboardRouter.currentPage == "CLIENT" ? .cPanelClient : .cAccent)
                        .onTapGesture {
                            self.toTab(page: "CLIENT", title: "modClient")
                        }
                    Image("ic-activity").resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / 5)
                        .foregroundColor(self.dashboardRouter.currentPage == "ACTIVITY" ? .cPanelActivity : .cAccent)
                        .onTapGesture {
                            self.toTab(page: "ACTIVITY", title: "modActivity")
                        }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 46, maxHeight: 46)
        }
        .partialSheet(isPresented: self.$menuIsPresented) {
            GlobalMenu(isPresented: self.$menuIsPresented)
        }
    }
    
    func toTab(page: String, title: String) {
        self.dashboardRouter.currentPage = page
        self.title = title
        self.headerRouter.current = "TITLE"
    }
}

struct DashboardPanelView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardPanelView()
    }
}
