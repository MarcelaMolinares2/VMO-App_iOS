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
    
    func local() -> [AdvertisingMaterialRequest] {
        return Array(realm.objects(AdvertisingMaterialRequest.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
    }
    
}

class AdvertisingMaterialDeliveryDao: GenericDao {
    
    func store(advertisingMaterialDelivery: AdvertisingMaterialDelivery) {
        try! realm.write {
            realm.add(advertisingMaterialDelivery, update: .all)
        }
    }
    
    func local() -> [AdvertisingMaterialDelivery] {
        return Array(realm.objects(AdvertisingMaterialDelivery.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
    }
    
    func updateStock(movement: Movement) {
        movement.dataMaterial.forEach { mm in
            if let material = MaterialDao(realm: realm).by(id: mm.id) {
                material.sets.forEach { materialSet in
                    let delivered = mm.sets.filter { $0.id == materialSet.id }
                    if !delivered.isEmpty {
                        try! realm.write {
                            materialSet.delivered = materialSet.delivered + delivered[0].quantity
                        }
                    }
                }
            }
        }
    }
    
    func updateStock(activity: DifferentToVisit) {
        activity.materials.forEach { mm in
            if let material = MaterialDao(realm: realm).by(id: mm.materialId) {
                material.sets.forEach { materialSet in
                    let delivered = mm.sets.filter { $0.id == materialSet.id }
                    if !delivered.isEmpty {
                        try! realm.write {
                            materialSet.delivered = materialSet.delivered + delivered[0].quantity
                        }
                    }
                }
            }
        }
    }
    
}

class AgentLocationDao: GenericDao {
    
    func all() -> [AgentLocation] {
        return Array(realm.objects(AgentLocation.self).sorted(by: \.date, ascending: false))
    }
    
    func local() -> [AgentLocation] {
        return Array(realm.objects(AgentLocation.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
    }
    
    func store(agentLocation: AgentLocation) {
        try! realm.write {
            realm.add(agentLocation, update: .all)
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
    
    func all() -> [PanelCategory] {
        return Array(realm.objects(PanelCategory.self).sorted(byKeyPath: "name"))
    }
    
    func all(categoryType: Int) -> [PanelCategory] {
        return Array(realm.objects(PanelCategory.self).filter("categoryTypeId == \(categoryType)").sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> PanelCategory? {
        return realm.objects(PanelCategory.self).filter("id == \(id)").first
    }
    
    func by(id: Int?) -> PanelCategory? {
        return by(id: String(describing: id ?? 0))
    }
    
}

class CityDao: GenericDao {
    
    func all() -> [City] {
        return Array(realm.objects(City.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> City? {
        return realm.objects(City.self).filter("id == \(id)").first
    }
    
    func by(id: Int?) -> City? {
        return by(id: String(describing: id ?? 0))
    }
    
}

class ClientDao: GenericDao {
    
    func all() -> [Client] {
        return Array(realm.objects(Client.self).sorted(byKeyPath: "name"))
    }
    
    func local() -> [Client] {
        return Array(realm.objects(Client.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
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
    
    func all() -> [PanelContact] {
        return Array(realm.objects(PanelContact.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> PanelContact? {
        return realm.objects(PanelContact.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> PanelContact? {
        return realm.object(ofType: PanelContact.self, forPrimaryKey: objectId)
    }
    
    func store(contact: PanelContact) {
        try! realm.write {
            realm.add(contact, update: .all)
        }
    }
    
}

class ContactControlTypeDao: GenericDao {
    
    func all() -> [ContactControlType] {
        return Array(realm.objects(ContactControlType.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> ContactControlType? {
        return realm.objects(ContactControlType.self).filter("id == \(id)").first
    }
    
    func by(id: Int?) -> ContactControlType? {
        return by(id: String(describing: id ?? 0))
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
    
    func by(id: Int?) -> Cycle? {
        return by(id: String(describing: id ?? 0))
    }
    
    func active() -> [Cycle] {
        if let user = UserDao(realm: realm).logged() {
            let cycles = Array(
                realm.objects(Cycle.self).where {
                    $0.isActive == "Y"
                }
            )
            
            var cyclesByCountry: [Cycle]
            let tmpByCountry = cycles.filter { $0.countryId == user.countryId }
            if tmpByCountry.isEmpty {
                cyclesByCountry = cycles
            } else {
                cyclesByCountry = tmpByCountry
            }
            
            var cyclesByLine: [Cycle]
            if (user.lineId ?? 0) > 0 {
                let tmpByLine = cycles.filter { $0.lineId == user.lineId }
                if tmpByLine.isEmpty {
                    cyclesByLine = cyclesByCountry
                } else {
                    cyclesByLine = tmpByLine
                }
            } else {
                cyclesByLine = cyclesByCountry
            }
            
            var cyclesByRegion: [Cycle] = cyclesByLine
            /*if (user.regionId ?? 0) > 0 {
                let tmpByRegion = cycles.filter { $0.regions.map { r in r.id } == user.regionId }
                if tmpByRegion.isEmpty {
                    cyclesByRegion = cyclesByLine
                } else {
                    cyclesByRegion = tmpByRegion
                }
            } else {
                cyclesByRegion = cyclesByLine
            }*/
            if !cyclesByRegion.isEmpty {
                return cyclesByRegion
            }
            return cycles
        }
        return []
    }
    /*
    fun all(context: Context): List<Cycle> {
        
        val cyclesByRegion = if ((user.regionId ?: 0) > 0) {
            val tmpByRegion =
            cyclesByLine.filter { it.regions.map { item -> item.id }.contains(user.regionId) }
            tmpByRegion.ifEmpty {
                cyclesByLine
            }
        } else {
            cyclesByLine
        }
        
        return cyclesByRegion.ifEmpty {
            cycles
        }
    }
     */
}

class DeleteDao: GenericDao {
    
    func panel(panel: Panel, reason: String) {
        let generalRequest = GeneralRequest()
        generalRequest.type = "DELETE"
        generalRequest.content = reason
        
        let generalRequestSync = GeneralRequestSyncDao()
        generalRequestSync.type = "DELETE"
        generalRequestSync.content = reason
        generalRequestSync.itemObjectId = panel.objectId
        generalRequestSync.itemId = panel.id
        generalRequestSync.itemType = panel.type
        
        try! realm.write {
            switch panel.type {
                case "M":
                    if let doctor = DoctorDao(realm: realm).by(objectId: panel.objectId) {
                        doctor.requests.append(generalRequest)
                    }
                case "F":
                    if let pharmacy = PharmacyDao(realm: realm).by(objectId: panel.objectId) {
                        pharmacy.requests.append(generalRequest)
                    }
                case "C":
                    if let client = ClientDao(realm: realm).by(objectId: panel.objectId) {
                        client.requests.append(generalRequest)
                    }
                case "P":
                    if let patient = PatientDao(realm: realm).by(objectId: panel.objectId) {
                        patient.requests.append(generalRequest)
                    }
                case "T":
                    if let potential = PotentialDao(realm: realm).by(objectId: panel.objectId) {
                        potential.requests.append(generalRequest)
                    }
                default:
                    break
            }
            
            realm.add(generalRequestSync)
        }
    }
    
}

class DiaryDao: GenericDao {
    
    func store(diary: Diary) {
        try! realm.write {
            if diary.transactionType.isEmpty {
                diary.transactionType = "UPDATE"
            }
            realm.add(diary, update: .all)
        }
    }
    
    func by(date: Date) -> [Diary] {
        return Array(
            realm.objects(Diary.self).where {
                $0.date == Utils.dateFormat(date: date)
            }
        )
    }
    
    func by(objectId: String) -> Diary? {
        return try! realm.object(ofType: Diary.self, forPrimaryKey: ObjectId(string: objectId))
    }
    
    func local() -> [Diary] {
        return Array(realm.objects(Diary.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
    }
    
}

class ExpenseReportDao: GenericDao {
    
    func store(expenseReport: ExpenseReport) {
        try! realm.write {
            realm.add(expenseReport, update: .all)
        }
    }
    
}

class FreeDayRequestDao: GenericDao {
    
    func store(freeDayRequest: FreeDayRequest) {
        try! realm.write {
            realm.add(freeDayRequest, update: .all)
        }
    }
    
    func local() -> [FreeDayRequest] {
        return Array(realm.objects(FreeDayRequest.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
    }
    
}

class FreeDayReasonDao: GenericDao {
    
    func all() -> [FreeDayReason] {
        return Array(realm.objects(FreeDayReason.self).sorted(byKeyPath: "content"))
    }
    
    func by(id: String) -> FreeDayReason? {
        return realm.objects(FreeDayReason.self).filter("id == \(id)").first
    }
    
    func by(id: Int?) -> FreeDayReason? {
        return by(id: String(describing: id ?? 0))
    }
    
}

class MenuDao: GenericDao {
    
    func all() -> [Menu] {
        return Array(realm.objects(Menu.self).sorted(byKeyPath: "name"))
    }
    
    func by(userType: Int, parent: Int = 0) -> [Menu] {
        return realm.objects(Menu.self).where {
            $0.parent == parent
        }
        .sorted(byKeyPath: "order", ascending: true)
        .filter { menu in
            menu.userTypes.components(separatedBy: ",").contains(String(userType))
        }
    }
    
}

class MovementDao: GenericDao {
    
    func all() -> [Movement] {
        return Array(realm.objects(Movement.self).sorted(byKeyPath: "date"))
    }
    
    func local() -> [Patient] {
        return Array(realm.objects(Patient.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
    }
    
    func by(date: Date) -> [Movement] {
        return Array(
            realm.objects(Movement.self)
                .where {
                    $0.date == Utils.dateFormat(date: date)
                }
                .sorted(byKeyPath: "date")
        )
    }
    
    func by(objectId: String) -> Movement? {
        if !objectId.isEmpty {
            return try! realm.object(ofType: Movement.self, forPrimaryKey: ObjectId(string: objectId))
        }
        return nil
    }
    
    func open() -> [Movement] {
        return Array(
            realm.objects(Movement.self)
                .where {
                    $0.transactionStatus == "OPEN"
                }
                .sorted(byKeyPath: "date")
        )
    }
    
    func open(panelObjectId: ObjectId, panelType: String) -> Movement? {
        return realm.objects(Movement.self).where {
            $0.panelObjectId == panelObjectId && $0.panelType == panelType && $0.transactionStatus == "OPEN"
        }
        .first
    }
    
    func store(movement: Movement) {
        try! realm.write {
            if movement.transactionType.isEmpty {
                movement.transactionType = "UPDATE"
            }
            realm.add(movement, update: .all)
        }
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
    
    func all() -> [DifferentToVisit] {
        return Array(realm.objects(DifferentToVisit.self).sorted(byKeyPath: "id"))
    }
    
    func local() -> [DifferentToVisit] {
        return Array(realm.objects(DifferentToVisit.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
    }
    
    func by(id: String) -> DifferentToVisit? {
        return realm.objects(DifferentToVisit.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> DifferentToVisit? {
        return realm.object(ofType: DifferentToVisit.self, forPrimaryKey: objectId)
    }
    
    func store(activity: DifferentToVisit) {
        try! realm.write {
            if activity.transactionType.isEmpty {
                activity.transactionType = "UPDATE"
            }
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
    
    func by(id: Int) -> Doctor? {
        return by(id: String(id))
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
    
    func local() -> [Group] {
        return Array(realm.objects(Group.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
    }
    
    func by(id: Int) -> Group? {
        return realm.objects(Group.self).filter("id == \(id)").first
    }
    
    func by(objectId: ObjectId) -> Group? {
        return realm.object(ofType: Group.self, forPrimaryKey: objectId)
    }
    
    func store(group: Group){
        try! realm.write {
            if group.transactionType.isEmpty {
                group.transactionType = "UPDATE"
            }
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
        BrickDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name ?? "") }
    }
    
    func categories() -> [GenericSelectableItem] {
        CategoryDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name ?? "") }
    }
    
    func categories(categoryType: Int) -> [GenericSelectableItem] {
        CategoryDao(realm: self.realm).all(categoryType: categoryType).map { GenericSelectableItem(value: "\($0.id)", label: $0.name ?? "") }
    }
    
    func cities() -> [GenericSelectableItem] {
        CityDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name ?? "") }
    }
    
    func colleges() -> [GenericSelectableItem] {
        CollegeDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name ?? "") }
    }
    
    func countries() -> [GenericSelectableItem] {
        CountryDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name) }
    }
    
    func cycles() -> [GenericSelectableItem] {
        CycleDao(realm: self.realm).active().map { GenericSelectableItem(value: "\($0.id)", label: $0.displayName) }
    }
    
    func expenseConcepts() -> [GenericSelectableItem] {
        ExpenseConceptDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name) }
    }
    
    func freeDayReasons() -> [GenericSelectableItem] {
        FreeDayReasonDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.content) }
    }
    
    func lines() -> [GenericSelectableItem] {
        LineDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name) }
    }
    
    func materials() -> [GenericSelectableItem] {
        MaterialDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name ?? "", complement: String(format: NSLocalizedString("envCodeArg", comment: "Code: %@"), $0.code ?? "--")) }
    }
    
    func materialsPlain() -> [GenericSelectableItem] {
        MaterialPlainDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name ?? "", complement: String(format: NSLocalizedString("envCodeArg", comment: "Code: %@"), $0.code ?? "--")) }
    }
    
    func movementFailReasons(panelType: String) -> [GenericSelectableItem] {
        MovementFailReasonDao(realm: self.realm).by(type: panelType).map { GenericSelectableItem(value: "\($0.id)", label: $0.content) }
    }
    
    func panelDeleteReasons(panelType: String) -> [GenericSelectableItem] {
        PanelDeleteReasonDao(realm: self.realm).by(panelType: panelType).map { GenericSelectableItem(value: "\($0.id)", label: $0.content) }
    }
    
    func pharmacyChains() -> [GenericSelectableItem] {
        PharmacyChainDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name ?? "") }
    }
    
    func pharmacyTypes() -> [GenericSelectableItem] {
        PharmacyTypeDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name) }
    }
    
    func predefinedComments(table: String, field: String) -> [GenericSelectableItem] {
        realm.objects(PredefinedComment.self).where {
            $0.table == table && $0.field == field
        }
        .map { GenericSelectableItem(value: "\($0.id)", label: $0.content) }
    }
    
    func pricesLists() -> [GenericSelectableItem] {
        PricesListDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name ?? "") }
    }
    
    func products() -> [GenericSelectableItem] {
        ProductDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name) }
    }
    
    func productsPromoted(pharmacyChainId: Int) -> [GenericSelectableItem] {
        if pharmacyChainId == 0 {
            return products()
        } else {
            return ProductDao(realm: self.realm).by(pharmacyChainId: pharmacyChainId).map { GenericSelectableItem(value: "\($0.id)", label: $0.name) }
        }
    }
    
    func productBrands() -> [GenericSelectableItem] {
        ProductBrandDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name) }
    }
    
    func productsWithCompetitors() -> [GenericSelectableItem] {
        ProductDao(realm: self.realm).competitors().map { GenericSelectableItem(value: "\($0.id)", label: $0.name) }
    }
    
    func specialties(tp: String = "P") -> [GenericSelectableItem] {
        let items: [Specialty]
        if tp == "P" {
            items = SpecialtyDao(realm: self.realm).primary()
        } else {
            items = SpecialtyDao(realm: self.realm).secondary()
        }
        return items.map { GenericSelectableItem(value: "\($0.id)", label: $0.name) }
    }
    
    func styles() -> [GenericSelectableItem] {
        StyleDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name) }
    }
    
    func usersInverseHierarchy() -> [GenericSelectableItem] {
        UserDao(realm: self.realm).inverseHierarchy().map { GenericSelectableItem(value: "\($0.id)", label: $0.name.capitalized) }
    }
    
    func usersHierarchy() -> [GenericSelectableItem] {
        UserDao(realm: self.realm).hierarchy().map { GenericSelectableItem(value: "\($0.id)", label: $0.name.capitalized) }
    }
    
    func zones() -> [GenericSelectableItem] {
        ZoneDao(realm: self.realm).all().map { GenericSelectableItem(value: "\($0.id)", label: $0.name ?? "") }
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
    
    func by(id: Int) -> AdvertisingMaterial? {
        return by(id: String(describing: id))
    }
    
}

class PredefinedCommentDao: GenericDao {
    
    func all() -> [PredefinedComment] {
        return Array(realm.objects(PredefinedComment.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> PredefinedComment? {
        return realm.objects(PredefinedComment.self).filter("id == \(id)").first
    }
    
    func by(id: Int) -> PredefinedComment? {
        return by(id: String(describing: id))
    }
    
}

class MovementFailReasonDao: GenericDao {
    
    func all() -> [MovementFailReason] {
        return Array(realm.objects(MovementFailReason.self).sorted(byKeyPath: "name"))
    }
    
    func by(type: String) -> [MovementFailReason] {
        return Array(
            realm
                .objects(MovementFailReason.self)
                .sorted(byKeyPath: "content")
                .filter { $0.panelType.components(separatedBy: ",").contains(type) }
        )
    }
    
    func by(id: String) -> MovementFailReason? {
        return realm.objects(MovementFailReason.self).filter("id == \(id)").first
    }
    
    func by(id: Int) -> MovementFailReason? {
        return by(id: String(describing: id))
    }
    
}

class ExpenseConceptDao: GenericDao {
    
    func all() -> [ExpenseConcept] {
        return Array(realm.objects(ExpenseConcept.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> ExpenseConcept? {
        return realm.objects(ExpenseConcept.self).filter("id == \(id)").first
    }
    
    func by(id: Int) -> ExpenseConcept? {
        return by(id: String(describing: id))
    }
    
}

class MaterialPlainDao: GenericDao {
    
    func all() -> [AdvertisingMaterialPlain] {
        return Array(realm.objects(AdvertisingMaterialPlain.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> AdvertisingMaterialPlain? {
        return realm.objects(AdvertisingMaterialPlain.self).filter("id == \(id)").first
    }
    
    func by(id: Int) -> AdvertisingMaterialPlain? {
        return by(id: String(describing: id))
    }
    
}

class MaterialSetDao: GenericDao {
    
    func by(id: String) -> AdvertisingMaterialSet? {
        return realm.objects(AdvertisingMaterialSet.self).filter("id == \(id)").first
    }
    
    func by(id: Int) -> AdvertisingMaterialSet? {
        return by(id: String(describing: id))
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
    
}

class MediaItemDao: GenericDao {
    
    func store(mediaItem: MediaItem) {
        if let exists = realm.objects(MediaItem.self).where({ q in
            q.table == mediaItem.table && q.field == mediaItem.field && q.localId == mediaItem.localId
        }).first {
            try! realm.write {
                exists.date = Utils.currentDateTime()
            }
        } else {
            try! realm.write {
                realm.add(mediaItem)
            }
        }
    }
    
    func remove(mediaItem: MediaItem) {
        if let exists = realm.objects(MediaItem.self).where({ q in
            q.table == mediaItem.table && q.field == mediaItem.field && q.localId == mediaItem.localId
        }).first {
            try! realm.write {
                realm.delete(exists)
            }
        }
    }
    
    func by(table: String, item: ObjectId) -> [MediaItem] {
        return Array(realm.objects(MediaItem.self).where {
            $0.table == table && $0.localId == item
        })
    }
    
    func by(table: String, field: String, localId: ObjectId) -> MediaItem {
        return realm.objects(MediaItem.self).where({ q in
            q.table == table && q.field == field && q.localId == localId
        }).first ?? MediaItem()
    }
    
}

class PanelDeleteReasonDao: GenericDao {
    
    func by(panelType: String) -> [PanelDeleteReason] {
        return Array(
            realm.objects(PanelDeleteReason.self).sorted(byKeyPath: "content")
        ).filter { pdr in
            pdr.panelType.components(separatedBy: ",").contains(panelType)
        }
    }
    
    func by(id: String) -> PanelDeleteReason? {
        return realm.objects(PanelDeleteReason.self).filter("id == \(id)").first
    }
    
    func by(id: Int?) -> PanelDeleteReason? {
        return by(id: String(describing: id ?? 0))
    }
    
}

class PatientDao: GenericDao {
    
    func all() -> [Patient] {
        return Array(realm.objects(Patient.self).sorted(byKeyPath: "lastName"))
    }
    
    func local() -> [Patient] {
        return Array(realm.objects(Patient.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
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
    
    func local() -> [Pharmacy] {
        return Array(realm.objects(Pharmacy.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
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
    
    func by(id: Int?) -> PharmacyChain? {
        return by(id: String(describing: id ?? 0))
    }
    
}

class PharmacyTypeDao: GenericDao {
    
    func all() -> [PharmacyType] {
        return Array(realm.objects(PharmacyType.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> PharmacyType? {
        return realm.objects(PharmacyType.self).filter("id == \(id)").first
    }
    
    func by(id: Int?) -> PharmacyType? {
        return by(id: String(describing: id ?? 0))
    }
    
}

class PotentialDao: GenericDao {
    
    func all() -> [PotentialProfessional] {
        return Array(realm.objects(PotentialProfessional.self).sorted(byKeyPath: "name"))
    }
    
    func local() -> [PotentialProfessional] {
        return Array(realm.objects(PotentialProfessional.self).where {
            ($0.transactionType != "") && ($0.transactionStatus == "")
        })
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
    
    func by(pharmacyChainId: Int) -> [Product] {
        return Array(realm.objects(Product.self).where {
            $0.pharmacyChains.pharmacyChainId == pharmacyChainId
        }.sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> Product? {
        return realm.objects(Product.self).filter("id == \(id)").first
    }
    
    func by(id: Int?) -> Product? {
        return by(id: String(describing: id ?? 0))
    }
    
    func competitors() -> [Product] {
        return Array(realm.objects(Product.self).where {
            ($0.competitors != nil) && ($0.competitors != "")
        })
    }
    
}

class ProductBrandDao: GenericDao {
    
    func all() -> [ProductBrand] {
        return Array(realm.objects(ProductBrand.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: String) -> ProductBrand? {
        return realm.objects(ProductBrand.self).filter("id == \(id)").first
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
    
    func by(id: Int?) -> Specialty? {
        return by(id: String(describing: id ?? 0))
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

class UserDao: GenericDao {
    
    func all() -> [User] {
        return Array(realm.objects(User.self).sorted(byKeyPath: "name"))
    }
    
    func by(id: Int) -> User? {
        return realm.objects(User.self).filter("id == \(id)").first
    }
    
    func by(id: String) -> User? {
        return realm.objects(User.self).filter("id == \(id)").first
    }
    
    func inverseHierarchy() -> [User] {
        return Array(
            realm.objects(User.self).where {
                $0.hierarchy.userId == logged()?.id ?? 0
            }.sorted(byKeyPath: "name")
        )
    }
    
    func hierarchy() -> [User] {
        let usersHierarchy = logged()?.hierarchy.map { $0.userId } ?? []
        return Array(realm.objects(User.self).where {
            $0.id.in(usersHierarchy)
        }.sorted(byKeyPath: "name"))
    }
    
    func logged() -> User? {
        return by(id: JWTUtils.sub())
    }
    
}

class UserPreferenceDao: GenericDao {
    
    func all() -> [UserPreference] {
        return Array(realm.objects(UserPreference.self))
    }
    
    func by(module: String) -> [UserPreference] {
        return Array(
            realm.objects(UserPreference.self).where {
                $0.module == module
            }
        )
    }
    
    func update(module: String, key: String, value: String, onSaveDone: @escaping () -> Void) {
        let preferences = realm.objects(UserPreference.self).where {
            $0.module == module && $0.type == key
        }
        if let preference = preferences.first {
            try! realm.write {
                preference.value = value
                DispatchQueue.main.async {
                    onSaveDone()
                }
            }
        }
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
