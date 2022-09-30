//
//  SyncRecurrentService.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import RealmSwift
import Amplify

enum UploadRequestServices {
    case activity, client, diary, doctor, group, movement, patient, pharmacy, potential
}

class UploadRequestOperation: Operation {
    @objc private enum State: Int {
        case ready
        case executing
        case finished
    }
    
    var dispatchGroup = DispatchGroup()
    var step = 0
    var fails: [String: [Int16: String]] = [:]
    
    var prefix = ""
    var services: [UploadRequestServices] = []
    
    
    private var _state = State.ready
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".op.state", attributes: .concurrent)
    
    @objc private dynamic var state: State {
        get { return stateQueue.sync { _state } }
        set { stateQueue.sync(flags: .barrier) { _state = newValue } }
    }
    
    public override var isAsynchronous: Bool { return true }
    open override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    public override var isExecuting: Bool {
        return state == .executing
    }
    
    public override var isFinished: Bool {
        return state == .finished
    }
    
    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady",  "isFinished", "isExecuting"].contains(key) {
            return [#keyPath(state)]
        }
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    public override func start() {
        if isCancelled {
            finish()
            return
        }
        self.state = .executing
        main()
    }
    
    open override func main() {
        fatalError("Implement in subclass to perform task")
    }
    
    public final func finish() {
        if isExecuting {
            state = .finished
        }
    }
    
    func upload() {
        dispatchGroup = DispatchGroup()
        
        if step < services.count {
            switch services[step] {
                case .activity:
                    ActivityDao(realm: try! Realm()).local().forEach { activity in
                        doRequest(path: "activity", data: Utils.jsonObjectArray(string: try! Utils.objToJSON(activity)), object: DifferentToVisit(value: activity), from: DifferentToVisit.self, table: "activity")
                    }
                case .client:
                    ClientDao(realm: try! Realm()).local().forEach { client in
                        doRequest(path: "client", data: Utils.jsonObjectArray(string: try! Utils.objToJSON(client)), object: Client(value: client), from: Client.self, table: "client")
                    }
                case .diary:
                    DiaryDao(realm: try! Realm()).local().forEach { diary in
                        doRequest(path: "diary", data: Utils.jsonObjectArray(string: try! Utils.objToJSON(diary)), object: Diary(value: diary), from: Diary.self, table: "diary")
                    }
                case .doctor:
                    DoctorDao(realm: try! Realm()).local().forEach { doctor in
                        doRequest(path: "doctor", data: Utils.jsonObjectArray(string: try! Utils.objToJSON(doctor)), object: Doctor(value: doctor), from: Doctor.self, table: "doctor")
                    }
                case .movement:
                    break
                case .patient:
                    PatientDao(realm: try! Realm()).local().forEach { patient in
                        doRequest(path: "patient", data: Utils.jsonObjectArray(string: try! Utils.objToJSON(patient)), object: Patient(value: patient), from: Patient.self, table: "patient")
                    }
                case .pharmacy:
                    PharmacyDao(realm: try! Realm()).local().forEach { pharmacy in
                        doRequest(path: "pharmacy", data: Utils.jsonObjectArray(string: try! Utils.objToJSON(pharmacy)), object: Pharmacy(value: pharmacy), from: Pharmacy.self, table: "pharmacy")
                    }
                case .potential:
                    PotentialDao(realm: try! Realm()).local().forEach { potential in
                        doRequest(path: "potential", data: Utils.jsonObjectArray(string: try! Utils.objToJSON(potential)), object: PotentialProfessional(value: potential), from: PotentialProfessional.self, table: "potential")
                    }
                case .group:
                    GroupDao(realm: try! Realm()).local().forEach { group in
                        doRequest(path: "group", data: Utils.jsonObjectArray(string: try! Utils.objToJSON(group)), object: Group(value: group), from: Group.self, table: "group")
                    }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Finished all requests.")
            self.finish()
        }
    }
    
    func doRequest<T: Object & Codable & SyncEntity>(path: String, data: [String : Any], object: T, from: T.Type, table: String) {
        dispatchGroup.enter()
        if object.transactionType == "CREATE" {
            AppServer().postRequest(data: data, path: "\(prefix)/\(path)") { (successful, code, data) in
                self.handleRequest(from: from, object: object, table: table, successful: successful, code: code, data: data)
            }
        } else {
            AppServer().putRequest(id: object.id, data: data, path: "\(prefix)/\(path)") { (successful, code, data) in
                self.handleRequest(from: from, object: object, table: table, successful: successful, code: code, data: data)
            }
        }
    }
    
    func handleRequest<T: Object & Codable & SyncEntity>(from: T.Type, object: T, table: String, successful: Bool, code: Int16, data: Any) {
        print(successful, code, data)
        if successful {
            let realm = try! Realm()
            var obj = realm.object(ofType: from.self, forPrimaryKey: object.objectId)
            try! realm.write {
                obj?.id = Utils.castInt(value: data)
                obj?.transactionType = ""
            }
            let dispatchGroupMedia = DispatchGroup()
            MediaItemDao(realm: realm).by(table: table, item: object.objectId).forEach { m in
                dispatchGroupMedia.enter()
                let mediaItem = MediaItem(value: m)
                mediaItem.serverId = Utils.castInt(value: data)
                Amplify.Storage.uploadFile(key: MediaUtils.awsPath(media: mediaItem), local: MediaUtils.mediaURL(media: mediaItem)) { (event) in
                    switch event {
                        case .success:
                            MediaUtils.remove(table: mediaItem.table, field: mediaItem.field, localId: mediaItem.localId)
                            print("SUCCESS / DELETE LOCAL RESOURCE")
                        case .failure:
                            print("FAILED / TRACK ERROR IN CRAHSLYTICS")
                    }
                    dispatchGroupMedia.leave()
                }
            }
            dispatchGroupMedia.notify(queue: .main) {
                self.dispatchGroup.leave()
            }
        } else {
            fails[table] = [code: data as! String]
            self.dispatchGroup.leave()
        }
    }
    
    func end(path: String = "", code: Int16 = 200, message: String = "") {
        step += 1
        upload()
    }
    
}
