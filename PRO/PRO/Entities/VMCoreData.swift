//
//  VMCoreData.swift
//  PRO
//
//  Created by VMO on 2/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//


import Foundation
import RealmSwift


class AgentLocation: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    @Persisted var userId: Int = 0
    @Persisted var date: String = ""
    @Persisted var latitude: Float = 0
    @Persisted var longitude: Float = 0
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_ubicacion", userId = "id_usuario", date = "fecha", latitude = "latitud", longitude = "longitud"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(date, forKey: .date)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

class AdvertisingMaterialDelivery: Object, Encodable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    @Persisted var transaction: String = "D"
    @Persisted var deliveredFrom: Int = 0
    @Persisted var date: String = ""
    @Persisted var comment: String = ""
    @Persisted var materials = List<AdvertisingMaterialDeliveryMaterial>()
    
    private enum EncodingKeys: String, CodingKey {
        case transaction = "transaction_type", deliveredFrom = "delivered_from", date = "date_time", comment = "observations", materials
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(transaction, forKey: .transaction)
        try container.encode(deliveredFrom, forKey: .deliveredFrom)
        try container.encode(date, forKey: .date)
        try container.encode(comment, forKey: .comment)
        try container.encode(materials, forKey: .materials)
    }
}

class AdvertisingMaterialDeliveryMaterial: Object, Encodable, Identifiable {
    @Persisted var materialId: Int = 0
    @Persisted var materialCategoryId: Int = 0
    @Persisted var sets = List<AdvertisingMaterialDeliveryMaterialSet>()
    //var set: AdvertisingMaterialSet = AdvertisingMaterialSet()
    
    private enum EncodingKeys: String, CodingKey {
        case materialId = "material_id", materialCategoryId = "material_category_id", sets
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(materialId, forKey: .materialId)
        try container.encode(materialCategoryId, forKey: .materialCategoryId)
        try container.encode(sets, forKey: .sets)
    }
}

class AdvertisingMaterialDeliveryMaterialSet: Object, Encodable {
    @Persisted var id: Int = 0
    @Persisted var quantity: Int = 0
    @Persisted var operationType: String = "O"
    @Persisted var deliveredTo: Int = 0
    
    private enum EncodingKeys: String, CodingKey {
        case id, quantity, operationType = "operation_type", deliveredTo = "delivered_to"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(operationType, forKey: .operationType)
        try container.encode(deliveredTo, forKey: .deliveredTo)
    }
}

class AdvertisingMaterialRequest: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    @Persisted var date: String = ""
    @Persisted var details = List<AdvertisingMaterialRequestDetail>()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id, date = "fecha_solicitud", details
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(details, forKey: .details)
    }
}

class AdvertisingMaterialRequestDetail: Object, Encodable {
    @Persisted var materialId = 0
    @Persisted var quantity: Int = 0
    @Persisted var comment: String = ""
    
    private enum EncodingKeys: String, CodingKey {
        case materialId = "id", quantity, comment
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(materialId, forKey: .materialId)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(comment, forKey: .comment)
    }
}

class DifferentToVisit: Object, Codable, SyncEntity, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var cycleId: Int = 0
    @Persisted var userId: Int = 0
    @Persisted var diaryId: Int = 0
    @Persisted var eventId: Int = 0
    @Persisted var comment: String = ""
    @Persisted var dateFrom: String = ""
    @Persisted var dateTo: String = ""
    @Persisted var hourFrom: String = ""
    @Persisted var hourTo: String = ""
    @Persisted var latitude: Float = 0
    @Persisted var longitude: Float = 0
    @Persisted var requestFreeDay: Int = 0
    @Persisted var fields: String = ""
    @Persisted var materials = List<DifferentToVisitMaterial>()
    @Persisted var assistants = List<DifferentToVisitAssistant>()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_actividad", cycleId = "ciclo", userId = "id_usuario", diaryId = "id_agenda", eventId = "id_evento", comment = "descripcion", dateFrom = "fecha_inicial", dateTo = "fecha_final", hourFrom = "hora_inicial", hourTo = "hora_final", latitude = "latitud", longitude = "longitud", requestFreeDay = "solicitar_dias_autorizados", fields, materials, assistants
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.cycleId = try DynamicUtils.intTypeDecoding(container: container, key: .cycleId)
        self.userId = try DynamicUtils.intTypeDecoding(container: container, key: .userId)
        self.diaryId = try DynamicUtils.intTypeDecoding(container: container, key: .diaryId)
        self.eventId = try DynamicUtils.intTypeDecoding(container: container, key: .eventId)
        self.comment = try DynamicUtils.stringTypeDecoding(container: container, key: .comment)
        self.dateFrom = try DynamicUtils.stringTypeDecoding(container: container, key: .dateFrom)
        self.dateTo = try DynamicUtils.stringTypeDecoding(container: container, key: .dateTo)
        self.hourFrom = try DynamicUtils.stringTypeDecoding(container: container, key: .hourFrom)
        self.hourTo = try DynamicUtils.stringTypeDecoding(container: container, key: .hourTo)
        self.latitude = try DynamicUtils.floatTypeDecoding(container: container, key: .latitude)
        self.longitude = try DynamicUtils.floatTypeDecoding(container: container, key: .longitude)
        self.requestFreeDay = try DynamicUtils.intTypeDecoding(container: container, key: .requestFreeDay)
        self.fields = try DynamicUtils.adFieldsTypeDecoding(container: container, key: .fields)
        
        self.materials = try DynamicUtils.listTypeDecoding(container: container, key: .materials)
        self.assistants = try DynamicUtils.listTypeDecoding(container: container, key: .assistants)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_actividad", cycleId = "ciclo", userId = "id_usuario", diaryId = "id_agenda", eventId = "id_evento", comment = "descripcion", dateFrom = "fecha_inicial", dateTo = "fecha_final", hourFrom = "hora_inicial", hourTo = "hora_final", latitude = "latitud", longitude = "longitud", requestFreeDay = "solicitar_dias_autorizados", fields, materials, assistants
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(cycleId, forKey: .cycleId)
        try container.encode(userId, forKey: .userId)
        try container.encode(diaryId, forKey: .diaryId)
        try container.encode(eventId, forKey: .eventId)
        try container.encode(comment, forKey: .comment)
        try container.encode(dateFrom, forKey: .dateFrom)
        try container.encode(dateTo, forKey: .dateTo)
        try container.encode(hourFrom, forKey: .hourFrom)
        try container.encode(hourTo, forKey: .hourTo)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(requestFreeDay, forKey: .requestFreeDay)
        try container.encode(fields, forKey: .fields)
        try container.encode(materials, forKey: .materials)
        try container.encode(assistants, forKey: .assistants)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}

class DifferentToVisitMaterial: Object, Codable {
    @Persisted var materialId: Int = 0
    @Persisted var materialCategoryId: Int = 0
    @Persisted var sets = List<DifferentToVisitMaterialSet>()
    
    private enum CodingKeys: String, CodingKey {
        case materialId = "material_id", materialCategoryId = "material_category_id", sets
    }
    
    private enum EncodingKeys: String, CodingKey {
        case materialId = "material_id", materialCategoryId = "material_category_id", sets
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(materialId, forKey: .materialId)
        try container.encode(materialCategoryId, forKey: .materialCategoryId)
        try container.encode(sets, forKey: .sets)
    }
    
}

class DifferentToVisitMaterialSet: Object, Codable {
    @Persisted var id: Int = 0
    @Persisted var quantity: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case id, quantity
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id, quantity
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(quantity, forKey: .quantity)
    }
    
}

class DifferentToVisitAssistant: Object, Codable {
    @Persisted var panelObjectId: ObjectId
    @Persisted var panelId: Int = 0
    @Persisted var panelType: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case panelId = "panel_id", panelType = "panel_type"
    }
    
    private enum EncodingKeys: String, CodingKey {
        case panelId = "panel_id", panelType = "panel_type"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(panelId, forKey: .panelId)
        try container.encode(panelType, forKey: .panelType)
    }
    
}

protocol SyncEntity {
    var objectId: ObjectId { get set }
    var id: Int { get set }
    var transactionStatus: String { get set }
    var transactionType: String { get set }
    var transactionResponse: String { get set }
}

protocol Panel {
    var objectId: ObjectId { get set }
    var id: Int { get set }
    var idNumber: String { get set }
    var type: String { get set }
    var name: String? { get set }
    var email: String? { get set }
    var createdAt: String { get set }
    
    var phone: String? { get set }
    var fields: String { get set }
    
    var brickId: Int? { get set }
    var cityId: Int { get set }
    var countryId: Int? { get set }
    var pricesListId: Int? { get set }
    var zoneId: Int? { get set }
    
    var visitFTF: Int? { get set }
    var visitVirtual: Int? { get set }
    
    var isSelected: Bool { get set }
    var visitsFeeWasEdited: Bool { get set }
    
    var lastMovement: MovementSummarized? { get set }
    var lastMove: PanelMove? { get set }
    var categories: List<PanelCategoryPanel> { get set }
    var contactControl: List<ContactControlPanel> { get set }
    var visitingHours: List<PanelVisitingHour> { get set }
    var locations: List<PanelLocation> { get set }
    var requests: List<GeneralRequest> { get set }
    var users: List<PanelUser> { get set }
    var visitDates: List<PanelVisitedOn> { get set }
}

extension Panel {
    
    func cityName(realm: Realm) -> String {
        if let location = mainLocation() {
            if let city = CityDao(realm: realm).by(id: location.cityId) {
                return city.name ?? ""
            }
        }
        return ""
    }
    
    func coverage(userId: Int) -> Float {
        if let user = findUser(userId: userId <= 0 ? JWTUtils.sub() : userId) {
            if user.visitsFee <= 0 {
                return 0
            }
            return Float(((user.visitsCycle * 100) / user.visitsFee))
        }
        return 0
    }
    
    func mainLocation() -> PanelLocation? {
        if !locations.isEmpty {
            let main = locations.filter { location in
                location.type == "DEFAULT"
            }
            return main.isEmpty ? locations.first : main.first
        }
        return nil
    }
    
