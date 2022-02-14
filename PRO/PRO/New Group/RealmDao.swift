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
    
    func next<T: Object>(from: T.Type, key: String = "id") -> Int {
        var value = 0
        if let max: Int = realm.objects(from.self).max(ofProperty: key) {
            value = max
        }
        return value < 1000000 ? 1000000 : value + 1
    }
}

class AdvertisingMaterialRequestDao: GenericDao {
    
    func store(advertisingMaterialRequest: AdvertisingMaterialRequest) {
        try! realm.write {
            realm.add(advertisingMaterialRequest, update: .all)
        }
    }
    
}

class BrickDao: GenericDao {
    
    func all() -> [Brick] {
        return Array(realm.objects(Brick.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Brick? {
        return realm.objects(Brick.self).filter("id == \(id)").first
    }
    
}

class CategoryDao: GenericDao {
    
    func all() -> [Category] {
        return Array(realm.objects(Category.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Category? {
        return realm.objects(Category.self).filter("id == \(id)").first
    }
    
}

class CityDao: GenericDao {
    
    func all() -> [City] {
        return Array(realm.objects(City.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> City? {
        return realm.objects(City.self).filter("id == \(id)").first
    }
    
}

class ClientDao: GenericDao {
    
    func all() -> [Client] {
        return Array(realm.objects(Client.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Client? {
        return realm.objects(Client.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> Client? {
        return realm.object(ofType: Client.self, forPrimaryKey: objectId)
    }
    
    func store(client: Client) {
        try! realm.write {
            realm.add(client, update: .all)
        }
    }
    
}

class CollegeDao: GenericDao {
    
    func all() -> [College] {
        return Array(realm.objects(College.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> College? {
        return realm.objects(College.self).filter("id == \(id)").first
    }
    
}

class ContactDao: GenericDao {
    
    func all() -> [Contact] {
        return Array(realm.objects(Contact.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Contact? {
        return realm.objects(Contact.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> Contact? {
        return realm.object(ofType: Contact.self, forPrimaryKey: objectId)
    }
    
    func store(contact: Contact) {
        try! realm.write {
            realm.add(contact, update: .all)
        }
    }
    
}

class CountryDao: GenericDao {
    
    func all() -> [Country] {
        return Array(realm.objects(Country.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Country? {
        return realm.objects(Country.self).filter("id == \(id)").first
    }
    
}

class CycleDao: GenericDao {
    
    func all() -> [Cycle] {
        return Array(realm.objects(Cycle.self).sorted(byKeyPath: "cycle").sorted(byKeyPath: "year"))
    }
    
    func by(id: String) -> Cycle? {
        return realm.objects(Cycle.self).filter("id == \(id)").first
    }
    
}

class FreeDayReasonDao: GenericDao {
    
    func all() -> [FreeDayReason] {
        return Array(realm.objects(FreeDayReason.self).sorted(byKeyPath: "cycle").sorted(byKeyPath: "year"))
    }
    
    func by(id: String) -> FreeDayReason? {
        return realm.objects(FreeDayReason.self).filter("id == \(id)").first
    }
    
}


class RequestDayDao: GenericDao {
    
    func all() -> [RequestDay] {
        return Array(realm.objects(RequestDay.self).sorted(byKeyPath: "id"))
    }
    
    func by(id: String) -> RequestDay? {
        return realm.objects(RequestDay.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> RequestDay? {
        return realm.object(ofType: RequestDay.self, forPrimaryKey: objectId)
    }
    
    func store(request: RequestDay) {
        try! realm.write {
            realm.add(request, update: .all)
        }
    }
    
}

class ActivityDao: GenericDao {
    
    func all() -> [Activity] {
        return Array(realm.objects(Activity.self).sorted(byKeyPath: "id"))
    }
    
    func by(id: String) -> Activity? {
        return realm.objects(Activity.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> Activity? {
        return realm.object(ofType: Activity.self, forPrimaryKey: objectId)
    }
    
    func store(activity: Activity) {
        try! realm.write {
            realm.add(activity, update: .all)
        }
    }
    
}

class ExpenseDao: GenericDao {
    
    func all() -> [Expense] {
        return Array(realm.objects(Expense.self).sorted(byKeyPath: "id"))
    }
    
    func by(id: String) -> Expense? {
        return realm.objects(Expense.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> Expense? {
        return realm.object(ofType: Expense.self, forPrimaryKey: objectId)
    }
    
    func store(expense: Expense) {
        try! realm.write {
            realm.add(expense, update: .all)
        }
    }
    
}

class DoctorDao: GenericDao {
    
    func all() -> [Doctor] {
        return Array(realm.objects(Doctor.self).sorted(byKeyPath: "lastName"))
    }
    
    func local() -> [Doctor] {
        return Array(realm.objects(Doctor.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
    }
    
    func by(id: String) -> Doctor? {
        return realm.objects(Doctor.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> Doctor? {
        return realm.object(ofType: Doctor.self, forPrimaryKey: objectId)
    }
    
    func store(doctor: Doctor) {
        try! realm.write {
            realm.add(doctor, update: .all)
        }
    }
    
}

class GroupDao: GenericDao {
    
    func all() -> [Group] {
        return Array(realm.objects(Group.self).sorted(byKeyPath: "objectId"))
    }
    
    func by(id: Int) -> Group? {
        return realm.objects(Group.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> Group? {
        return realm.object(ofType: Group.self, forPrimaryKey: objectId)
    }
    
    func store(group: Group){
        try! realm.write {
            realm.add(group, update: .all)
        }
    }
    
    func delete(group: Group) {
        try! self.realm.write {
            self.realm.delete(self.realm.object(ofType: Group.self, forPrimaryKey: group.objectId)!)
        }
    }
    
}

class GenericSelectableDao: GenericDao {
    
    func bricks() -> [GenericSelectableItem] {
        BrickDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func categories() -> [GenericSelectableItem] {
        CategoryDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func cities() -> [GenericSelectableItem] {
        CityDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func colleges() -> [GenericSelectableItem] {
        CollegeDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func countries() -> [GenericSelectableItem] {
        CountryDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func cycles() -> [GenericSelectableItem] {
        CycleDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.displayName) }
    }
    
    func lines() -> [GenericSelectableItem] {
        LineDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func materials() -> [GenericSelectableItem] {
        MaterialDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func pharmacyChains() -> [GenericSelectableItem] {
        PharmacyChainDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func pharmacyTypes() -> [GenericSelectableItem] {
        PharmacyTypeDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func pricesLists() -> [GenericSelectableItem] {
        PricesListDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func products() -> [GenericSelectableItem] {
        ProductDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func productBrands() -> [GenericSelectableItem] {
        let all = ProductDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.brand ?? "") }
        var results = [GenericSelectableItem]()
        all.forEach { item in
            if !results.contains(where: { it in
                return it.label == item.label
            }) {
                results.append(item)
            }
        }
        return results
    }
    
    func productsWithCompetitors() -> [GenericSelectableItem] {
        ProductDao(realm: self.realm).competitors().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func specialties(tp: String = "P") -> [GenericSelectableItem] {
        let items: [Specialty]
        if tp == "P" {
            items = SpecialtyDao(realm: self.realm).primary()
        } else {
            items = SpecialtyDao(realm: self.realm).secondary()
        }
        return items.map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func styles() -> [GenericSelectableItem] {
        StyleDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
    func zones() -> [GenericSelectableItem] {
        ZoneDao(realm: self.realm).all().map { GenericSelectableItem(id: "\($0.id)", label: $0.name ?? "") }
    }
    
}

class LineDao: GenericDao {
    
    func all() -> [Line] {
        return Array(realm.objects(Line.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Line? {
        return realm.objects(Line.self).filter("id == \(id)").first
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

class MediaItemDao: GenericDao {
    
    func store(mediaItem: MediaItem) {
        if let exists = realm.objects(MediaItem.self)
            .filter("table == '\(mediaItem.table)'")
            .filter("field == '\(mediaItem.field)'")
            .filter("localItem == '\(mediaItem.localItem)'")
            .first {
            try! realm.write {
                exists.date = Utils.currentDateTime()
            }
        } else {
            try! realm.write {
                realm.add(mediaItem)
            }
        }
    }
    
    func by(table: String, item: ObjectId) -> [MediaItem] {
        return Array(realm.objects(MediaItem.self).where {
            $0.table == table && $0.localItem == item.stringValue
        })
    }
    
}

class PatientDao: GenericDao {
    
    func all() -> [Patient] {
        return Array(realm.objects(Patient.self).sorted(byKeyPath: "lastName"))
    }
    
    func by(id: String) -> Patient? {
        return realm.objects(Patient.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> Patient? {
        return realm.object(ofType: Patient.self, forPrimaryKey: objectId)
    }
    
    func store(patient: Patient) {
        try! realm.write {
            realm.add(patient, update: .all)
        }
    }
    
}

class PharmacyDao: GenericDao {
    
    func all() -> [Pharmacy] {
        return Array(realm.objects(Pharmacy.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Pharmacy? {
        return realm.objects(Pharmacy.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> Pharmacy? {
        return realm.object(ofType: Pharmacy.self, forPrimaryKey: objectId)
    }
    
    func store(pharmacy: Pharmacy) {
        try! realm.write {
            realm.add(pharmacy, update: .all)
        }
    }
    
}

class PharmacyChainDao: GenericDao {
    
    func all() -> [PharmacyChain] {
        return Array(realm.objects(PharmacyChain.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> PharmacyChain? {
        return realm.objects(PharmacyChain.self).filter("id == \(id)").first
    }
    
}

class PharmacyTypeDao: GenericDao {
    
    func all() -> [PharmacyType] {
        return Array(realm.objects(PharmacyType.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> PharmacyType? {
        return realm.objects(PharmacyType.self).filter("id == \(id)").first
    }
    
}

class PotentialDao: GenericDao {
    
    func all() -> [PotentialProfessional] {
        return Array(realm.objects(PotentialProfessional.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> PotentialProfessional? {
        return realm.objects(PotentialProfessional.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> PotentialProfessional? {
        return realm.object(ofType: PotentialProfessional.self, forPrimaryKey: objectId)
    }
    
    func store(potential: PotentialProfessional) {
        try! realm.write {
            realm.add(potential, update: .all)
        }
    }
    
}

class PricesListDao: GenericDao {
    
    func all() -> [PricesList] {
        return Array(realm.objects(PricesList.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> PricesList? {
        return realm.objects(PricesList.self).filter("id == \(id)").first
    }
    
}

class ProductDao: GenericDao {
    
    func all() -> [Product] {
        return Array(realm.objects(Product.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Product? {
        return realm.objects(Product.self).filter("id == \(id)").first
    }
    
    func competitors() -> [Product] {
        return Array(realm.objects(Product.self).where {
            ($0.competitors != nil) && ($0.competitors != "")
        })
    }
    
}

class SpecialtyDao: GenericDao {
    
    func primary() -> [Specialty] {
        return Array(realm.objects(Specialty.self).filter("isPrimary == 1").sorted(byKeyPath: "name"))
    }
    
    func secondary() -> [Specialty] {
        return Array(realm.objects(Specialty.self).filter("isSecondary == 1").sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Specialty? {
        return realm.objects(Specialty.self).filter("id == \(id)").first
    }
    
}

class StyleDao: GenericDao {
    
    func all() -> [Style] {
        return Array(realm.objects(Style.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Style? {
        return realm.objects(Style.self).filter("id == \(id)").first
    }
    
}

class ZoneDao: GenericDao {
    
    func all() -> [Zone] {
        return Array(realm.objects(Zone.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Zone? {
        return realm.objects(Zone.self).filter("id == \(id)").first
    }
    
}
