//
//  RealmDao.swift
//  PRO
//
//  Created by VMO on 24/08/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import Foundation
import RealmSwift

class GenericDao {
    
    var realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
    }
}

class ClientDao: GenericDao {
    
    func all() -> [Client] {
        return Array(realm.objects(Client.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Client? {
        return realm.objects(Client.self).filter("id == \(id)").first
    }
    
}

class CycleDao: GenericDao {
    
    func all() -> [Cycle] {
        return Array(realm.objects(Cycle.self).sorted(byKeyPath: "cycle").sorted(byKeyPath: "year"))
    }
    
}

class DoctorDao: GenericDao {
    
    func all() -> [Doctor] {
        return Array(realm.objects(Doctor.self).sorted(byKeyPath: "lastName"))
    }
    
    func by(id: String) -> Doctor? {
        return realm.objects(Doctor.self).filter("id == \(id)").first
    }
    
}

class MaterialDao: GenericDao {
    
    func all() -> [AdvertisingMaterial] {
        return Array(realm.objects(AdvertisingMaterial.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> AdvertisingMaterial? {
        return realm.objects(AdvertisingMaterial.self).filter("id == \(id)").first
    }
    
}

class MaterialDeliveryDao: GenericDao {
    
    @Published var updateObject: AdvertisingMaterialDelivery?
    
    func all() -> [AdvertisingMaterialDelivery] {
        return Array(realm.objects(AdvertisingMaterialDelivery.self).sorted(byKeyPath: "objectId"))
    }
    
    func by(id: String) -> AdvertisingMaterialDelivery? {
        return realm.objects(AdvertisingMaterialDelivery.self).filter("id == \(id)").first
    }
    
    func store(deliveries: [AdvertisingMaterialDelivery]){
        if realm.objects(AdvertisingMaterialDelivery.self).count == 0 {
            try! realm.write {
                realm.add(deliveries)
            }
        } else {
            try! realm.write {
                realm.add(deliveries)
            }
        }
    }
    
}

class GroupDao: GenericDao {
    
    @Published var updateObject: Group?
    
    func all() -> [Group] {
        return Array(realm.objects(Group.self).sorted(byKeyPath: "objectId"))
    }
    
    func by(id: String) -> Group? {
        return realm.objects(Group.self).filter("id == \(id)").first
    }
    
    func store(groups: [Group]){
        if realm.objects(Group.self).count == 0 {
            try! realm.write {
                realm.add(groups)
            }
        } else {
            try! realm.write {
                realm.add(groups)
            }
        }
    }
    
}

class GenericSelectableDao: GenericDao {
    
    func cycles() -> [GenericSelectableItem] {
        CycleDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.displayName) }
    }
    
    func materials() -> [GenericSelectableItem] {
        MaterialDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
}

class PatientDao: GenericDao {
    
    func all() -> [Patient] {
        return Array(realm.objects(Patient.self).sorted(byKeyPath: "lastName"))
    }
    
    func by(id: String) -> Patient? {
        return realm.objects(Patient.self).filter("id == \(id)").first
    }
    
}

class PharmacyDao: GenericDao {
    
    func all() -> [Pharmacy] {
        return Array(realm.objects(Pharmacy.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Pharmacy? {
        return realm.objects(Pharmacy.self).filter("id == \(id)").first
    }
    
}
