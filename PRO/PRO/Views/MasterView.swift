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

struct MasterView: View {
    @EnvironmentObject var masterRouter: MasterRouter
    @EnvironmentObject var userSettings: UserSettings
    
    @State var menuIsPresented = false
    @State var searchBarOpen = false
    
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
                            Spacer()
                            Text(NSLocalizedString("env\(masterRouter.tabRight.capitalized)", comment: ""))
                            Spacer()
                        default:
                            MasterHeaderDynamicView(date: $masterRouter.date, route: $masterRouter.tabCenter, search: $masterRouter.search, searchBarOpen: $searchBarOpen)
                    }
                    if !searchBarOpen {
                        Button(action: {
                            
                        }) {
                            Image("ic-notification")
                                .resizable()
                                .foregroundColor(.cPrimary)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40, alignment: .center)
                                .padding(8)
                        }
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
        .partialSheet(isPresented: self.$menuIsPresented) {
            GlobalMenu(isPresented: self.$menuIsPresented)
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
                case "DIARY-MAP", "DIARY-LIST":
                    Button(action: {
                        self.date = Utils.addDaysToDate(days: -1, to: self.date)
                    }) {
                        Image("ic-arrow-double-left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60)
                            .padding(10)
                            .foregroundColor(.cIcon)
                    }
                    Text(Utils.dateFormat(date: self.date, format: "d MMM"))
                        .foregroundColor(.cPrimaryDark)
                        .frame(maxWidth: .infinity)
                    Button(action: {
                        self.date = Utils.addDaysToDate(days: 1, to: self.date)
                    }) {
                        Image("ic-arrow-double-right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60)
                            .padding(10)
                            .foregroundColor(.cIcon)
                    }
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