    func mainCategory(realm: Realm, defaultValue: String = "") -> String {
        if categories.isEmpty {
            return defaultValue
        }
        if let category = CategoryDao(realm: realm).by(id: categories.first?.categoryId) {
            return category.name ?? defaultValue
        }
        return defaultValue
    }
    
    func findUser(userId: Int) -> PanelUser? {
        return users.first { panelUser in
            panelUser.userId == userId
        }
    }
    
    func mainUser() -> PanelUser? {
        return findUser(userId: JWTUtils.sub())
    }
    
    func visitsInCycle() -> Int? {
        if let user = mainUser() {
            return user.visitsCycle
        }
        return nil
    }
    
    func hasDeleteRequest() -> Bool {
        return !requests.filter { gr in
            return gr.type == "DELETE"
        }.isEmpty
    }
    
    func couldVisitByNumber() -> Bool {
        if let mainUser = mainUser() {
            if mainUser.visitsCycle >= mainUser.visitsFee {
                var restrict = true
                switch type {
                    case "M":
                        restrict = Config.get(key: "MOV_RES_NUM_MED").value == 1
                    case "F":
                        restrict = Config.get(key: "MOV_RES_NUM_FAR").value == 1
                    case "C":
                        restrict = Config.get(key: "MOV_RES_NUM_CLI").value == 1
                    case "P":
                        restrict = Config.get(key: "MOV_RES_NUM_PAT").value == 1
                    default:
                        break
                }
                return !restrict
            }
            return true
        }
        return false
    }
    
    func couldVisitToday() -> Bool {
        if visitDates.map({ $0.date }).contains(Utils.currentDate()) {
            var restrict = true
            switch type {
                case "M":
                    restrict = Config.get(key: "MOV_RES_DAY_MED").value == 1
                case "F":
                    restrict = Config.get(key: "MOV_RES_DAY_FAR").value == 1
                case "C":
                    restrict = Config.get(key: "MOV_RES_DAY_CLI").value == 1
                case "P":
                    restrict = Config.get(key: "MOV_RES_DAY_PAT").value == 1
                default:
                    break
            }
            return !restrict
        }
        return true
    }
    
}

class GenericPanel: Panel, SyncEntity {
    var type: String = ""
    var email: String?
    var phone: String?
    var brickId: Int?
    var countryId: Int?
    var pricesListId: Int?
    var zoneId: Int?
    var visitFTF: Int?
    var visitVirtual: Int?
    var idNumber: String = ""
    var name: String? = ""
    var createdAt: String = ""
    var fields: String = ""
    var cityId: Int = 0
    var isSelected: Bool = false
    var visitsFeeWasEdited: Bool = false
    var lastMove: PanelMove?
    var lastMovement: MovementSummarized?
    var visitingHours: List<PanelVisitingHour> = List<PanelVisitingHour>()
    var locations: List<PanelLocation> = List<PanelLocation>()
    var categories: List<PanelCategoryPanel> = List<PanelCategoryPanel>()
    var contactControl: List<ContactControlPanel> = List<ContactControlPanel>()
    var requests: List<GeneralRequest> = List<GeneralRequest>()
    var users: List<PanelUser> = List<PanelUser>()
    var visitDates: List<PanelVisitedOn> = List<PanelVisitedOn>()
    var objectId: ObjectId = ObjectId()
    var id: Int = 0
    var transactionStatus: String = ""
    var transactionType: String = ""
    var transactionResponse: String = ""
    
}



class Client: Object, Codable, Panel, SyncEntity, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var idNumber: String = ""
    @Persisted var type: String = "C"
    @Persisted var name: String? = ""
    @Persisted var email: String? = ""
    @Persisted var createdAt: String = ""
    @Persisted var phone: String? = ""
    @Persisted var fields: String = ""
    
    @Persisted var brickId: Int?
    @Persisted var cityId: Int = 0
    @Persisted var countryId: Int?
    @Persisted var pricesListId: Int?
    @Persisted var zoneId: Int?
    @Persisted var visitFTF: Int?
    @Persisted var visitVirtual: Int?
    @Persisted var visitsFeeWasEdited: Bool = false
    var isSelected: Bool = false

    @Persisted var lastMove: PanelMove?
    @Persisted var lastMovement: MovementSummarized?
    @Persisted var visitingHours: List<PanelVisitingHour> = List<PanelVisitingHour>()
    @Persisted var locations: List<PanelLocation> = List<PanelLocation>()
    @Persisted var categories: List<PanelCategoryPanel> = List<PanelCategoryPanel>()
    @Persisted var contactControl: List<ContactControlPanel> = List<ContactControlPanel>()
    @Persisted var requests: List<GeneralRequest> = List<GeneralRequest>()
    @Persisted var users: List<PanelUser> = List<PanelUser>()
    @Persisted var visitDates: List<PanelVisitedOn> = List<PanelVisitedOn>()
    
    @Persisted var contacts: List<PanelContact> = List<PanelContact>()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_cliente", idNumber = "nit", name = "nombre", email = "email", createdAt = "created_at", phone = "telefono", fields, brickId = "id_brick", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", visitsFeeWasEdited = "visits_fee_was_edited", lastMove = "last_move", lastMovement = "last_movement", visitingHours = "visiting_hours", locations, categories, contactControl = "contact_control", requests = "general_requests", users = "panel_user", visitDates = "visited_on", contacts
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.idNumber = try DynamicUtils.stringTypeDecoding(container: container, key: .idNumber)
        self.name = try DynamicUtils.stringTypeDecoding(container: container, key: .name)
        self.email = try DynamicUtils.stringTypeDecoding(container: container, key: .email)
        self.createdAt = try DynamicUtils.stringTypeDecoding(container: container, key: .createdAt)
        self.phone = try DynamicUtils.stringTypeDecoding(container: container, key: .phone)
        self.fields = try DynamicUtils.adFieldsTypeDecoding(container: container, key: .fields)
        self.brickId = try DynamicUtils.intTypeDecoding(container: container, key: .brickId)
        self.cityId = try DynamicUtils.intTypeDecoding(container: container, key: .cityId)
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.pricesListId = try DynamicUtils.intTypeDecoding(container: container, key: .pricesListId)
        self.zoneId = try DynamicUtils.intTypeDecoding(container: container, key: .zoneId)
        self.visitFTF = try DynamicUtils.intTypeDecoding(container: container, key: .visitFTF)
        self.visitVirtual = try DynamicUtils.intTypeDecoding(container: container, key: .visitVirtual)
        self.visitsFeeWasEdited = try DynamicUtils.boolTypeDecoding(container: container, key: .visitsFeeWasEdited)
        self.lastMove = try DynamicUtils.objectTypeDecoding(container: container, key: .lastMove)
        self.lastMovement = try DynamicUtils.objectTypeDecoding(container: container, key: .lastMovement)
        self.visitingHours = try DynamicUtils.listTypeDecoding(container: container, key: .visitingHours)
        self.locations = try DynamicUtils.listTypeDecoding(container: container, key: .locations)
        self.categories = try DynamicUtils.listTypeDecoding(container: container, key: .categories)
        self.contactControl = try DynamicUtils.listTypeDecoding(container: container, key: .contactControl)
        self.requests = try DynamicUtils.listTypeDecoding(container: container, key: .requests)
        self.users = try DynamicUtils.listTypeDecoding(container: container, key: .users)
        self.visitDates = try DynamicUtils.listTypeDecoding(container: container, key: .visitDates)
        
        self.contacts = try DynamicUtils.listTypeDecoding(container: container, key: .contacts)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_cliente", idNumber = "nit", name = "nombre", email = "email", createdAt = "created_at", phone = "telefono", fields, brickId = "id_brick", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", lastMove = "last_move", lastMovement = "last_movement", visitingHours = "visiting_hours", locations, categories, contactControl = "contact_control", requests = "general_requests", users = "panel_user", visitDates = "visited_on", contacts
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(idNumber, forKey: .idNumber)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(phone, forKey: .phone)
        try container.encode(fields, forKey: .fields)
        try container.encode(brickId, forKey: .brickId)
        try container.encode(cityId, forKey: .cityId)
        try container.encode(countryId, forKey: .countryId)
        try container.encode(pricesListId, forKey: .pricesListId)
        try container.encode(zoneId, forKey: .zoneId)
        try container.encode(visitFTF, forKey: .visitFTF)
        try container.encode(visitVirtual, forKey: .visitVirtual)
        try container.encode(visitingHours, forKey: .visitingHours)
        try container.encode(locations, forKey: .locations)
        try container.encode(categories, forKey: .categories)
        try container.encode(contactControl, forKey: .contactControl)
        try container.encode(requests, forKey: .requests)
        
        try container.encode(contacts, forKey: .contacts)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
    static func classKeys() -> [String: String] {
        return ["id" : "id_cliente", "idNumber" : "nit", "name" : "nombre", "email" : "email", "createdAt" : "created_at", "phone" : "telefono", "fields, brickId" : "id_brick", "cityId" : "id_ciudad", "countryId" : "id_pais", "pricesListId" : "id_lista_precios", "zoneId" : "id_zona", "visitFTF" : "visit_ftf", "visitVirtual" : "visit_virtual", "lastMove" : "last_move", "lastMovement" : "last_movement", "visitingHours" : "visiting_hours", "locations, categories, contactControl" : "contact_control", "requests" : "general_requests", "users" : "panel_user", "visitDates" : "visited_on"]
    }
    
}

