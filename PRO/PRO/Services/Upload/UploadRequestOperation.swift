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
    case activity, client, doctor, patient, pharmacy, potential
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
                    break
                case .client:
                    break
                case .doctor:
                    DoctorDao(realm: try! Realm()).local().forEach { doctor in
                        post(path: "doctor", data: Utils.jsonObjectArray(string: try! Utils.objToJSON(doctor)), object: Doctor(value: doctor), from: Doctor.self, table: "doctor")
                    }
                case .patient:
                    break
                case .pharmacy:
                    break
                case .potential:
                    break
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Finished all requests.")
        }
    }
    
    func post<T: Object & Codable & SyncEntity>(path: String, data: [String : Any], object: T, from: T.Type, table: String) {
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
            try! realm.write {
                object.setValue(Utils.castInt(value: data), forKey: "id")
                object.setValue("", forKey: "transactionType")
                realm.add(object, update: .modified)
            }
            let dispatchGroupMedia = DispatchGroup()
            MediaItemDao(realm: realm).by(table: table, item: object.objectId).forEach { mediaItem in
                dispatchGroupMedia.enter()
                mediaItem.id = Utils.castInt(value: data)
                print(mediaItem)
                Amplify.Storage.uploadFile(key: MediaUtils.awsPath(media: mediaItem), local: MediaUtils.mediaURL(media: mediaItem)) { (event) in
                    switch event {
                        case .success:
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
        }
    }
    
    func end(path: String = "", code: Int16 = 200, message: String = "") {
        step += 1
        upload()
    }
    
}
