//
//  ContentView.swift
//  PRO
//
//  Created by VMO on 1/09/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import AlertToast
import RealmSwift

struct ContentView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var syncObserver = SyncObserver()
    
    var body: some View {
        VStack {
            if userSettings.loggedIn {
                switch viewRouter.currentPage {
                    case "MASTER":
                        MasterView()
                    default:
                        WrapperView()
                }
            } else {
                switch viewRouter.currentPage {
                    case "APP-MASTER":
                        MasterLoginView()
                    case "APP-MASTER-LAB":
                        MasterLaboratoryView()
                    case "AUTH-COGNITO-CONFIRM":
                        AuthCognitoConfirmView()
                    case "AUTH-RECOVER-PASSWORD":
                        AuthRecoverPasswordView()
                    default:
                        AuthSignInView()
                }
            }
        }
        .onDisappear {
            syncObserver.destroy()
        }
        .attachPartialSheetToRoot()
    }
    
    func observers() {
        /*let operationQueue = OperationQueue()
        let syncUploadOperation = SyncUploadService()
        operationQueue.addOperations([syncUploadOperation], waitUntilFinished: false)*/
    }
}

class SyncObserver {
    
    var notificationTokens = [NotificationToken]()
    
    init() {
        let realm = try! Realm()
        
        //updateCurrentOperation(key: .diary, status: 0)
        //updateCurrentOperation(key: .doctor, status: 0)
        startObserver(realm: realm, from: Diary.self, key: .diary)
        startObserver(realm: realm, from: DifferentToVisit.self, key: .activity)
        startObserver(realm: realm, from: Client.self, key: .client)
        startObserver(realm: realm, from: Doctor.self, key: .doctor)
        startObserver(realm: realm, from: Group.self, key: .group)
        startObserver(realm: realm, from: Patient.self, key: .patient)
        startObserver(realm: realm, from: Pharmacy.self, key: .pharmacy)
        startObserver(realm: realm, from: PotentialProfessional.self, key: .potential)
        
        startObserver(realm: realm, from: AgentLocation.self, key: .agentLocation)
        startObserver(realm: realm, from: FreeDayRequest.self, key: .freeDayRequest)
        startObserver(realm: realm, from: AdvertisingMaterialDelivery.self, key: .materialDelivery)
        startObserver(realm: realm, from: AdvertisingMaterialRequest.self, key: .materialRequest)
    }
    
    private func startObserver<T: Object & SyncEntity>(realm: Realm, from: T.Type, key: UploadRequestServices) {
        let results = realm.objects(from.self).where {
            $0.transactionType != ""
        }
        
        notificationTokens.append(
            results.observe { [] (changes: RealmCollectionChange) in
                switch changes {
                    case .initial:
                        print("initial", results)
                        self.doOperation(key: key)
                    case .update(_, _, _, _):
                        print("update", results)
                        self.doOperation(key: key)
                    case .error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        fatalError("\(error)")
                }
            }
        )
    }
    
    private func doOperation(key: UploadRequestServices) {
        if true /*couldStartOperation(key: key)*/ {
            print("START OPERATION -> \(key)")
            updateCurrentOperation(key: key, status: 1)
            
            DispatchQueue.global(qos: .background).async {
                let operationQueue = OperationQueue()
                let syncOperation = SyncUploadOnDemandService(service: key)
                syncOperation.completionBlock = {
                    DispatchQueue.main.async {
                        self.updateCurrentOperation(key: key, status: 0)
                    }
                }
                operationQueue.addOperations([syncOperation], waitUntilFinished: false)
            }
            
        }
    }
    
    private func couldStartOperation(key: UploadRequestServices) -> Bool {
        let realm = try! Realm()
        if let op = realm.object(ofType: CurrentOperation.self, forPrimaryKey: "upload-\(keyString(key: key))") {
            print(op)
            return op.status == 0
        }
        return true
    }
    
    private func updateCurrentOperation(key: UploadRequestServices, status: Int) {
        let realm = try! Realm()
        realm.writeAsync {
            if let op = realm.object(ofType: CurrentOperation.self, forPrimaryKey: "upload-\(self.keyString(key: key))") {
                op.status = status
            } else {
                let op = CurrentOperation()
                op.type = "upload-\(self.keyString(key: key))"
                op.status = status
                realm.create(CurrentOperation.self, value: op)
            }
        }
    }
    
    private func keyString(key: UploadRequestServices) -> String {
        switch key {
            case .activity:
                return "dtv"
            case .client:
                return "client"
            case .diary:
                return "diary"
            case .doctor:
                return "doctor"
            case .movement:
                return "movement"
            case .patient:
                return "patient"
            case .pharmacy:
                return "pharmacy"
            case .potential:
                return "potential"
            case .group:
                return "group"
            case .agentLocation:
                return "agent-location"
            case .freeDayRequest:
                return "free-day-request"
            case .materialDelivery:
                return "material-delivery"
            case .materialRequest:
                return "material-request"
        }
    }
    
    func destroy() {
        notificationTokens.forEach { nt in
            nt.invalidate()
        }
    }
    
}