class PanelContact: Object, Codable, Panel, SyncEntity, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var idNumber: String = ""
    @Persisted var type: String = "CT"
    @Persisted var name: String? = ""
    @Persisted var email: String? = ""
    @Persisted var createdAt: String = ""
    @Persisted var phone: String? = ""
    @Persisted var fields: String = ""
    
    @Persisted var brickId: Int?
    @Persisted var cityId: Int = 0
    @Persisted var countryId: Int?
    @Persisted var pricesListId: Int?
    @Persisted var zoneId: Int?
    @Persisted var visitFTF: Int?
    @Persisted var visitVirtual: Int?
    @Persisted var visitsFeeWasEdited: Bool = false
    var isSelected: Bool = false
    
    @Persisted var lastMove: PanelMove?
    @Persisted var lastMovement: MovementSummarized?
    @Persisted var visitingHours: List<PanelVisitingHour> = List<PanelVisitingHour>()
    @Persisted var locations: List<PanelLocation> = List<PanelLocation>()
    @Persisted var categories: List<PanelCategoryPanel> = List<PanelCategoryPanel>()
    @Persisted var contactControl: List<ContactControlPanel> = List<ContactControlPanel>()
    @Persisted var requests: List<GeneralRequest> = List<GeneralRequest>()
    @Persisted var users: List<PanelUser> = List<PanelUser>()
    @Persisted var visitDates: List<PanelVisitedOn> = List<PanelVisitedOn>()
    
    
    @Persisted var panelObjectId: ObjectId?
    @Persisted var panelId: Int = 0
    @Persisted var panelType: String = ""
    @Persisted var documentType: String? = ""
    @Persisted var gender: String? = ""
    @Persisted var position: String? = ""
    @Persisted var profession: String? = ""
    @Persisted var address: String? = ""
    @Persisted var mobilePhone: String? = ""
    @Persisted var joinDate: String? = ""
    @Persisted var ext: String? = ""
    @Persisted var habeasData: String? = ""
    @Persisted var birthDate: String? = ""
    
    @Persisted var specialtyId: Int? = 0
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_contacto", idNumber = "cedula", name = "nombres", email = "email", createdAt = "created_at", phone = "telefono", fields, brickId = "id_brick", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", visitsFeeWasEdited = "visits_fee_was_edited", lastMove = "last_move", lastMovement = "last_movement", visitingHours = "visiting_hours", locations, categories, contactControl = "contact_control", requests = "general_requests", users = "panel_user", visitDates = "visited_on", panelId = "id_panel", panelType = "tipo_panel", documentType = "tipo_documento", gender = "sexo", position = "cargo", profession = "profesion", address = "direccion", mobilePhone = "celular", joinDate = "fecha_ingreso", ext = "extension", habeasData = "habeas_data", birthDate = "md_cumpleanos", specialtyId = "id_especialidad"
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.idNumber = try DynamicUtils.stringTypeDecoding(container: container, key: .idNumber)
        self.email = try DynamicUtils.stringTypeDecoding(container: container, key: .email)
        self.createdAt = try DynamicUtils.stringTypeDecoding(container: container, key: .createdAt)
        self.phone = try DynamicUtils.stringTypeDecoding(container: container, key: .phone)
        self.fields = try DynamicUtils.adFieldsTypeDecoding(container: container, key: .fields)
        self.brickId = try DynamicUtils.intTypeDecoding(container: container, key: .brickId)
        self.cityId = try DynamicUtils.intTypeDecoding(container: container, key: .cityId)
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.pricesListId = try DynamicUtils.intTypeDecoding(container: container, key: .pricesListId)
        self.zoneId = try DynamicUtils.intTypeDecoding(container: container, key: .zoneId)
        self.visitFTF = try DynamicUtils.intTypeDecoding(container: container, key: .visitFTF)
        self.visitVirtual = try DynamicUtils.intTypeDecoding(container: container, key: .visitVirtual)
        self.visitsFeeWasEdited = try DynamicUtils.boolTypeDecoding(container: container, key: .visitsFeeWasEdited)
        self.lastMove = try DynamicUtils.objectTypeDecoding(container: container, key: .lastMove)
        self.lastMovement = try DynamicUtils.objectTypeDecoding(container: container, key: .lastMovement)
        self.visitingHours = try DynamicUtils.listTypeDecoding(container: container, key: .visitingHours)
        self.locations = try DynamicUtils.listTypeDecoding(container: container, key: .locations)
        self.categories = try DynamicUtils.listTypeDecoding(container: container, key: .categories)
        self.contactControl = try DynamicUtils.listTypeDecoding(container: container, key: .contactControl)
        self.requests = try DynamicUtils.listTypeDecoding(container: container, key: .requests)
        self.users = try DynamicUtils.listTypeDecoding(container: container, key: .users)
        self.visitDates = try DynamicUtils.listTypeDecoding(container: container, key: .visitDates)
        
        self.panelId = try DynamicUtils.intTypeDecoding(container: container, key: .panelId)
        self.panelType = try DynamicUtils.stringTypeDecoding(container: container, key: .panelType)
        self.documentType = try DynamicUtils.stringTypeDecoding(container: container, key: .documentType)
        self.gender = try DynamicUtils.stringTypeDecoding(container: container, key: .gender)
        self.position = try DynamicUtils.stringTypeDecoding(container: container, key: .position)
        self.profession = try DynamicUtils.stringTypeDecoding(container: container, key: .profession)
        self.address = try DynamicUtils.stringTypeDecoding(container: container, key: .address)
        self.mobilePhone = try DynamicUtils.stringTypeDecoding(container: container, key: .mobilePhone)
        self.joinDate = try DynamicUtils.stringTypeDecoding(container: container, key: .joinDate)
        self.ext = try DynamicUtils.stringTypeDecoding(container: container, key: .ext)
        self.habeasData = try DynamicUtils.stringTypeDecoding(container: container, key: .habeasData)
        self.birthDate = try DynamicUtils.stringTypeDecoding(container: container, key: .birthDate)
        self.specialtyId = try DynamicUtils.intTypeDecoding(container: container, key: .specialtyId)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_contacto", idNumber = "cedula", name = "nombres", email = "email", createdAt = "created_at", phone = "telefono", fields, brickId = "id_brick", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", lastMove = "last_move", lastMovement = "last_movement", visitingHours = "visiting_hours", locations, categories, contactControl = "contact_control", requests = "general_requests", users = "panel_user", visitDates = "visited_on", panelId = "id_panel", panelType = "tipo_panel", documentType = "tipo_documento", gender = "sexo", position = "cargo", profession = "profesion", address = "direccion", mobilePhone = "celular", joinDate = "fecha_ingreso", ext = "extension", habeasData = "habeas_data", birthDate = "md_cumpleanos", specialtyId = "id_especialidad"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(idNumber, forKey: .idNumber)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(phone, forKey: .phone)
        try container.encode(fields, forKey: .fields)
        try container.encode(brickId, forKey: .brickId)
        try container.encode(cityId, forKey: .cityId)
        try container.encode(countryId, forKey: .countryId)
        try container.encode(pricesListId, forKey: .pricesListId)
        try container.encode(zoneId, forKey: .zoneId)
        try container.encode(visitFTF, forKey: .visitFTF)
        try container.encode(visitVirtual, forKey: .visitVirtual)
        try container.encode(visitingHours, forKey: .visitingHours)
        try container.encode(locations, forKey: .locations)
        try container.encode(categories, forKey: .categories)
        try container.encode(contactControl, forKey: .contactControl)
        try container.encode(requests, forKey: .requests)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}

