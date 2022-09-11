//
//  SupportMainView.swift
//  PRO
//
//  Created by VMO on 8/09/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import Zip

struct SupportMainView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @ObservedObject private var moduleRouter = ModuleRouter()
    
    @State var connectionStatus: ConnectionStatus = .unknown
    @State var isSyncing: Bool = false
    
    var body: some View {
        VStack {
            if isSyncing {
                
            } else {
                HeaderToggleView(title: "modSupport")
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
    
    @State private var isSyncing: Bool = false
    @State private var modalOptions: Bool = false
    @State private var modalSync: Bool = false
    
    @ObservedResults(CurrentOperation.self) var operations
    
    var body: some View {
        VStack(spacing: 0) {
            if isSyncing {
                VStack {
                    Spacer()
                    VStack {
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
                        LottieView(name: "sync_animation", loopMode: .loop, speed: 1)
                            .frame(width: 300, height: 200)
                        Text("envSyncMessage")
                            .foregroundColor(Color.cTextHigh)
                            .font(.system(size: 14))
                    }
                    Spacer()
                }
            } else {
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
                        FAB(image: "ic-support") {
                        }
                        Spacer()
                        VStack {
                            FAB(image: "ic-sync") {
                                modalSync = true
                            }
                            FAB(image: "ic-more") {
                                modalOptions = true
                            }
                        }
                    }
                    .padding(.bottom, Globals.UI_FAB_VERTICAL)
                    .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
                }
            }
        }
        .partialSheet(isPresented: $modalOptions) {
            VStack(spacing: 20) {
                VStack {
                    Button {
                        shareData()
                    } label: {
                        Text("envShareData")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        shareMedia()
                    } label: {
                        Text("envShareMedia")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                }
                .background(Color.cBackground1dp)
                .cornerRadius(5)
                VStack {
                    Button {
                        
                    } label: {
                        Text("envDeleteData")
                            .foregroundColor(.cDanger)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                }
                .background(Color.cBackground1dp)
                .cornerRadius(5)
            }
            .padding()
        }
        .partialSheet(isPresented: $modalSync) {
            VStack(spacing: 20) {
                VStack {
                    Button {
                        syncPanels()
                    } label: {
                        Text("envDownloadPanels")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        syncDiary()
                    } label: {
                        Text("envSyncDiary")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        syncGeneralConfig()
                    } label: {
                        Text("envBasicConfiguration")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                }
                .background(Color.cBackground1dp)
                .cornerRadius(5)
            }
            .padding()
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
    
    func syncGeneralConfig() {
        modalSync = false
        isSyncing = true
        DispatchQueue.global(qos: .background).async {
            let operationQueue = OperationQueue()
            let syncOperation = SyncOnDemandGeneralConfigService()
            syncOperation.completionBlock = {
                syncGeneralConfigNested()
            }
            operationQueue.addOperations([syncOperation], waitUntilFinished: false)
        }
    }
    
    func syncGeneralConfigNested() {
        isSyncing = true
        DispatchQueue.global(qos: .background).async {
            let operationQueue = OperationQueue()
            let syncOperation = SyncOnDemandGeneralConfigNestedService()
            syncOperation.completionBlock = {
                DispatchQueue.main.async {
                    self.isSyncing = false
                }
            }
            operationQueue.addOperations([syncOperation], waitUntilFinished: false)
        }
    }
    
    func syncDiary() {
        modalSync = false
        isSyncing = true
        DispatchQueue.global(qos: .background).async {
            let operationQueue = OperationQueue()
            let syncOperation = SyncOnDemandDiaryService()
            syncOperation.completionBlock = {
                DispatchQueue.main.async {
                    self.isSyncing = false
                }
            }
            operationQueue.addOperations([syncOperation], waitUntilFinished: false)
        }
    }
    
    func syncPanels() {
        modalSync = false
        isSyncing = true
        DispatchQueue.global(qos: .background).async {
            let operationQueue = OperationQueue()
            let syncOperation = SyncOnDemandPanelsService()
            syncOperation.completionBlock = {
                DispatchQueue.main.async {
                    self.isSyncing = false
                }
            }
            operationQueue.addOperations([syncOperation], waitUntilFinished: false)
        }
    }
    
    func shareData() {
        modalOptions = false
        var lines = SyncUtils.shareData()
        doShare(type: "data", data: &lines)
    }
    
    func shareMedia() {
        modalOptions = false
        var lines = SyncUtils.shareMedia()
        doShare(type: "media", data: &lines, folder: FileUtils.folder(path: "media"))
    }
    
    func doShare(type: String, data: inout [String], folder: URL? = nil) {
        data.insert("\n", at: 0)
        data.insert("Laboratory Hash: \(UserDefaults.standard.string(forKey: Globals.LABORATORY_HASH) ?? "")", at: 0)
        data.insert("Laboratory: \(UserDefaults.standard.string(forKey: Globals.LABORATORY_PATH) ?? "")", at: 0)
        data.insert("Token: \(UserDefaults.standard.string(forKey: Globals.ACCESS_TOKEN) ?? "")", at: 0)
        data.insert("User: \(JWTUtils.sub())", at: 0)
        
        let filePath = FileUtils.sync(type: type, data: data)
        let zipFilePath = FileUtils.syncZip(type: type)
        
        do {
            var files = [URL]()
            files.append(filePath)
            if let f = folder {
                files.append(f)
            }
            try Zip.zipFiles(paths: files, zipFilePath: zipFilePath, password: "VMOnline20#22", progress: { (progress) -> () in
                print(progress)
            })
        }
        catch {
            print("ZIP Error", error)
        }
        var filesToShare = [Any]()
        filesToShare.append(zipFilePath)
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        ApplicationUtils.rootViewController()?.present(activityViewController, animated: true, completion: nil)
    }
    
    func deleteData() {
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
