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

class CycleDao: GenericDao {
    
    func all() -> [Cycle] {
        return Array(realm.objects(Cycle.self).sorted(byKeyPath: "cycle").sorted(byKeyPath: "year"))
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
        return Array(realm.objects(AdvertisingMaterialDelivery.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> AdvertisingMaterialDelivery? {
        return realm.objects(AdvertisingMaterialDelivery.self).filter("id == \(id)").first
    }
    
    func store(deliveries: [AdvertisingMaterialDelivery]){
        //realm.objects(AdvertisingMaterialDelivery.self)
        //if realm.objects(Group.self).count == 0
        if realm.objects(AdvertisingMaterialDelivery.self).count == 0{
            try! realm.write {
                realm.add(deliveries)
            }
        } else {
            try! realm.write {
                realm.add(deliveries)
            }
        }
    }
    
    /*
     fun store(vararg deliveries: AdvertisingMaterialDelivery) {
         deliveries.forEach { materialDelivery ->
             realm.executeTransaction {
                 materialDelivery.uuid = RealmUtils.nextUUID<AdvertisingMaterialDelivery>(realm)
                 materialDelivery.transactionType = "CREATE"
                 it.copyToRealmOrUpdate(materialDelivery)
             }
             realm.materialDao().updateStock(materialDelivery)
         }
     }
     */
    
}

class GenericSelectableDao: GenericDao {
    
    func cycles() -> [GenericSelectableItem] {
        CycleDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.displayName) }
    }
    
    func materials() -> [GenericSelectableItem] {
        MaterialDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
}