class Diary: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var date: String?
    @Persisted var hourStart: String?
    @Persisted var hourEnd: String?
    @Persisted var type: String?
    @Persisted var contactType: String?
    @Persisted var panelType: String?
    @Persisted var content: String?
    @Persisted var panelId = 0
    @Persisted var isContactPoint = 0
    @Persisted var wasVisited = 0
    @Persisted var dataFields: String?
    @Persisted var transaction = ""
    @Persisted var lastUpdate = ""
    
    private enum CodingKeys: String, CodingKey {
        case id = "diary_id", date = "date_", hourStart = "hour_start", hourEnd = "hour_end", type = "type_", contactType = "contact_type", panelType = "panel_type", panelId = "panel_id", isContactPoint = "contact_point", dataFields, wasVisited, content
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(hourStart, forKey: .hourStart)
        try container.encode(hourEnd, forKey: .hourEnd)
        try container.encode(type, forKey: .type)
        try container.encode(contactType, forKey: .contactType)
        try container.encode(panelType, forKey: .panelType)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class Doctor: Object, Codable, Panel, SyncEntity, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    lazy var name: String? = { "\(firstName ?? "") \(lastName ?? "")" }()
    
    @Persisted var idNumber: String = ""
    @Persisted var type: String = "M"
    @Persisted var email: String? = ""
    @Persisted var createdAt: String = ""
    @Persisted var phone: String? = ""
    @Persisted var fields: String = ""
    
    @Persisted var brickId: Int?
    @Persisted var cityId: Int = 0
    @Persisted var countryId: Int?
    @Persisted var pricesListId: Int?
    @Persisted var zoneId: Int?
    @Persisted var visitFTF: Int?
    @Persisted var visitVirtual: Int?
    @Persisted var visitsFeeWasEdited: Bool = false
    var isSelected: Bool = false
    
    @Persisted var lastMove: PanelMove?
    @Persisted var lastMovement: MovementSummarized?
    @Persisted var visitingHours: List<PanelVisitingHour> = List<PanelVisitingHour>()
    @Persisted var locations: List<PanelLocation> = List<PanelLocation>()
    @Persisted var categories: List<PanelCategoryPanel> = List<PanelCategoryPanel>()
    @Persisted var contactControl: List<ContactControlPanel> = List<ContactControlPanel>()
    @Persisted var requests: List<GeneralRequest> = List<GeneralRequest>()
    @Persisted var users: List<PanelUser> = List<PanelUser>()
    @Persisted var visitDates: List<PanelVisitedOn> = List<PanelVisitedOn>()
    
    @Persisted var documentType: String? = ""
    @Persisted var firstName: String? = ""
    @Persisted var lastName: String? = ""
    @Persisted var score: Float? = 0
    @Persisted var cdi: String? = ""
    @Persisted var code: String? = ""
    @Persisted var neighborhood: String? = ""
    @Persisted var institution: String? = ""
    @Persisted var emailVerified: Int? = 0
    @Persisted var hasNoEmail: Int? = 0
    @Persisted var habeasData: String? = ""
    @Persisted var gender: String? = ""
    @Persisted var hq: String? = ""
    @Persisted var mobilePhone: String? = ""
    @Persisted var secretary: String? = ""
    @Persisted var birthDate: String? = ""
    @Persisted var birthDateSecretary: String? = ""
    @Persisted var joinDate: String? = ""
    @Persisted var prepaidEntities: String? = ""
    @Persisted var relatedTo: String? = ""
    @Persisted var formulation: String? = ""
    @Persisted var photo: String? = ""
    
    @Persisted var collegeId: Int? = 0
    @Persisted var specialtyId: Int? = 0
    @Persisted var secondSpecialtyId: Int? = 0
    @Persisted var styleId: Int? = 0
    @Persisted var tvConsent: Int? = 0
    
    @Persisted var lines: List<PanelLine> = List<PanelLine>()
    @Persisted var clients: List<PanelRelation> = List<PanelRelation>()
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case id = "id_medico", idNumber = "dni", email = "email", createdAt = "created_at", phone = "telefono_consulta", fields, brickId = "id_brick", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", visitsFeeWasEdited = "visits_fee_was_edited", lastMove = "last_move", lastMovement = "last_movement", visitingHours = "visiting_hours", locations, categories, contactControl = "contact_control", requests = "general_requests", users = "panel_user", visitDates = "visited_on", documentType = "tipo_documento", firstName = "nombres", lastName = "apellidos", score = "puntaje", cdi, code = "codigo", neighborhood = "barrio", institution = "institucion", emailVerified = "email_verificado", hasNoEmail = "no_email", habeasData = "habeas_data", gender = "sexo", hq = "sede", mobilePhone = "telefono_movil", secretary = "nombre_secretaria", birthDate = "md_cumpleanos", birthDateSecretary = "md_cumpleanos_secretaria", joinDate = "fecha_ingreso", prepaidEntities = "entidades_prepagadas", relatedTo = "asoc", formulation = "formulacion", photo = "foto", collegeId = "id_universidad", specialtyId = "id_especialidad", secondSpecialtyId = "id_especialidad_secundaria", styleId = "id_estilo", tvConsent = "tv_consent", clients, lines
    }
    
    override init() {
            super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.idNumber = try DynamicUtils.stringTypeDecoding(container: container, key: .idNumber)
        self.email = try DynamicUtils.stringTypeDecoding(container: container, key: .email)
        self.createdAt = try DynamicUtils.stringTypeDecoding(container: container, key: .createdAt)
        self.phone = try DynamicUtils.stringTypeDecoding(container: container, key: .phone)
        self.fields = try DynamicUtils.adFieldsTypeDecoding(container: container, key: .fields)
        self.brickId = try DynamicUtils.intTypeDecoding(container: container, key: .brickId)
        self.cityId = try DynamicUtils.intTypeDecoding(container: container, key: .cityId)
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.pricesListId = try DynamicUtils.intTypeDecoding(container: container, key: .pricesListId)
        self.zoneId = try DynamicUtils.intTypeDecoding(container: container, key: .zoneId)
        self.visitFTF = try DynamicUtils.flagTypeDecoding(container: container, key: .visitFTF)
        self.visitVirtual = try DynamicUtils.flagTypeDecoding(container: container, key: .visitVirtual)
        self.visitsFeeWasEdited = try DynamicUtils.boolTypeDecoding(container: container, key: .visitsFeeWasEdited)
        self.lastMove = try DynamicUtils.objectTypeDecoding(container: container, key: .lastMove)
        self.lastMovement = try DynamicUtils.objectTypeDecoding(container: container, key: .lastMovement)
        self.visitingHours = try DynamicUtils.listTypeDecoding(container: container, key: .visitingHours)
        self.locations = try DynamicUtils.listTypeDecoding(container: container, key: .locations)
        self.categories = try DynamicUtils.listTypeDecoding(container: container, key: .categories)
        self.contactControl = try DynamicUtils.listTypeDecoding(container: container, key: .contactControl)
        self.requests = try DynamicUtils.listTypeDecoding(container: container, key: .requests)
        self.users = try DynamicUtils.listTypeDecoding(container: container, key: .users)
        self.visitDates = try DynamicUtils.listTypeDecoding(container: container, key: .visitDates)
        
        
        self.documentType = try DynamicUtils.stringTypeDecoding(container: container, key: .documentType)
        self.firstName = try DynamicUtils.stringTypeDecoding(container: container, key: .firstName)
        self.lastName = try DynamicUtils.stringTypeDecoding(container: container, key: .lastName)
        self.score = try DynamicUtils.floatTypeDecoding(container: container, key: .score)
        self.cdi = try DynamicUtils.stringTypeDecoding(container: container, key: .cdi)
        self.code = try DynamicUtils.stringTypeDecoding(container: container, key: .code)
        self.neighborhood = try DynamicUtils.stringTypeDecoding(container: container, key: .neighborhood)
        self.institution = try DynamicUtils.stringTypeDecoding(container: container, key: .institution)
        self.emailVerified = try DynamicUtils.flagTypeDecoding(container: container, key: .emailVerified)
        self.hasNoEmail = try DynamicUtils.flagTypeDecoding(container: container, key: .hasNoEmail)
        self.habeasData = try DynamicUtils.stringTypeDecoding(container: container, key: .habeasData)
        self.gender = try DynamicUtils.stringTypeDecoding(container: container, key: .gender)
        self.hq = try DynamicUtils.stringTypeDecoding(container: container, key: .hq)
        self.mobilePhone = try DynamicUtils.stringTypeDecoding(container: container, key: .mobilePhone)
        self.secretary = try DynamicUtils.stringTypeDecoding(container: container, key: .secretary)
        self.birthDate = try DynamicUtils.stringTypeDecoding(container: container, key: .birthDate)
        self.birthDateSecretary = try DynamicUtils.stringTypeDecoding(container: container, key: .birthDateSecretary)
        self.joinDate = try DynamicUtils.stringTypeDecoding(container: container, key: .joinDate)
        self.prepaidEntities = try DynamicUtils.stringTypeDecoding(container: container, key: .prepaidEntities)
        self.relatedTo = try DynamicUtils.stringTypeDecoding(container: container, key: .relatedTo)
        self.formulation = try DynamicUtils.stringTypeDecoding(container: container, key: .formulation)
        self.photo = try DynamicUtils.stringTypeDecoding(container: container, key: .photo)
        
        self.collegeId = try DynamicUtils.intTypeDecoding(container: container, key: .collegeId)
        self.specialtyId = try DynamicUtils.intTypeDecoding(container: container, key: .specialtyId)
        self.secondSpecialtyId = try DynamicUtils.intTypeDecoding(container: container, key: .secondSpecialtyId)
        self.styleId = try DynamicUtils.intTypeDecoding(container: container, key: .styleId)
        self.tvConsent = try DynamicUtils.intTypeDecoding(container: container, key: .tvConsent)
        
        self.clients = try DynamicUtils.listTypeDecoding(container: container, key: .clients)
        self.lines = try DynamicUtils.listTypeDecoding(container: container, key: .lines)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_medico", idNumber = "dni", email = "email", createdAt = "created_at", phone = "telefono_consulta", fields, brickId = "id_brick", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", lastMove = "last_move", lastMovement = "last_movement", visitingHours = "visiting_hours", locations, categories, contactControl = "contact_control", requests = "general_requests", users = "panel_user", visitDates = "visited_on", documentType = "tipo_documento", firstName = "nombres", lastName = "apellidos", score = "puntaje", cdi, code = "codigo", neighborhood = "barrio", institution = "institucion", emailVerified = "email_verificado", hasNoEmail = "no_email", habeasData = "habeas_data", gender = "sexo", hq = "sede", mobilePhone = "telefono_movil", secretary = "nombre_secretaria", birthDate = "md_cumpleanos", birthDateSecretary = "md_cumpleanos_secretaria", joinDate = "fecha_ingreso", prepaidEntities = "entidades_prepagadas", relatedTo = "asoc", formulation = "formulacion", photo = "foto", collegeId = "id_universidad", specialtyId = "id_especialidad", secondSpecialtyId = "id_especialidad_secundaria", styleId = "id_estilo", tvConsent = "tv_consent", clients, lines
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(idNumber, forKey: .idNumber)
        try container.encode(email, forKey: .email)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(phone, forKey: .phone)
        //try container.encode(fields, forKey: .fields)
        try container.encode(brickId, forKey: .brickId)
        try container.encode(cityId, forKey: .cityId)
        try container.encode(countryId, forKey: .countryId)
        try container.encode(pricesListId, forKey: .pricesListId)
        try container.encode(zoneId, forKey: .zoneId)
        try container.encode(visitFTF, forKey: .visitFTF)
        try container.encode(visitVirtual, forKey: .visitVirtual)
        //try container.encode(visitingHours, forKey: .visitingHours)
        //try container.encode(locations, forKey: .locations)
        //try container.encode(categories, forKey: .categories)
        //try container.encode(contactControl, forKey: .contactControl)
        //try container.encode(requests, forKey: .requests)
        
        try container.encode(documentType, forKey: .documentType)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(cdi, forKey: .cdi)
        try container.encode(code, forKey: .code)
        try container.encode(neighborhood, forKey: .neighborhood)
        try container.encode(institution, forKey: .institution)
        try container.encode(emailVerified, forKey: .emailVerified)
        try container.encode(hasNoEmail, forKey: .hasNoEmail)
        try container.encode(habeasData, forKey: .habeasData)
        try container.encode(gender, forKey: .gender)
        try container.encode(hq, forKey: .hq)
        try container.encode(mobilePhone, forKey: .mobilePhone)
        try container.encode(secretary, forKey: .secretary)
        try container.encode(birthDate, forKey: .birthDate)
        try container.encode(birthDateSecretary, forKey: .birthDateSecretary)
        try container.encode(joinDate, forKey: .joinDate)
        try container.encode(prepaidEntities, forKey: .prepaidEntities)
        try container.encode(relatedTo, forKey: .relatedTo)
        try container.encode(formulation, forKey: .formulation)
        try container.encode(photo, forKey: .photo)
        try container.encode(collegeId, forKey: .collegeId)
        try container.encode(specialtyId, forKey: .specialtyId)
        try container.encode(secondSpecialtyId, forKey: .secondSpecialtyId)
        try container.encode(styleId, forKey: .styleId)
        try container.encode(tvConsent, forKey: .tvConsent)
        
        //try container.encode(clients, forKey: .clients)
        //try container.encode(lines, forKey: .lines)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
    static func classKeys() -> [String: String] {
        return ["id" : "id_medico", "idNumber" : "dni", "email" : "email", "createdAt" : "created_at", "phone" : "telefono_consulta", "fields, brickId" : "id_brick", "cityId" : "id_ciudad", "countryId" : "id_pais", "pricesListId" : "id_lista_precios", "zoneId" : "id_zona", "visitFTF" : "visit_ftf", "visitVirtual" : "visit_virtual", "lastMove" : "last_move", "lastMovement" : "last_movement", "visitingHours" : "visiting_hours", "locations, categories, contactControl" : "contact_control", "requests" : "general_requests", "users" : "panel_user", "visitDates" : "visited_on", "documentType" : "tipo_documento", "firstName" : "nombres", "lastName" : "apellidos", "score" : "puntaje", "cdi, code" : "codigo", "neighborhood" : "barrio", "institution" : "institucion", "emailVerified" : "email_verificado", "hasNoEmail" : "no_email", "habeasData" : "habeas_data", "gender" : "sexo", "hq" : "sede", "mobilePhone" : "telefono_movil", "secretary" : "nombre_secretaria", "birthDate" : "md_cumpleanos", "birthDateSecretary" : "md_cumpleanos_secretaria", "joinDate" : "fecha_ingreso", "prepaidEntities" : "entidades_prepagadas", "relatedTo" : "asoc", "formulation" : "formulacion", "photo" : "foto", "collegeId" : "id_universidad", "specialtyId" : "id_especialidad", "secondSpecialtyId" : "id_especialidad_secundaria", "styleId" : "id_estilo", "tvConsent" : "tv_consent"]
    }
    
    func specialtyName(realm: Realm) -> String {
        if let specialty = SpecialtyDao(realm: realm).by(id: specialtyId) {
            return specialty.name
        }
        return ""
    }
}

