//
//  MasterView.swift
//  PRO
//
//  Created by VMO on 2/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import PartialSheet
import RealmSwift
import AlertToast

struct MasterView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var masterRouter: MasterRouter
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var menuIsPresented = false
    @State private var searchBarOpen = false
    @State private var modalAgentLocation = false
    @State private var locationSavedToast = false
    
    @ObservedResults(CurrentOperation.self) var operations
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                HStack {
                    if !searchBarOpen {
                        Button(action: {
                            self.menuIsPresented = true
                        }) {
                            Image("logo-header")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70)
                        }
                    }
                    switch masterRouter.slide {
                        case 0:
                            Spacer()
                            Text("envVisualAids")
                            Spacer()
                        case 2:
                            MasterHeaderDynamicView(date: $masterRouter.date, route: $masterRouter.tabRight, search: $masterRouter.search, searchBarOpen: $searchBarOpen)
                        default:
                            MasterHeaderDynamicView(date: $masterRouter.date, route: $masterRouter.tabCenter, search: $masterRouter.search, searchBarOpen: $searchBarOpen)
                    }
                    if !searchBarOpen {
                        HStack {
                            Spacer()
                            Button(action: {
                                viewRouter.currentPage = "NOTIFICATION-CENTER-VIEW"
                            }) {
                                Image("ic-notification")
                                    .resizable()
                                    .foregroundColor(.cPrimary)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32, alignment: .center)
                                    .padding(8)
                            }
                            .frame(width: 40, height: 40, alignment: .center)
                        }
                        .frame(width: 70)
                    }
                }
                TabView(selection: $masterRouter.slide) {
                    SLAIDPanelView()
                        .tag(0)
                    DashboardView()
                        .tag(1)
                    DashboardExtraView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            if !userSettings.initStatus {
                VStack(alignment: .center, spacing: 10) {
                    ProgressView()
                    ForEach(
                        operations.filter {
                            $0.type == "sync"
                        },
                        id: \.type
                    ) { op in
                        Text(NSLocalizedString("env\(op.current.components(separatedBy: "-").map({$0.capitalized}).joined(separator: ""))", comment: ""))
                            .foregroundColor(Color.cTextHigh)
                            .font(.system(size: 20))
                    }
                    Text("envSyncMessage")
                        .foregroundColor(Color.cTextHigh)
                        .font(.system(size: 14))
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.cSyncView)
                .onAppear {
                    
                }
            }
        }
        .sheet(isPresented: self.$menuIsPresented) {
            GlobalMenu(isPresented: self.$menuIsPresented) {
                menuIsPresented = false
                modalAgentLocation = true
            }
        }
        .partialSheet(isPresented: $modalAgentLocation) {
            AgentLocationForm() {
                modalAgentLocation = false
                locationSavedToast = true
            }
        }
        .toast(isPresenting: $locationSavedToast) {
            AlertToast(type: .complete(.cDone), title: NSLocalizedString("envSuccessfullySaved", comment: ""))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                masterRouter.slide = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    masterRouter.slide = 1
                }
            }
            doSync()
        }
        .onChange(of: masterRouter.tabRight) { newValue in
            resetHeader()
        }
        .onChange(of: masterRouter.tabCenter) { newValue in
            resetHeader()
        }
    }
    
    func doSync() {
        DispatchQueue.global(qos: .background).async {
            let operationQueue = OperationQueue()
            let syncOperation = SyncOperation()
            syncOperation.completionBlock = {
                DispatchQueue.main.async {
                    self.userSettings.toggleInit(value: true)
                }
            }
            operationQueue.addOperations([syncOperation], waitUntilFinished: false)
        }
    }
    
    func resetHeader() {
        masterRouter.search = ""
        searchBarOpen = false
    }
    
}

struct MasterHeaderDynamicView: View {
    
    @Binding var date: Date
    @Binding var route: String
    @Binding var search: String
    @Binding var searchBarOpen: Bool
    
    @State private var title = ""
    
    var body: some View {
        HStack {
            switch route {
                case "home":
                    Button(action: {
                        var dateComponent = DateComponents()
                        dateComponent.day = -1
                        date = Calendar.current.date(byAdding: dateComponent, to: date) ?? Date()
                    }) {
                        Image("ic-double-arrow-left")
                            .resizable()
                            .foregroundColor(.cIcon)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30, alignment: .center)
                            .padding(8)
                    }
                    .frame(width: 44, height: 44, alignment: .center)
                    Spacer()
                    DatePicker(selection: $date, displayedComponents: .date) {}
                        .labelsHidden()
                        .id(date)
                    Spacer()
                    Button(action: {
                        var dateComponent = DateComponents()
                        dateComponent.day = 1
                        date = Calendar.current.date(byAdding: dateComponent, to: date) ?? Date()
                    }) {
                        Image("ic-double-arrow-right")
                            .resizable()
                            .foregroundColor(.cIcon)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30, alignment: .center)
                            .padding(8)
                    }
                    .frame(width: 44, height: 44, alignment: .center)
                case "dashboard", "indicators", "birthdays":
                    Spacer()
                    Text(NSLocalizedString("env\(route.capitalized)", comment: ""))
                    Spacer()
                default:
                    if searchBarOpen {
                        SearchBar(text: $search, placeholder: Text(NSLocalizedString("envSearch", comment: "") + " " + NSLocalizedString(self.title, comment: "").lowercased())) {
                            self.searchBarOpen = false
                        }
                    } else {
                        Text(NSLocalizedString("envSearch", comment: "") + " " + NSLocalizedString(title, comment: "").lowercased())
                            .foregroundColor(.cPrimaryDark)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .onTapGesture {
                                self.searchBarOpen = true
                            }
                    }
            }
        }
        .onAppear {
            
        }
    }
    
}
