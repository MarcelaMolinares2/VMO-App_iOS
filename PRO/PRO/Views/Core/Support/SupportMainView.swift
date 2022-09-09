//
//  SupportMainView.swift
//  PRO
//
//  Created by VMO on 8/09/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct SupportMainView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @ObservedObject private var moduleRouter = ModuleRouter()
    
    @State var connectionStatus: ConnectionStatus = .unknown
    @State var isSyncing: Bool = false
    
    var body: some View {
        VStack {
            if isSyncing {
                
            } else {
                HeaderToggleView(title: "modSupport") {
                    viewRouter.currentPage = "MASTER"
                }
                if connectionStatus != .unknown {
                    VStack {
                        Text((connectionStatus == .connected ? "envConnectedTS" : "errConnectionTSFailed").localized())
                            .foregroundColor(.cTextOverColor)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .center)
                    .background(connectionStatus == .connected ? Color.cDone : Color.cDanger)
                }
                switch moduleRouter.currentPage {
                    case "sync-media":
                        SupportSyncMediaView()
                    default:
                        SupportMainMenuView(moduleRouter: moduleRouter)
                }
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        AppServer().getRequest(path: "sync/ping") { success, code, data in
            connectionStatus = success ? .connected : .error
        }
    }
    
}

struct SupportMainMenuView: View {
    @ObservedObject var moduleRouter: ModuleRouter
    
    @State private var items = [SyncItem]()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                ForEach($items) { $item in
                    VStack {
                        Button(action: {
                            
                        }) {
                            HStack {
                                Image(item.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 30, minHeight: 30, maxHeight: 30, alignment: .center)
                                    .foregroundColor(.cIcon)
                                    .padding(6)
                                Text(item.label.localized())
                                    .foregroundColor(.cTextHigh)
                                    .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
                                if item.count > 0 {
                                    ZStack {
                                        Color.cWarning
                                            .frame(width: 24, height: 24, alignment: .center)
                                            .cornerRadius(6)
                                        Text("\(item.count)")
                                            .foregroundColor(.cTextOverColor)
                                    }
                                    .frame(width: 24, height: 24, alignment: .center)
                                } else {
                                    Image("ic-task")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 24, minHeight: 24, maxHeight: 24, alignment: .center)
                                        .foregroundColor(.cDone)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                    }
                    .background(Color.cBackground1dp)
                    .cornerRadius(4)
                    .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
                }
                ScrollViewFABBottom()
                ScrollViewFABBottom()
            }
            HStack(alignment: .bottom, spacing: 0) {
                FAB(image: "ic-plus") {
                }
                Spacer()
                VStack {
                    FAB(image: "ic-plus") {
                    }
                    FAB(image: "ic-plus") {
                    }
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        let realm = try! Realm()
        items.append(SyncItem(key: "media", label: "envMedia", count: SyncUtils.count(realm: realm, from: MediaItem.self), icon: "ic-gallery"))
        items.append(SyncItem(key: "visits", label: "envVisits", count: SyncUtils.count(realm: realm, from: Movement.self), icon: "ic-visit"))
        items.append(SyncItem(key: "doctors", label: "envDoctors", count: SyncUtils.count(realm: realm, from: Doctor.self), icon: "ic-doctor"))
        items.append(SyncItem(key: "pharmacies", label: "envPharmacies", count: SyncUtils.count(realm: realm, from: Pharmacy.self), icon: "ic-pharmacy"))
        items.append(SyncItem(key: "clients", label: "envClients", count: SyncUtils.count(realm: realm, from: Client.self), icon: "ic-client"))
        items.append(SyncItem(key: "patients", label: "envPatients", count: SyncUtils.count(realm: realm, from: Patient.self), icon: "ic-patient"))
        items.append(SyncItem(key: "potentials", label: "envPotentials", count: SyncUtils.count(realm: realm, from: PotentialProfessional.self), icon: "ic-potential"))
        items.append(SyncItem(key: "diary", label: "envDiary", count: SyncUtils.count(realm: realm, from: Diary.self), icon: "ic-diary"))
        items.append(SyncItem(key: "activities", label: "envActivities", count: SyncUtils.count(realm: realm, from: DifferentToVisit.self), icon: "ic-activity"))
    }
    
}

struct SupportSyncMediaView: View {
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                
            }
        }
    }
    
}

struct SyncItem: Identifiable {
    let id = UUID()
    var key: String
    var label: String
    var count: Int
    var icon: String
    
    init(key: String, label: String, count: Int, icon: String) {
        self.key = key
        self.label = label
        self.count = count
        self.icon = icon
    }
    
}