class Group: Object, Codable, SyncEntity, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var name: String = ""
    @Persisted var members = List<GroupMember>()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_grupo", name = "grupo", members
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}

class GroupMember: Object, Codable {
    @Persisted var panelObjectId: ObjectId
    @Persisted var panelId: Int
    @Persisted var panelType: String
    
    private enum CodingKeys: String, CodingKey {
        case panelId = "id", panelType = "type"
    }
}

class MediaItem: Object, Decodable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = "PENDING"
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var table: String = ""
    @Persisted var field: String = ""
    @Persisted var date: String = ""
    @Persisted var ext: String = ""
    @Persisted var serverId: Int = 0
    @Persisted var localId: ObjectId
}

class Movement: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var panelId: Int = 0
    @Persisted var panelObjectId: ObjectId
    @Persisted var panelType: String = ""
    @Persisted var date: String = ""
    @Persisted var realDate: String = ""
    @Persisted var hour: String = ""
    @Persisted var comment: String? = ""
    @Persisted var target: String? = ""
    @Persisted var duration: Float?
    @Persisted var executed: String = ""
    @Persisted var latitude: Float?
    @Persisted var longitude: Float?
    @Persisted var companionId: Int?
    @Persisted var wasScheduled: String = ""
    @Persisted var rqAssistance: Int = 0
    @Persisted var isOpen: Bool = false
    @Persisted var openLastNotification: String?
    @Persisted var openAt: String?
    @Persisted var closedAt: String?
    @Persisted var contactType: String = ""
    @Persisted var contactedBy: String?
    var assocPanelLocation: Bool = false
    @Persisted var dataContacts: String?
    @Persisted var additionalFields: String?
    @Persisted var cycleId: Int = 0
    @Persisted var dataPromoted: String = ""
    @Persisted var dataMaterial = List<MovementMaterial>()
    @Persisted var dataStock = List<MovementProductStock>()
    @Persisted var dataShopping = List<MovementProductShopping>()
    @Persisted var dataTransference = List<MovementProductTransference>()
    
    var tmpDate = Date()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_movimiento", panelId = "id_medico", panelType = "tipo", date = "fecha_visita", realDate = "fecha_real", hour = "hora_visita", comment = "comentario", target = "objetivo_proxima", duration = "duracion", executed = "no_efect", latitude = "latitud", longitude = "longitud", companionId = "id_acompanante", wasScheduled = "agendado", rqAssistance = "asistencia", openAt = "fecha_inicio", closedAt = "fecha_fin", contactType = "tipo_contacto", contactedBy = "contactado_por", dataContacts = "contacto", additionalFields = "fields", cycleId = "ciclo", dataPromoted = "productos_prom", dataMaterial = "rl_material_deliveries", dataStock = "rl_product_stock", dataShopping = "rl_shopping", dataTransference = "rl_product_transference"
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.additionalFields = try DynamicUtils.adFieldsTypeDecoding(container: container, key: .additionalFields)
    }
    
}

class MovementMaterial: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id: Int = 0//material_id
    @Persisted var category: String = ""
    @Persisted var sets = List<MovementMaterialSet>()
}

class MovementMaterialSet: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id: String = ""
    @Persisted var quantity: Int = 0
}

class MovementProductStock: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id: Int = 0//product_id
    @Persisted var hasStock: Bool = false//has_stock
    @Persisted var quantity: Float = 0
    @Persisted var noStockReason: String = ""//no_stock_reason
}

class MovementProductShopping: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id: Int = 0//product_id
    @Persisted var price: Float = 0
    @Persisted var competitors = List<MovementProductShoppingCompetitor>()
}

class MovementProductShoppingCompetitor: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id: String = ""//Competitor Name
    @Persisted var price: Float = 0
}

class MovementProductTransference: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id: Int = 0 //product_id
    @Persisted var quantity: Float = 0
    @Persisted var price: Float = 0
    @Persisted var bonusProduct: Int = 0//bonus_product
    @Persisted var bonusQuantity: Float = 0//bonus_quantity
}

class MovementSummarized: Object, Decodable {
    @Persisted var id = 0
    @Persisted var cycleId = 0
    @Persisted var date: String
    @Persisted var dateReal: String
    @Persisted var comment: String?
    @Persisted var targetNext: String?
    @Persisted var type: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_movimiento", cycleId = "ciclo", date = "fecha_visita", dateReal = "fecha_real", comment = "comentario", targetNext = "objetivo_proxima", type = "tipo"
    }
}

class PanelLocation: Object, Codable {
    @Persisted var id = 0
    @Persisted var address: String
    @Persisted var latitude: Float?
    @Persisted var longitude: Float?
    @Persisted var type: String?
    @Persisted var geocode: String?
    @Persisted var cityId: Int?
    @Persisted var complement: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "panel_location_id", address, latitude, longitude, type = "type_", geocode, cityId = "city_id", complement
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "panel_location_id", address, latitude, longitude, type = "type_", geocode, cityId = "city_id", complement
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(address, forKey: .address)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(type, forKey: .type)
        try container.encode(geocode, forKey: .geocode)
        try container.encode(cityId, forKey: .cityId)
        try container.encode(complement, forKey: .complement)
    }
}

