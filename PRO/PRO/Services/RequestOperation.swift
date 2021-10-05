//
//  RequestOperation.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import BackgroundTasks
import RealmSwift

enum RequestServices {
    case brick, category, city, college, config, country, cycle, day_request_reason, pharmacy_chain, prices_list, specialty, style, user, zone,//Tertiary
         material, product, line,//Secondary
         activity, client, doctor, patient, pharmacy, potential//Primary
}

class RequestOperation: Operation {
    @objc private enum State: Int {
        case ready
        case executing
        case finished
    }
    
    var step = 0
    var fails: [String: [Int16: String]] = [:]
    
    var prefix = ""
    var services: [RequestServices] = []
    
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
        fatalError("Implement in sublcass to perform task")
    }
    
    public final func finish() {
        if isExecuting {
            state = .finished
        }
    }
    
    func getRQ<T: Object & Codable>(from: T.Type, path: String, primaryKey: String, keys: [String: String] = [String: String]()) {
        AppServer().getRequest(path: "\(prefix)/\(path)") { (successful, code, data) in
            self.handleRequest(from: from, path: path, primaryKey: primaryKey, keys: keys, successful: successful, code: code, data: data)
        }
    }
    
    func postRQ<T: Object & Codable>(from: T.Type, path: String, data: [String : Any], primaryKey: String, keys: [String: String] = [String: String]()) {
        AppServer().postRequest(data: data, path: "\(prefix)/\(path)") { (successful, code, data) in
            self.handleRequest(from: from, path: path, primaryKey: primaryKey, keys: keys, successful: successful, code: code, data: data)
        }
    }
    
    func handleRequest<T: Object & Codable>(from: T.Type, path: String, primaryKey: String, keys: [String: String], successful: Bool, code: Int16, data: Any) {
        if successful {
            let realm = try! Realm()
            do {
                // Open a thread-safe transaction.
                try realm.write {
                    if let rs = data as? [String] {
                        //print(rs)
                        for item in rs {
                            print(item)
                            let object = Utils.jsonDictionary(string: item)
                            let objectId = Utils.castInt(value: object[primaryKey])
                            if let local = realm.objects(from.self).filter("id = %@", objectId > 0 ? objectId : Utils.castString(value: object[primaryKey])).first {
                                var final = Dictionary<String, Any>()
                                let obj = Utils.jsonDictionary(string: item)
                                obj.keys.forEach { key in
                                    if let k = keys[key] {
                                        final[k] = obj[key]
                                    } else {
                                        final[key] = obj[key]
                                    }
                                }
                                let server = try JSONDecoder().decode(from.self, from: (Utils.json(from: final)?.data(using: .utf8)!)!)
                                server.setValue(local.value(forKey: "objectId"), forKey: "objectId")
                                realm.add(server, update: .modified)
                            } else {
                                let decoded = try JSONDecoder().decode(from.self, from: item.data(using: .utf8)!)
                                realm.add(decoded, update: .all)
                            }
                        }
                    }
                }
                self.end()
            } catch let error as NSError {
                print(error)
                self.end(path: path, code: -10, message: error.localizedDescription)
            }
        } else {
            print(data)
            self.end(path: path, code: code, message: data as! String)
        }
    }
    
    func get() {
        if step < services.count {
            print("\(step) -> \(services[step])")
            switch services[step] {
            case .brick:
                getRQ(from: Brick.self, path: "brick", primaryKey: Brick.primaryCodingKey())
            case .city:
                getRQ(from: City.self, path: "city", primaryKey: City.primaryCodingKey())
            case .config:
                getRQ(from: Config.self, path: "", primaryKey: Config.primaryCodingKey())
            case .country:
                getRQ(from: Country.self, path: "country", primaryKey: Country.primaryCodingKey())
            case .cycle:
                getRQ(from: Cycle.self, path: "cycle", primaryKey: Cycle.primaryCodingKey())
            case .user:
                getRQ(from: User.self, path: "user", primaryKey: User.primaryCodingKey())
            case .zone:
                getRQ(from: Zone.self, path: "zone", primaryKey: Zone.primaryCodingKey())
            case .day_request_reason:
                getRQ(from: FreeDayReason.self, path: "free-day-reason", primaryKey: FreeDayReason.primaryCodingKey())
            case .line:
                getRQ(from: Line.self, path: "line", primaryKey: Line.primaryCodingKey())
            case .material:
                postRQ(from: AdvertisingMaterial.self, path: "material/filter", data: [String: Any](), primaryKey: AdvertisingMaterial.primaryCodingKey())
            case .product:
                getRQ(from: Product.self, path: "product", primaryKey: Product.primaryCodingKey())
            case .activity:
                postRQ(from: Activity.self, path: "activity/filter", data:
                        [
                            "id_usuario" : JWTUtils.sub()
                        ], primaryKey: Activity.primaryCodingKey()
                )
            case .client:
                postRQ(from: Client.self, path: "bridge/client/filter", data:
                        [
                            "user_ids" : JWTUtils.sub()
                        ], primaryKey: Client.primaryCodingKey()
                )
            case .doctor:
                postRQ(from: Doctor.self, path: "doctor/filter", data:
                        [
                            "user_ids" : JWTUtils.sub()
                        ], primaryKey: Doctor.primaryCodingKey()
                )
            case .patient:
                postRQ(from: Patient.self, path: "patient/filter", data:
                        [
                            "user_ids" : JWTUtils.sub()
                        ], primaryKey: Patient.primaryCodingKey()
                )
            case .pharmacy:
                postRQ(from: Pharmacy.self, path: "pharmacy/filter", data:
                        [
                            "user_ids" : JWTUtils.sub()
                        ], primaryKey: Pharmacy.primaryCodingKey()
                )
            case .potential:
                postRQ(from: PotentialProfessional.self, path: "potential/filter", data:
                        [
                            "user_ids" : JWTUtils.sub()
                        ], primaryKey: PotentialProfessional.primaryCodingKey()
                )
            case .category:
                getRQ(from: Category.self, path: "panel-category", primaryKey: Category.primaryCodingKey())
            case .college:
                getRQ(from: College.self, path: "college", primaryKey: College.primaryCodingKey())
            case .pharmacy_chain:
                getRQ(from: PharmacyChain.self, path: "pharmacy-chain", primaryKey: PharmacyChain.primaryCodingKey())
            case .prices_list:
                getRQ(from: PricesList.self, path: "prices-list", primaryKey: PricesList.primaryCodingKey())
            case .specialty:
                getRQ(from: Specialty.self, path: "specialty", primaryKey: Specialty.primaryCodingKey())
            case .style:
                getRQ(from: Style.self, path: "style", primaryKey: Style.primaryCodingKey())
            }
        } else {
            debugPrint("Sync Process End")
            self.finish()
        }
    }
    
    func end(path: String = "", code: Int16 = 200, message: String = "") {
        if code != 200 {
            fails[path] = [code: message]
        }
        step += 1
        get()
    }
    
}