class Patient: Object, Codable, Panel, SyncEntity, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    lazy var name: String? = { "\(firstName ?? "") \(lastName ?? "")" }()
    
    @Persisted var idNumber: String = ""
    @Persisted var type: String = "P"
    @Persisted var email: String? = ""
    @Persisted var createdAt: String = ""
    @Persisted var phone: String? = ""
    @Persisted var fields: String = ""
    
    @Persisted var brickId: Int?
    @Persisted var cityId: Int = 0
    @Persisted var countryId: Int?
    @Persisted var pricesListId: Int?
    @Persisted var zoneId: Int?
    @Persisted var visitFTF: Int?
    @Persisted var visitVirtual: Int?
    @Persisted var visitsFeeWasEdited: Bool = false
    var isSelected: Bool = false
    
    @Persisted var lastMove: PanelMove?
    @Persisted var lastMovement: MovementSummarized?
    @Persisted var visitingHours: List<PanelVisitingHour> = List<PanelVisitingHour>()
    @Persisted var locations: List<PanelLocation> = List<PanelLocation>()
    @Persisted var categories: List<PanelCategoryPanel> = List<PanelCategoryPanel>()
    @Persisted var contactControl: List<ContactControlPanel> = List<ContactControlPanel>()
    @Persisted var requests: List<GeneralRequest> = List<GeneralRequest>()
    @Persisted var users: List<PanelUser> = List<PanelUser>()
    @Persisted var visitDates: List<PanelVisitedOn> = List<PanelVisitedOn>()
    
    @Persisted var firstName: String? = ""
    @Persisted var lastName: String? = ""
    @Persisted var habeasData: String? = ""
    
    @Persisted var clients: List<PanelRelation> = List<PanelRelation>()
    @Persisted var doctors: List<PanelRelation> = List<PanelRelation>()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_paciente", idNumber = "dni", email = "email", createdAt = "created_at", phone = "telefono", fields, brickId = "id_brick", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", visitsFeeWasEdited = "visits_fee_was_edited", lastMove = "last_move", lastMovement = "last_movement", visitingHours = "visiting_hours", locations, categories, contactControl = "contact_control", requests = "general_requests", users = "panel_user", visitDates = "visited_on", firstName = "nombres", lastName = "apellidos", habeasData = "habeas_data", clients, doctors
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.idNumber = try DynamicUtils.stringTypeDecoding(container: container, key: .idNumber)
        self.email = try DynamicUtils.stringTypeDecoding(container: container, key: .email)
        self.createdAt = try DynamicUtils.stringTypeDecoding(container: container, key: .createdAt)
        self.phone = try DynamicUtils.stringTypeDecoding(container: container, key: .phone)
        self.fields = try DynamicUtils.adFieldsTypeDecoding(container: container, key: .fields)
        self.brickId = try DynamicUtils.intTypeDecoding(container: container, key: .brickId)
        self.cityId = try DynamicUtils.intTypeDecoding(container: container, key: .cityId)
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.pricesListId = try DynamicUtils.intTypeDecoding(container: container, key: .pricesListId)
        self.zoneId = try DynamicUtils.intTypeDecoding(container: container, key: .zoneId)
        self.visitFTF = try DynamicUtils.intTypeDecoding(container: container, key: .visitFTF)
        self.visitVirtual = try DynamicUtils.intTypeDecoding(container: container, key: .visitVirtual)
        self.visitsFeeWasEdited = try DynamicUtils.boolTypeDecoding(container: container, key: .visitsFeeWasEdited)
        self.lastMove = try DynamicUtils.objectTypeDecoding(container: container, key: .lastMove)
        self.lastMovement = try DynamicUtils.objectTypeDecoding(container: container, key: .lastMovement)
        self.visitingHours = try DynamicUtils.listTypeDecoding(container: container, key: .visitingHours)
        self.locations = try DynamicUtils.listTypeDecoding(container: container, key: .locations)
        self.categories = try DynamicUtils.listTypeDecoding(container: container, key: .categories)
        self.contactControl = try DynamicUtils.listTypeDecoding(container: container, key: .contactControl)
        self.requests = try DynamicUtils.listTypeDecoding(container: container, key: .requests)
        self.users = try DynamicUtils.listTypeDecoding(container: container, key: .users)
        self.visitDates = try DynamicUtils.listTypeDecoding(container: container, key: .visitDates)
        
        self.firstName = try DynamicUtils.stringTypeDecoding(container: container, key: .firstName)
        self.lastName = try DynamicUtils.stringTypeDecoding(container: container, key: .lastName)
        self.habeasData = try DynamicUtils.stringTypeDecoding(container: container, key: .habeasData)
        
        self.clients = try DynamicUtils.listTypeDecoding(container: container, key: .clients)
        self.doctors = try DynamicUtils.listTypeDecoding(container: container, key: .doctors)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_paciente", idNumber = "dni", email = "email", createdAt = "created_at", phone = "telefono", fields, brickId = "id_brick", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", lastMove = "last_move", lastMovement = "last_movement", visitingHours = "visiting_hours", locations, categories, contactControl = "contact_control", requests = "general_requests", users = "panel_user", visitDates = "visited_on", firstName = "nombres", lastName = "apellidos", habeasData = "habeas_data", clients, doctors
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(idNumber, forKey: .idNumber)
        try container.encode(email, forKey: .email)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(phone, forKey: .phone)
        try container.encode(fields, forKey: .fields)
        try container.encode(brickId, forKey: .brickId)
        try container.encode(cityId, forKey: .cityId)
        try container.encode(countryId, forKey: .countryId)
        try container.encode(pricesListId, forKey: .pricesListId)
        try container.encode(zoneId, forKey: .zoneId)
        try container.encode(visitFTF, forKey: .visitFTF)
        try container.encode(visitVirtual, forKey: .visitVirtual)
        try container.encode(visitingHours, forKey: .visitingHours)
        try container.encode(locations, forKey: .locations)
        try container.encode(categories, forKey: .categories)
        try container.encode(contactControl, forKey: .contactControl)
        try container.encode(requests, forKey: .requests)
        
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(habeasData, forKey: .habeasData)
        
        try container.encode(clients, forKey: .clients)
        try container.encode(doctors, forKey: .doctors)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
    static func classKeys() -> [String: String] {
        return ["id" : "id_paciente", "idNumber" : "dni", "email" : "email", "createdAt" : "created_at", "phone" : "telefono", "fields, brickId" : "id_brick", "cityId" : "id_ciudad", "countryId" : "id_pais", "pricesListId" : "id_lista_precios", "zoneId" : "id_zona", "visitFTF" : "visit_ftf", "visitVirtual" : "visit_virtual", "lastMove" : "last_move", "lastMovement" : "last_movement", "visitingHours" : "visiting_hours", "locations, categories, contactControl" : "contact_control", "requests" : "general_requests", "users" : "panel_user", "visitDates" : "visited_on", "firstName" : "nombres", "lastName" : "apellidos", "habeasData" : "habeas_data"]
    }
}

class Pharmacy: Object, Codable, Panel, SyncEntity, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var idNumber: String = ""
    @Persisted var type: String = "F"
    @Persisted var name: String? = ""
    @Persisted var email: String? = ""
    @Persisted var createdAt: String = ""
    @Persisted var phone: String? = ""
    @Persisted var fields: String = ""
    
    @Persisted var brickId: Int?
    @Persisted var cityId: Int = 0
    @Persisted var countryId: Int?
    @Persisted var pricesListId: Int?
    @Persisted var zoneId: Int?
    @Persisted var visitFTF: Int?
    @Persisted var visitVirtual: Int?
    @Persisted var visitsFeeWasEdited: Bool = false
    var isSelected: Bool = false
    
    @Persisted var lastMove: PanelMove?
    @Persisted var lastMovement: MovementSummarized?
    @Persisted var visitingHours: List<PanelVisitingHour> = List<PanelVisitingHour>()
    @Persisted var locations: List<PanelLocation> = List<PanelLocation>()
    @Persisted var categories: List<PanelCategoryPanel> = List<PanelCategoryPanel>()
    @Persisted var contactControl: List<ContactControlPanel> = List<ContactControlPanel>()
    @Persisted var requests: List<GeneralRequest> = List<GeneralRequest>()
    @Persisted var users: List<PanelUser> = List<PanelUser>()
    @Persisted var visitDates: List<PanelVisitedOn> = List<PanelVisitedOn>()
    
    @Persisted var code: String? = ""
    @Persisted var neighborhood: String? = ""
    @Persisted var openDate: String? = ""
    @Persisted var relatedTo: String? = ""
    @Persisted var profile: String? = ""
    @Persisted var observations: String? = ""
    
    @Persisted var pharmacyChainId: Int?
    @Persisted var pharmacyTypeId: Int?
    
    @Persisted var lines: List<PanelLine> = List<PanelLine>()
    @Persisted var contacts: List<PanelContact> = List<PanelContact>()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_detfarmacia", idNumber = "nit", name = "nombre", email = "email", createdAt = "created_at", phone = "telefono", fields, brickId = "id_brick", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", visitsFeeWasEdited = "visits_fee_was_edited", lastMove = "last_move", lastMovement = "last_movement", visitingHours = "visiting_hours", locations, categories, contactControl = "contact_control", requests = "general_requests", users = "panel_user", visitDates = "visited_on", code = "cod_farma", neighborhood = "barrio", openDate = "fecha_apertura", relatedTo = "asociado", profile = "perfil", observations = "observ", pharmacyChainId = "id_genfarmacia", pharmacyTypeId = "id_tipo_farmacia", lines, contacts
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.idNumber = try DynamicUtils.stringTypeDecoding(container: container, key: .idNumber)
        self.name = try DynamicUtils.stringTypeDecoding(container: container, key: .name)
        self.email = try DynamicUtils.stringTypeDecoding(container: container, key: .email)
        self.createdAt = try DynamicUtils.stringTypeDecoding(container: container, key: .createdAt)
        self.phone = try DynamicUtils.stringTypeDecoding(container: container, key: .phone)
        self.fields = try DynamicUtils.adFieldsTypeDecoding(container: container, key: .fields)
        self.brickId = try DynamicUtils.intTypeDecoding(container: container, key: .brickId)
        self.cityId = try DynamicUtils.intTypeDecoding(container: container, key: .cityId)
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.pricesListId = try DynamicUtils.intTypeDecoding(container: container, key: .pricesListId)
        self.zoneId = try DynamicUtils.intTypeDecoding(container: container, key: .zoneId)
        self.visitFTF = try DynamicUtils.intTypeDecoding(container: container, key: .visitFTF)
        self.visitVirtual = try DynamicUtils.intTypeDecoding(container: container, key: .visitVirtual)
        self.visitsFeeWasEdited = try DynamicUtils.boolTypeDecoding(container: container, key: .visitsFeeWasEdited)
        self.lastMove = try DynamicUtils.objectTypeDecoding(container: container, key: .lastMove)
        self.lastMovement = try DynamicUtils.objectTypeDecoding(container: container, key: .lastMovement)
        self.visitingHours = try DynamicUtils.listTypeDecoding(container: container, key: .visitingHours)
        self.locations = try DynamicUtils.listTypeDecoding(container: container, key: .locations)
        self.categories = try DynamicUtils.listTypeDecoding(container: container, key: .categories)
        self.contactControl = try DynamicUtils.listTypeDecoding(container: container, key: .contactControl)
        self.requests = try DynamicUtils.listTypeDecoding(container: container, key: .requests)
        self.users = try DynamicUtils.listTypeDecoding(container: container, key: .users)
        self.visitDates = try DynamicUtils.listTypeDecoding(container: container, key: .visitDates)
        
        self.code = try DynamicUtils.stringTypeDecoding(container: container, key: .code)
        self.neighborhood = try DynamicUtils.stringTypeDecoding(container: container, key: .neighborhood)
        self.openDate = try DynamicUtils.stringTypeDecoding(container: container, key: .openDate)
        self.relatedTo = try DynamicUtils.stringTypeDecoding(container: container, key: .relatedTo)
        self.profile = try DynamicUtils.stringTypeDecoding(container: container, key: .profile)
        self.observations = try DynamicUtils.stringTypeDecoding(container: container, key: .observations)
        
        self.pharmacyChainId = try DynamicUtils.intTypeDecoding(container: container, key: .pharmacyChainId)
        self.pharmacyTypeId = try DynamicUtils.intTypeDecoding(container: container, key: .pharmacyTypeId)
        
        self.lines = try DynamicUtils.listTypeDecoding(container: container, key: .lines)
        self.contacts = try DynamicUtils.listTypeDecoding(container: container, key: .contacts)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_detfarmacia", idNumber = "nit", name = "nombre", email = "email", createdAt = "created_at", phone = "telefono", fields, brickId = "id_brick", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", lastMove = "last_move", lastMovement = "last_movement", visitingHours = "visiting_hours", locations, categories, contactControl = "contact_control", requests = "general_requests", users = "panel_user", visitDates = "visited_on", code = "cod_farma", neighborhood = "barrio", openDate = "fecha_apertura", relatedTo = "asociado", profile = "perfil", observations = "observ", pharmacyChainId = "id_genfarmacia", pharmacyTypeId = "id_tipo_farmacia", lines, contacts
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(idNumber, forKey: .idNumber)
        try container.encode(email, forKey: .email)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(phone, forKey: .phone)
        try container.encode(fields, forKey: .fields)
        try container.encode(brickId, forKey: .brickId)
        try container.encode(cityId, forKey: .cityId)
        try container.encode(countryId, forKey: .countryId)
        try container.encode(pricesListId, forKey: .pricesListId)
        try container.encode(zoneId, forKey: .zoneId)
        try container.encode(visitFTF, forKey: .visitFTF)
        try container.encode(visitVirtual, forKey: .visitVirtual)
        try container.encode(visitingHours, forKey: .visitingHours)
        try container.encode(locations, forKey: .locations)
        try container.encode(categories, forKey: .categories)
        try container.encode(contactControl, forKey: .contactControl)
        try container.encode(requests, forKey: .requests)
        
        try container.encode(code, forKey: .code)
        try container.encode(neighborhood, forKey: .neighborhood)
        try container.encode(openDate, forKey: .openDate)
        try container.encode(relatedTo, forKey: .relatedTo)
        try container.encode(profile, forKey: .profile)
        try container.encode(observations, forKey: .observations)
        
        try container.encode(pharmacyChainId, forKey: .pharmacyChainId)
        try container.encode(pharmacyTypeId, forKey: .pharmacyTypeId)
        
        try container.encode(contacts, forKey: .contacts)
        try container.encode(lines, forKey: .lines)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
    static func classKeys() -> [String: String] {
        return ["id" : "id_detfarmacia", "idNumber" : "nit", "name" : "nombre", "email" : "email", "createdAt" : "created_at", "phone" : "telefono", "fields, brickId" : "id_brick", "cityId" : "id_ciudad", "countryId" : "id_pais", "pricesListId" : "id_lista_precios", "zoneId" : "id_zona", "visitFTF" : "visit_ftf", "visitVirtual" : "visit_virtual", "visitsFeeWasEdited" : "visits_fee_was_edited", "lastMove" : "last_move", "lastMovement" : "last_movement", "visitingHours" : "visiting_hours", "locations, categories, contactControl" : "contact_control", "requests" : "general_requests", "users" : "panel_user", "visitDates" : "visited_on", "code" : "cod_farma", "neighborhood" : "barrio", "openDate" : "fecha_apertura", "relatedTo" : "asociado", "profile" : "perfil", "observations" : "observ", "pharmacyChainId" : "id_genfarmacia", "pharmacyTypeId" : "id_tipo_farmacia"]
    }
    
    func pharmacyTypeName(realm: Realm) -> String {
        if let pharmacyType = PharmacyTypeDao(realm: realm).by(id: pharmacyTypeId) {
            return pharmacyType.name
        }
        return ""
    }
    
    func pharmacyChainName(realm: Realm) -> String {
        if let pharmacyChain = PharmacyChainDao(realm: realm).by(id: pharmacyChainId) {
            return pharmacyChain.name ?? ""
        }
        return ""
    }
    
}

class PotentialProfessional: Object, Codable, Panel, SyncEntity, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var idNumber: String = ""
    @Persisted var name: String? = ""
    @Persisted var type: String = "T"
    @Persisted var email: String? = ""
    @Persisted var createdAt: String = ""
    @Persisted var phone: String? = ""
    @Persisted var fields: String = ""
    
    @Persisted var brickId: Int?
    @Persisted var cityId: Int = 0
    @Persisted var countryId: Int?
    @Persisted var pricesListId: Int?
    @Persisted var zoneId: Int?
    @Persisted var visitFTF: Int?
    @Persisted var visitVirtual: Int?
    @Persisted var visitsFeeWasEdited: Bool = false
    var isSelected: Bool = false
    
    @Persisted var lastMove: PanelMove?
    @Persisted var lastMovement: MovementSummarized?
    @Persisted var visitingHours: List<PanelVisitingHour> = List<PanelVisitingHour>()
    @Persisted var locations: List<PanelLocation> = List<PanelLocation>()
    @Persisted var categories: List<PanelCategoryPanel> = List<PanelCategoryPanel>()
    @Persisted var contactControl: List<ContactControlPanel> = List<ContactControlPanel>()
    @Persisted var requests: List<GeneralRequest> = List<GeneralRequest>()
    @Persisted var users: List<PanelUser> = List<PanelUser>()
    @Persisted var visitDates: List<PanelVisitedOn> = List<PanelVisitedOn>()
    
    @Persisted var cityName: String? = ""
    @Persisted var address: String? = ""
    @Persisted var specialtyName: String? = ""
    @Persisted var joinDate: String? = ""
    @Persisted var observations: String? = ""
    
    var brick: Brick?
    var category: PanelCategory?
    var city: City?
    var country: Country?
    var pricesList: PricesList?
    var zone: Zone?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id", idNumber = "cedula", name = "nombre", email = "email", createdAt = "created_at", phone = "telefono", fields, brickId = "id_brick", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", visitsFeeWasEdited = "visits_fee_was_edited", lastMove = "last_move", lastMovement = "last_movement", visitingHours = "visiting_hours", locations, categories, contactControl = "contact_control", requests = "general_requests", users = "panel_user", visitDates = "visited_on", contacts, cityName = "ciudad", address = "direccion", specialtyName = "especialidad", joinDate = "fecha_ingre", observations = "observaciones"
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.idNumber = try DynamicUtils.stringTypeDecoding(container: container, key: .idNumber)
        self.name = try DynamicUtils.stringTypeDecoding(container: container, key: .name)
        self.email = try DynamicUtils.stringTypeDecoding(container: container, key: .email)
        self.createdAt = try DynamicUtils.stringTypeDecoding(container: container, key: .createdAt)
        self.phone = try DynamicUtils.stringTypeDecoding(container: container, key: .phone)
        self.fields = try DynamicUtils.adFieldsTypeDecoding(container: container, key: .fields)
        self.brickId = try DynamicUtils.intTypeDecoding(container: container, key: .brickId)
        self.cityId = try DynamicUtils.intTypeDecoding(container: container, key: .cityId)
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.pricesListId = try DynamicUtils.intTypeDecoding(container: container, key: .pricesListId)
        self.zoneId = try DynamicUtils.intTypeDecoding(container: container, key: .zoneId)
        self.visitFTF = try DynamicUtils.intTypeDecoding(container: container, key: .visitFTF)
        self.visitVirtual = try DynamicUtils.intTypeDecoding(container: container, key: .visitVirtual)
        self.visitsFeeWasEdited = try DynamicUtils.boolTypeDecoding(container: container, key: .visitsFeeWasEdited)
        self.lastMove = try DynamicUtils.objectTypeDecoding(container: container, key: .lastMove)
        self.lastMovement = try DynamicUtils.objectTypeDecoding(container: container, key: .lastMovement)
        self.visitingHours = try DynamicUtils.listTypeDecoding(container: container, key: .visitingHours)
        self.locations = try DynamicUtils.listTypeDecoding(container: container, key: .locations)
        self.categories = try DynamicUtils.listTypeDecoding(container: container, key: .categories)
        self.contactControl = try DynamicUtils.listTypeDecoding(container: container, key: .contactControl)
        self.requests = try DynamicUtils.listTypeDecoding(container: container, key: .requests)
        self.users = try DynamicUtils.listTypeDecoding(container: container, key: .users)
        self.visitDates = try DynamicUtils.listTypeDecoding(container: container, key: .visitDates)
        
        self.cityName = try DynamicUtils.stringTypeDecoding(container: container, key: .cityName)
        self.address = try DynamicUtils.stringTypeDecoding(container: container, key: .address)
        self.specialtyName = try DynamicUtils.stringTypeDecoding(container: container, key: .specialtyName)
        self.observations = try DynamicUtils.stringTypeDecoding(container: container, key: .observations)
        self.joinDate = try DynamicUtils.stringTypeDecoding(container: container, key: .joinDate)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id", idNumber = "cedula", name = "nombre", email = "email", createdAt = "created_at", phone = "telefono", fields, brickId = "id_brick", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", lastMove = "last_move", lastMovement = "last_movement", visitingHours = "visiting_hours", locations, categories, contactControl = "contact_control", requests = "general_requests", users = "panel_user", visitDates = "visited_on", contacts, cityName = "ciudad", address = "direccion", specialtyName = "especialidad", joinDate = "fecha_ingre", observations = "observaciones"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(idNumber, forKey: .idNumber)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(phone, forKey: .phone)
        try container.encode(fields, forKey: .fields)
        try container.encode(brickId, forKey: .brickId)
        try container.encode(cityId, forKey: .cityId)
        try container.encode(countryId, forKey: .countryId)
        try container.encode(pricesListId, forKey: .pricesListId)
        try container.encode(zoneId, forKey: .zoneId)
        try container.encode(visitFTF, forKey: .visitFTF)
        try container.encode(visitVirtual, forKey: .visitVirtual)
        try container.encode(visitingHours, forKey: .visitingHours)
        try container.encode(locations, forKey: .locations)
        try container.encode(categories, forKey: .categories)
        try container.encode(contactControl, forKey: .contactControl)
        try container.encode(requests, forKey: .requests)
        
        try container.encode(cityName, forKey: .cityName)
        try container.encode(address, forKey: .address)
        try container.encode(specialtyName, forKey: .specialtyName)
        try container.encode(joinDate, forKey: .joinDate)
        try container.encode(observations, forKey: .observations)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
    static func classKeys() -> [String: String] {
        return ["id" : "id", "idNumber" : "cedula", "name" : "nombre", "email" : "email", "createdAt" : "created_at", "phone" : "telefono", "fields, brickId" : "id_brick", "cityId" : "id_ciudad", "countryId" : "id_pais", "pricesListId" : "id_lista_precios", "zoneId" : "id_zona", "visitFTF" : "visit_ftf", "visitVirtual" : "visit_virtual", "lastMove" : "last_move", "lastMovement" : "last_movement", "visitingHours" : "visiting_hours", "locations, categories, contactControl" : "contact_control", "requests" : "general_requests", "users" : "panel_user", "visitDates" : "visited_on", "contacts, cityName" : "ciudad", "address" : "direccion", "specialtyName" : "especialidad", "joinDate" : "fecha_ingre", "observations" : "observaciones"]
    }
}

class FreeDayRequest: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var reasonId: Int = 0
    @Persisted var requestedAt: String = ""
    @Persisted var observations: String = ""
    @Persisted var solved: Bool = false
    @Persisted var solvedAt: String = ""
    @Persisted var solvedBy: Int = 0
    @Persisted var details: List<FreeDayRequestDetail> = List<FreeDayRequestDetail>()
    
    private enum CodingKeys: String, CodingKey {
        case id = "free_day_request_id", reasonId = "free_day_reason_id", requestedAt = "requested_at", observations, solved, solvedAt = "solved_at", solvedBy = "solved_by", details
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "free_day_request_id", reasonId = "free_day_reason_id", requestedAt = "requested_at", observations, solved, solvedAt = "solved_at", solvedBy = "solved_by", details
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class FreeDayRequestDetail: Object, Codable {
    @Persisted var date: String = ""
    @Persisted var dayFull: Bool = false
    @Persisted var dayOnlyAM: Bool = false
    @Persisted var dayOnlyPM: Bool = false
    @Persisted var dayCustom: Bool = false
    @Persisted var percentage: Float = 0
    @Persisted var authorized: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case date = "date_", dayFull = "day_full", dayOnlyAM = "day_only_am", dayOnlyPM = "day_only_pm", dayCustom = "day_custom", percentage, authorized
    }
    
    private enum EncodingKeys: String, CodingKey {
        case date = "date_", dayFull = "day_full", dayOnlyAM = "day_only_am", dayOnlyPM = "day_only_pm", dayCustom = "day_custom", percentage, authorized
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(date, forKey: .date)
    }
}

class ExpenseReport: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var date: String = ""
    @Persisted var originDestiny: String = ""
    @Persisted var observations: String = ""
    @Persisted var details: List<ExpenseReportDetail> = List<ExpenseReportDetail>()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id", date = "date_", originDestiny = "origin_destiny", observations, details
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id", date = "date_", originDestiny = "origin_destiny", observations, details
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class ExpenseReportDetail: Object, Codable {
    @Persisted var objectId: ObjectId
    @Persisted var conceptId: Int = 0
    @Persisted var total: Float = 0
    @Persisted var companyNIT: String = ""
    @Persisted var companyName: String = ""
    @Persisted var supportingDocument: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case conceptId = "concept_id", total, companyNIT = "company_nit", companyName = "company_name", supportingDocument = "supporting_document"
    }
    
    private enum EncodingKeys: String, CodingKey {
        case conceptId = "concept_id", total, companyNIT = "company_nit", companyName = "company_name", supportingDocument = "supporting_document"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(conceptId, forKey: .conceptId)
    }
}

class RequestDay: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var dateStart: Date?
    @Persisted var dateEnd: Date?
    @Persisted var days = Float(0)
    @Persisted var percentage = Float(0)
    @Persisted var reason: String?
    @Persisted var comment: String?
    @Persisted var cycleId = Int(0)
    @Persisted var transaction = ""
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: RequestDay.CodingKeys(stringValue: "id")!)
        try container.encode(Utils.dateFormat(date: dateStart!), forKey: RequestDay.CodingKeys(stringValue: "fecha_inicial")!)
        try container.encode(Utils.dateFormat(date: dateEnd!), forKey: RequestDay.CodingKeys(stringValue: "fecha_final")!)
        try container.encode(days, forKey: RequestDay.CodingKeys(stringValue: "dias")!)
        try container.encode(percentage, forKey: RequestDay.CodingKeys(stringValue: "porcentaje")!)
        try container.encode(cycleId, forKey: RequestDay.CodingKeys(stringValue: "ciclo")!)
    }
}

class Expense: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var baseURL: String? = ""
    @Persisted var user: Int? = 0
    @Persisted var expenseDate: String? = ""
    @Persisted var verification: String? = ""
    @Persisted var originDestination: String? = ""
    @Persisted var concept: String? = ""
    @Persisted var total: Float? = 0
    @Persisted var km: Float? = 0
    @Persisted var kmExpense: Float? = 0
    @Persisted var observations: String? = ""
    @Persisted var conceptData: String? = ""
    
    private enum CodingKeys: String, CodingKey {
        case baseURL = "registro_gastos", user = "id_usuario", expenseDate = "fecha_gasto", verification = "comprobacion", originDestination = "origen_destino", km = "km", kmExpense = "gasto_km", observations = "observaciones", conceptData = "conceptData"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .user
        return codingKey.rawValue
    }
}

class ConceptExpenseSimple: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var baseURL: String? = ""
    @Persisted var name: String? = ""
    @Persisted var photo: String? = ""
    @Persisted var value: String? = ""
    @Persisted var companyDNI: String? = ""
    @Persisted var companyName: String? = ""
    
    private enum CodingKeys: String, CodingKey {
        case baseURL = "registro_gastos", id = "id_concepto", name = "concepto"
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.baseURL = try DynamicUtils.stringTypeDecoding(container: container, key: .baseURL)
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.name = try DynamicUtils.stringTypeDecoding(container: container, key: .name)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case baseURL = "registro_gastos", id = "id_concepto", name = "concepto"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(baseURL, forKey: .baseURL)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}








class PanelVisitingHour: Object, Codable {
    @Persisted var dayOfWeek: Int = 0
    @Persisted var amHourStart: String = ""
    @Persisted var amHourEnd: String = ""
    @Persisted var pmHourStart: String = ""
    @Persisted var pmHourEnd: String = ""
    @Persisted var amStatus: Int = 0
    @Persisted var pmStatus: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week", amHourStart = "am_hour_start", amHourEnd = "am_hour_end", pmHourStart = "pm_hour_start", pmHourEnd = "pm_hour_end", amStatus = "am_status", pmStatus = "pm_status"
    }
    
    private enum EncodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week", amHourStart = "am_hour_start", amHourEnd = "am_hour_end", pmHourStart = "pm_hour_start", pmHourEnd = "pm_hour_end", amStatus = "am_status", pmStatus = "pm_status"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(dayOfWeek, forKey: .dayOfWeek)
        try container.encode(amHourStart, forKey: .amHourStart)
        try container.encode(amHourEnd, forKey: .amHourEnd)
        try container.encode(pmHourStart, forKey: .pmHourStart)
        try container.encode(pmHourEnd, forKey: .pmHourEnd)
        try container.encode(amStatus, forKey: .amStatus)
        try container.encode(pmStatus, forKey: .pmStatus)
    }
}

class PanelMove: Object, Codable {
    @Persisted var id: Int = 0
    @Persisted var userForm: Int = 0
    @Persisted var userTo: Int = 0
    @Persisted var date: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case id = "panel_move_id", userForm = "user_from", userTo = "user_to", date = "date_"
    }
}

class PanelCategoryPanel: Object, Codable {
    @Persisted var id: Int = 0
    @Persisted var categoryId: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case id = "panel_category_panel_id", categoryId = "category_id"
    }
}

class ContactControlPanel: Object, Codable {
    @Persisted var status: Int = 0
    @Persisted var contactControlTypeId: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case status = "status_", contactControlTypeId = "contact_control_type_id"
    }
}

class PanelLine: Object, Codable {
    @Persisted var panelId = 0
    @Persisted var panelType = ""
    @Persisted var lineId = 0
    
    private enum CodingKeys: String, CodingKey {
        case panelId = "panel_id", panelType = "panel_type", lineId = "line_id"
    }
    
    private enum EncodingKeys: String, CodingKey {
        case panelId = "panel_id", panelType = "panel_type", lineId = "line_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(panelId, forKey: .panelId)
        try container.encode(panelType, forKey: .panelType)
        try container.encode(lineId, forKey: .lineId)
    }
}

class PanelRelation: Object, Codable {
    @Persisted var id = 0
    @Persisted var relatedToId = 0
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_relacion", relatedToId = "id_panel_2"
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_relacion", relatedToId = "id_panel_2"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(relatedToId, forKey: .relatedToId)
    }
}

class PanelUser: Object, Decodable {
    @Persisted var userId = 0
    @Persisted var visitsFee = 0
    @Persisted var visitsCycle = 0
    
    private enum CodingKeys: String, CodingKey {
        case userId = "id_usuario", visitsFee = "num_visitas", visitsCycle = "visits_in_cycle_count"
    }
}

class GeneralRequest: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String = ""
    @Persisted var transactionType: String = ""
    @Persisted var transactionResponse: String = ""
    
    @Persisted var senderId: Int = 0
    @Persisted var recipientId: Int? = 0
    @Persisted var itemId: Int = 0
    @Persisted var itemType: String? = ""
    @Persisted var type: String? = ""
    @Persisted var content: String? = ""
    @Persisted var result: String? = ""
    @Persisted var requestedAt: String = ""
    @Persisted var seenAt: String? = ""
    @Persisted var solvedAt: String? = ""
    
    private enum CodingKeys: String, CodingKey {
        case id = "general_request_id", senderId = "sender_id", recipientId = "recipient_id", itemId = "item_id", itemType = "item_type",
             type = "type_", content, result, requestedAt = "requested", seenAt = "seen", solvedAt = "solved"
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "general_request_id", senderId = "sender_id", recipientId = "recipient_id", itemId = "item_id", itemType = "item_type",
             type = "type_", content, result, requestedAt = "requested", seenAt = "seen", solvedAt = "solved"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(senderId, forKey: .senderId)
        try container.encode(recipientId, forKey: .recipientId)
        try container.encode(itemId, forKey: .itemId)
        try container.encode(itemType, forKey: .itemType)
        try container.encode(type, forKey: .type)
        try container.encode(content, forKey: .content)
        try container.encode(result, forKey: .result)
        try container.encode(requestedAt, forKey: .requestedAt)
        try container.encode(seenAt, forKey: .seenAt)
        try container.encode(solvedAt, forKey: .solvedAt)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class PanelVisitedOn: Object, Decodable {
    @Persisted var id = 0
    @Persisted var userID = 0
    @Persisted var date: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_movimiento", userID = "id_usuario", date = "fecha_visita"
    }
}
