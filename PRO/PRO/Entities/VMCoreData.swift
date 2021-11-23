//
//  VMCoreData.swift
//  PRO
//
//  Created by VMO on 2/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//


import Foundation
import RealmSwift

class Activity: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    @Persisted var description_: String?
    @Persisted var dateStart: String?
    @Persisted var dateEnd: String?
    @Persisted var hourStart: String?
    @Persisted var hourEnd: String?
    @Persisted var medics: String?
    @Persisted var pharmacies: String?
    @Persisted var clients: String?
    @Persisted var patients: String?
    @Persisted var requestFreeDay: Int?
    @Persisted var dayPercentage: Float?
    @Persisted var dayReason: String?
    @Persisted var latitude: Float?
    @Persisted var longitude: Float?
    //@Persisted var fieldsData: String?
    @Persisted var transaction = ""
    @Persisted var lastUpdate = ""
    var cycle: Cycle?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_actividad", description_ = "descripcion", dateStart = "fecha_inicial", dateEnd = "fecha_final", hourStart = "hora_inicial", hourEnd = "hora_final", medics = "id_medico", pharmacies = "id_farmacia", clients = "id_cliente", patients = "id_paciente", latitude = "latitud", longitude = "longitud", requestFreeDay = "solicitar_dias_autorizados"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}

class AdvertisingMaterialDelivery: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    @Persisted var userId: Int = 0
    @Persisted var userTo: Int = 0
    @Persisted var materialId: Int = 0
    @Persisted var type: String = ""
    @Persisted var date: String = ""
    @Persisted var comment: String = ""
    @Persisted var category: String = ""
    @Persisted var sets = List<AdvertisingMaterialDeliverySet>()
    
    var material: AdvertisingMaterial? = nil
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
    }
}

class AdvertisingMaterialDeliverySet: Object {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id: String = ""
    @Persisted var quantity: Int = 0
    var set: AdvertisingMaterialSet = AdvertisingMaterialSet()
}

class AdvertisingMaterialRequest: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var materials: String = "" //Materials IDs Separated by commas
    @Persisted var date: String = ""
    @Persisted var comment: String = ""
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
    }
}

protocol SyncEntity {
    var objectId: ObjectId { get set }
    var id: Int { get set }
    var transactionStatus: String? { get set }
    var transactionPending: String? { get set }
    var transactionResponse: String? { get set }
}

protocol Panel {
    var id: Int { get set }
    var idNumber: String? { get set }
    var type: String { get set }
    var name: String? { get set }
    var email: String? { get set }
    var phone: String? { get set }
    var additionalFields: String? { get set }
    
    var brickId: Int? { get set }
    var categoryId: Int? { get set }
    var cityId: Int? { get set }
    var countryId: Int? { get set }
    var pricesListId: Int? { get set }
    var zoneId: Int? { get set }
    
    var isMarked: Int { get set }
    var score: Float? { get set }
    var visitFTF: Int? { get set }
    var visitVirtual: Int? { get set }
    
    var lastMovement: MovementSimple? { get set }
    var locations: List<PanelLocation> { get set }
    var visitingHours: List<VisitingHour> { get set }
    var userPanel: List<UserPanel> { get set }
    
    var brick: Brick? { get set }
    var category: Category? { get set }
    var city: City? { get set }
    var country: Country? { get set }
    var pricesList: PricesList? { get set }
    var zone: Zone? { get set }
    
}

class GenericPanel: Panel, SyncEntity {
    var idNumber: String?
    var type: String = ""
    var name: String?
    var email: String?
    var phone: String?
    var additionalFields: String?
    var brickId: Int?
    var categoryId: Int?
    var cityId: Int?
    var countryId: Int?
    var pricesListId: Int?
    var zoneId: Int?
    var isMarked: Int = 0
    var score: Float?
    var visitFTF: Int?
    var visitVirtual: Int?
    var lastMovement: MovementSimple?
    var locations: List<PanelLocation> = List<PanelLocation>()
    var visitingHours: List<VisitingHour> = List<VisitingHour>()
    var userPanel: List<UserPanel> = List<UserPanel>()
    var brick: Brick?
    var category: Category?
    var city: City?
    var country: Country?
    var pricesList: PricesList?
    var zone: Zone?
    var objectId: ObjectId = ObjectId()
    var id: Int = 0
    var transactionStatus: String?
    var transactionPending: String?
    var transactionResponse: String?
    
}

class Client: Object, Codable, Panel, SyncEntity, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    @Persisted var idNumber: String?
    @Persisted var type: String = "C"
    @Persisted var name: String?
    @Persisted var email: String?
    @Persisted var phone: String?
    @Persisted var brickId: Int?
    @Persisted var categoryId: Int?
    @Persisted var cityId: Int?
    @Persisted var countryId: Int?
    @Persisted var pricesListId: Int?
    @Persisted var zoneId: Int?
    @Persisted var isMarked: Int
    @Persisted var score: Float?
    @Persisted var visitFTF: Int?
    @Persisted var visitVirtual: Int?
    @Persisted var additionalFields: String?
    @Persisted var lastMovement: MovementSimple?
    @Persisted var locations: List<PanelLocation>
    @Persisted var visitingHours: List<VisitingHour>
    @Persisted var userPanel: List<UserPanel>
    
    @Persisted var alias: String?
    @Persisted var joinDate: String?
    @Persisted var observations: String?
    @Persisted var url: String?
    
    var brick: Brick?
    var category: Category?
    var city: City?
    var country: Country?
    var pricesList: PricesList?
    var zone: Zone?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_cliente", name = "nombre"
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.name = try DynamicUtils.stringTypeDecoding(container: container, key: .name)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_cliente", name = "nombre"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}

class Contact: Object, Codable, Panel, SyncEntity, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var idNumber: String?
    @Persisted var type: String = "CT"
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    @Persisted var name: String?
    @Persisted var position: String?
    @Persisted var address: String?
    @Persisted var phone: String?
    @Persisted var mobilePhone: String?
    @Persisted var email: String?
    @Persisted var birthMonth = 0
    @Persisted var birthDay = 0
    @Persisted var specialty: String?
    @Persisted var hd: String?
    @Persisted var panelType: String?
    @Persisted var transaction = ""
    @Persisted var lastUpdate = ""
    @Persisted var cityId: Int?
    @Persisted var countryId: Int?
    
    var additionalFields: String?
    var brickId: Int?
    var categoryId: Int?
    var pricesListId: Int?
    var zoneId: Int?
    var isMarked: Int = 0
    var score: Float?
    var visitFTF: Int?
    var visitVirtual: Int?
    
    
    var locations = List<PanelLocation>()
    var visitingHours = List<VisitingHour>()
    var userPanel = List<UserPanel>()
    
    var brick: Brick?
    var category: Category?
    var city: City?
    var country: Country?
    var lastMovement: MovementSimple?
    var pricesList: PricesList?
    var zone: Zone?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_contacto", name = "nombres", position = "cargo", address = "direccion", phone = "telefono", mobilePhone = "celular", email = "correo_electronico", birthMonth = "mes_cumpleanos", birthDay = "dia_cumpleanos", specialty = "especialidad", hd = "habeas_data", panelType = "tipo", cityId = "ciudad"
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
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
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
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    lazy var name: String? = { "\(firstName ?? "") \(lastName ?? "")" }()
    
    @Persisted var idNumber: String?
    @Persisted var type: String = "M"
    @Persisted var email: String?
    @Persisted var phone: String?
    @Persisted var brickId: Int?
    @Persisted var categoryId: Int? = 0
    @Persisted var cityId: Int?
    @Persisted var countryId: Int?
    @Persisted var pricesListId: Int?
    @Persisted var zoneId: Int?
    @Persisted var isMarked: Int
    @Persisted var score: Float?
    @Persisted var visitFTF: Int?
    @Persisted var visitVirtual: Int?
    @Persisted var additionalFields: String?
    @Persisted var lastMovement: MovementSimple?
    @Persisted var locations: List<PanelLocation>
    @Persisted var visitingHours: List<VisitingHour>
    @Persisted var userPanel: List<UserPanel>
    
    @Persisted var documentType: String?
    @Persisted var firstName: String?
    @Persisted var lastName: String?
    @Persisted var cdi: String?
    @Persisted var code: String?
    @Persisted var neighborhood: String?
    @Persisted var institution: String?
    @Persisted var emailVerified: Int?
    @Persisted var hasNoEmail: Int?
    @Persisted var habeasData: String?
    @Persisted var gender: String?
    @Persisted var hq: String?
    @Persisted var mobilePhone: String?
    @Persisted var secretary: String?
    @Persisted var birthDate: String?
    @Persisted var birthDateSecretary: String?
    @Persisted var joinDate: String?
    @Persisted var prepaidEntities: String?
    @Persisted var relatedTo: String?
    @Persisted var formulation: String?
    @Persisted var photo: String?
    
    @Persisted var lines: String?
    @Persisted var collegeId: Int?
    @Persisted var clientId: Int?
    @Persisted var specialtyId: Int?
    @Persisted var secondSpecialtyId: Int?
    @Persisted var styleId: Int?
    
    var brick: Brick?
    var category: Category?
    var city: City?
    var country: Country?
    var pricesList: PricesList?
    var zone: Zone?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_medico", idNumber = "dni", email = "email", phone = "telefono_consulta", brickId = "id_brick", categoryId = "id_categoria", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", score = "puntaje", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", additionalFields = "fields", documentType = "tipo_documento", firstName = "nombres", lastName = "apellidos", code = "codigo", neighborhood = "barrio", institution = "institucion", emailVerified = "email_verificado", hasNoEmail = "no_email", habeasData = "habeas_data", gender = "sexo", hq = "sede", mobilePhone = "telefono_movil", secretary = "nombre_secretaria", birthDate = "md_cumpleanos", birthDateSecretary = "md_cumpleanos_secretaria", joinDate = "fecha_ingreso", prepaidEntities = "entidades_prepagadas", relatedTo = "asoc", formulation = "formulacion", photo = "foto", lines = "lineas", collegeId = "id_universidad", clientId = "id_cliente", specialtyId = "id_especialidad", secondSpecialtyId = "id_especialidad_secundaria", styleId = "id_estilo", isMarked, cdi
    }
    
    override init() {
            super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.brickId = try DynamicUtils.intTypeDecoding(container: container, key: .brickId)
        self.categoryId = try DynamicUtils.intTypeDecoding(container: container, key: .categoryId)
        self.cityId = try DynamicUtils.intTypeDecoding(container: container, key: .cityId)
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.pricesListId = try DynamicUtils.intTypeDecoding(container: container, key: .pricesListId)
        self.zoneId = try DynamicUtils.intTypeDecoding(container: container, key: .zoneId)
        self.visitFTF = try DynamicUtils.intTypeDecoding(container: container, key: .visitFTF)
        self.visitVirtual = try DynamicUtils.intTypeDecoding(container: container, key: .visitVirtual)
        self.emailVerified = try DynamicUtils.intTypeDecoding(container: container, key: .emailVerified)
        self.hasNoEmail = try DynamicUtils.intTypeDecoding(container: container, key: .hasNoEmail)
        self.collegeId = try DynamicUtils.intTypeDecoding(container: container, key: .collegeId)
        self.clientId = try DynamicUtils.intTypeDecoding(container: container, key: .clientId)
        self.specialtyId = try DynamicUtils.intTypeDecoding(container: container, key: .specialtyId)
        self.secondSpecialtyId = try DynamicUtils.intTypeDecoding(container: container, key: .secondSpecialtyId)
        self.styleId = try DynamicUtils.intTypeDecoding(container: container, key: .styleId)
        self.isMarked = try DynamicUtils.intTypeDecoding(container: container, key: .isMarked)
        
        self.score = try DynamicUtils.floatTypeDecoding(container: container, key: .score)
        
        self.idNumber = try DynamicUtils.stringTypeDecoding(container: container, key: .idNumber)
        self.email = try DynamicUtils.stringTypeDecoding(container: container, key: .email)
        self.phone = try DynamicUtils.stringTypeDecoding(container: container, key: .phone)
        self.documentType = try DynamicUtils.stringTypeDecoding(container: container, key: .documentType)
        self.firstName = try DynamicUtils.stringTypeDecoding(container: container, key: .firstName)
        self.lastName = try DynamicUtils.stringTypeDecoding(container: container, key: .lastName)
        self.code = try DynamicUtils.stringTypeDecoding(container: container, key: .code)
        self.neighborhood = try DynamicUtils.stringTypeDecoding(container: container, key: .neighborhood)
        self.institution = try DynamicUtils.stringTypeDecoding(container: container, key: .institution)
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
        self.lines = try DynamicUtils.stringTypeDecoding(container: container, key: .lines)
        self.additionalFields = try DynamicUtils.adFieldsTypeDecoding(container: container, key: .additionalFields)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_medico", idNumber = "dni", email = "email", phone = "telefono_consulta", brickId = "id_brick", categoryId = "id_categoria", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", score = "puntaje", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", additionalFields = "fields", documentType = "tipo_documento", firstName = "nombres", lastName = "apellidos", code = "codigo", neighborhood = "barrio", institution = "institucion", emailVerified = "email_verificado", hasNoEmail = "no_email", habeasData = "habeas_data", gender = "sexo", hq = "sede", mobilePhone = "telefono_movil", secretary = "nombre_secretaria", birthDate = "md_cumpleanos", birthDateSecretary = "md_cumpleanos_secretaria", joinDate = "fecha_ingreso", prepaidEntities = "entidades_prepagadas", relatedTo = "asoc", formulation = "formulacion", photo = "foto", lines = "lineas", collegeId = "id_universidad", clientId = "id_cliente", specialtyId = "id_especialidad", secondSpecialtyId = "id_especialidad_secundaria", styleId = "id_estilo", isMarked, cdi
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(brickId, forKey: .brickId)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(cityId, forKey: .cityId)
        try container.encode(countryId, forKey: .countryId)
        try container.encode(pricesListId, forKey: .pricesListId)
        try container.encode(zoneId, forKey: .zoneId)
        try container.encode(visitFTF, forKey: .visitFTF)
        try container.encode(visitVirtual, forKey: .visitVirtual)
        try container.encode(emailVerified, forKey: .emailVerified)
        try container.encode(hasNoEmail, forKey: .hasNoEmail)
        try container.encode(collegeId, forKey: .collegeId)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(specialtyId, forKey: .specialtyId)
        try container.encode(secondSpecialtyId, forKey: .secondSpecialtyId)
        try container.encode(styleId, forKey: .styleId)
        try container.encode(isMarked, forKey: .isMarked)
        
        try container.encode(score, forKey: .score)
        
        try container.encode(idNumber, forKey: .idNumber)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(documentType, forKey: .documentType)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(code, forKey: .code)
        try container.encode(neighborhood, forKey: .neighborhood)
        try container.encode(institution, forKey: .institution)
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
        try container.encode(lines, forKey: .lines)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class Group: Object, Codable, SyncEntity, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    @Persisted var name: String? = ""
    @Persisted var groupMemberList = List<GroupMember>()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
    }
    
}

class GroupMember: Object {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id: Int = 0
    @Persisted var type: String?
    @Persisted var idPanel: Int
    
}

class MediaItem: Object, Decodable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String? = "PENDING"
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    @Persisted var table: String = ""
    @Persisted var field: String = ""
    @Persisted var item: Int = 0
    @Persisted var date: String = ""
    @Persisted var ext: String = ""
    @Persisted var localItem: String = ""
}

class MovementSimple: Object, Decodable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    @Persisted var cycleId = 0
    @Persisted var panelId = 0
    @Persisted var panelType: String?
    @Persisted var dateVisit: String?
    @Persisted var realDate: String?
    @Persisted var comment: String?
    @Persisted var targetNext: String?
    @Persisted var executed: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_movimiento", cycleId = "ciclo", panelId = "id_medico", panelType = "tipo", dateVisit = "fecha_visita", realDate = "fecha_real", comment = "comentario", targetNext = "objetivo_proxima", executed = "no_efect"
    }
}

class PanelLocation: Object, Decodable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    @Persisted var address: String?
    @Persisted var latitude: Float?
    @Persisted var longitude: Float?
    @Persisted var type_: String?
    @Persisted var geocode: String?
    @Persisted var cityId: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "panel_location_id", address, latitude, longitude, type_, cityId = "city_id", geocode
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class Patient: Object, Codable, Panel, SyncEntity, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    lazy var name: String? = { "\(String(describing: firstName)) \(String(describing: lastName))" }()
    
    @Persisted var idNumber: String?
    @Persisted var type: String = "P"
    @Persisted var email: String?
    @Persisted var phone: String?
    @Persisted var brickId: Int?
    @Persisted var categoryId: Int?
    @Persisted var cityId: Int?
    @Persisted var countryId: Int?
    @Persisted var pricesListId: Int?
    @Persisted var zoneId: Int?
    @Persisted var isMarked: Int
    @Persisted var score: Float?
    @Persisted var visitFTF: Int?
    @Persisted var visitVirtual: Int?
    @Persisted var additionalFields: String?
    @Persisted var lastMovement: MovementSimple?
    @Persisted var locations: List<PanelLocation>
    @Persisted var visitingHours: List<VisitingHour>
    @Persisted var userPanel: List<UserPanel>
    
    @Persisted var firstName: String?
    @Persisted var lastName: String?
    @Persisted var habeasData: String?
    @Persisted var joinDate: String?
    
    @Persisted var clientId: Int?
    
    var brick: Brick?
    var category: Category?
    var city: City?
    var country: Country?
    var pricesList: PricesList?
    var zone: Zone?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_paciente", email = "email", phone = "telefono", cityId = "id_ciudad", countryId = "id_pais", firstName = "nombres", lastName = "apellidos", habeasData = "habeas_data", joinDate = "fecha_ingreso", clientId = "id_cliente"
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.cityId = try DynamicUtils.intTypeDecoding(container: container, key: .cityId)
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.clientId = try DynamicUtils.intTypeDecoding(container: container, key: .clientId)
        
        self.email = try DynamicUtils.stringTypeDecoding(container: container, key: .email)
        self.phone = try DynamicUtils.stringTypeDecoding(container: container, key: .phone)
        self.firstName = try DynamicUtils.stringTypeDecoding(container: container, key: .firstName)
        self.lastName = try DynamicUtils.stringTypeDecoding(container: container, key: .lastName)
        self.habeasData = try DynamicUtils.stringTypeDecoding(container: container, key: .habeasData)
        self.joinDate = try DynamicUtils.stringTypeDecoding(container: container, key: .joinDate)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_paciente", email = "email", phone = "telefono", cityId = "id_ciudad", countryId = "id_pais", firstName = "nombres", lastName = "apellidos", habeasData = "habeas_data", joinDate = "fecha_ingreso", clientId = "id_cliente"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(cityId, forKey: .cityId)
        try container.encode(countryId, forKey: .countryId)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(habeasData, forKey: .habeasData)
        try container.encode(joinDate, forKey: .joinDate)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class Pharmacy: Object, Codable, Panel, SyncEntity, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    @Persisted var idNumber: String?
    @Persisted var name: String?
    @Persisted var type: String = "F"
    @Persisted var email: String?
    @Persisted var phone: String?
    @Persisted var brickId: Int?
    @Persisted var categoryId: Int?
    @Persisted var cityId: Int?
    @Persisted var countryId: Int?
    @Persisted var pricesListId: Int?
    @Persisted var zoneId: Int?
    @Persisted var isMarked: Int
    @Persisted var score: Float?
    @Persisted var visitFTF: Int?
    @Persisted var visitVirtual: Int?
    @Persisted var additionalFields: String?
    @Persisted var lastMovement: MovementSimple?
    @Persisted var locations: List<PanelLocation>
    @Persisted var visitingHours: List<VisitingHour>
    @Persisted var userPanel: List<UserPanel>
    
    @Persisted var code: String?
    @Persisted var neighborhood: String?
    @Persisted var openDate: String?
    @Persisted var pharmacyType: String?
    @Persisted var relatedTo: String?
    @Persisted var profile: String?
    @Persisted var observations: String?
    
    @Persisted var lines: String?
    @Persisted var pharmacyChainId: Int?
    
    var brick: Brick?
    var category: Category?
    var city: City?
    var country: Country?
    var pricesList: PricesList?
    var zone: Zone?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_detfarmacia", idNumber = "nit", name = "nombre", email = "email", phone = "telefono", brickId = "id_brick", categoryId = "id_categoria", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", score = "puntaje", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", code = "cod_farma", neighborhood = "barrio", openDate = "fecha_apertura", pharmacyType = "tipofarmacia", relatedTo = "asociado", profile = "perfil", observations = "observ", lines = "lineas", pharmacyChainId = "id_genfarmacia"
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
        self.phone = try DynamicUtils.stringTypeDecoding(container: container, key: .phone)
        self.brickId = try DynamicUtils.intTypeDecoding(container: container, key: .brickId)
        self.categoryId = try DynamicUtils.intTypeDecoding(container: container, key: .categoryId)
        self.cityId = try DynamicUtils.intTypeDecoding(container: container, key: .cityId)
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.pricesListId = try DynamicUtils.intTypeDecoding(container: container, key: .pricesListId)
        self.zoneId = try DynamicUtils.intTypeDecoding(container: container, key: .zoneId)
        self.score = try DynamicUtils.floatTypeDecoding(container: container, key: .score)
        self.visitFTF = try DynamicUtils.intTypeDecoding(container: container, key: .visitFTF)
        self.visitVirtual = try DynamicUtils.intTypeDecoding(container: container, key: .visitVirtual)
        self.code = try DynamicUtils.stringTypeDecoding(container: container, key: .code)
        self.neighborhood = try DynamicUtils.stringTypeDecoding(container: container, key: .neighborhood)
        self.openDate = try DynamicUtils.stringTypeDecoding(container: container, key: .openDate)
        self.pharmacyType = try DynamicUtils.stringTypeDecoding(container: container, key: .pharmacyType)
        self.relatedTo = try DynamicUtils.stringTypeDecoding(container: container, key: .relatedTo)
        self.profile = try DynamicUtils.stringTypeDecoding(container: container, key: .profile)
        self.observations = try DynamicUtils.stringTypeDecoding(container: container, key: .observations)
        self.lines = try DynamicUtils.stringTypeDecoding(container: container, key: .lines)
        self.pharmacyChainId = try DynamicUtils.intTypeDecoding(container: container, key: .pharmacyChainId)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_detfarmacia", idNumber = "nit", name = "nombre", email = "email", phone = "telefono", brickId = "id_brick", categoryId = "id_categoria", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", score = "puntaje", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", code = "cod_farma", neighborhood = "barrio", openDate = "fecha_apertura", pharmacyType = "tipofarmacia", relatedTo = "asociado", profile = "perfil", observations = "observ", lines = "lineas", pharmacyChainId = "id_genfarmacia"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(idNumber, forKey: .idNumber)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(brickId, forKey: .brickId)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(cityId, forKey: .cityId)
        try container.encode(countryId, forKey: .countryId)
        try container.encode(pricesListId, forKey: .pricesListId)
        try container.encode(zoneId, forKey: .zoneId)
        try container.encode(score, forKey: .score)
        try container.encode(visitFTF, forKey: .visitFTF)
        try container.encode(visitVirtual, forKey: .visitVirtual)
        try container.encode(code, forKey: .code)
        try container.encode(neighborhood, forKey: .neighborhood)
        try container.encode(openDate, forKey: .openDate)
        try container.encode(pharmacyType, forKey: .pharmacyType)
        try container.encode(relatedTo, forKey: .relatedTo)
        try container.encode(profile, forKey: .profile)
        try container.encode(observations, forKey: .observations)
        try container.encode(lines, forKey: .lines)
        try container.encode(pharmacyChainId, forKey: .pharmacyChainId)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}

class PotentialProfessional: Object, Codable, Panel, SyncEntity, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    @Persisted var idNumber: String?
    @Persisted var type: String = "T"
    @Persisted var name: String?
    @Persisted var email: String?
    @Persisted var phone: String?
    @Persisted var brickId: Int?
    @Persisted var categoryId: Int?
    @Persisted var cityId: Int?
    @Persisted var countryId: Int?
    @Persisted var pricesListId: Int?
    @Persisted var zoneId: Int?
    @Persisted var isMarked: Int
    @Persisted var score: Float?
    @Persisted var visitFTF: Int?
    @Persisted var visitVirtual: Int?
    @Persisted var additionalFields: String?
    @Persisted var lastMovement: MovementSimple?
    @Persisted var locations: List<PanelLocation>
    @Persisted var visitingHours: List<VisitingHour>
    @Persisted var userPanel: List<UserPanel>
    
    @Persisted var cityName: String?
    @Persisted var address: String?
    @Persisted var specialtyName: String?
    @Persisted var joinDate: String?
    @Persisted var observations: String?
    
    var brick: Brick?
    var category: Category?
    var city: City?
    var country: Country?
    var pricesList: PricesList?
    var zone: Zone?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id", idNumber = "cedula", name = "nombre", email = "email", phone = "telefono", countryId = "id_pais", cityName = "ciudad", address = "direccion", specialtyName = "especialidad", joinDate = "fecha_ingre", observations = "observaciones"
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
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.cityName = try DynamicUtils.stringTypeDecoding(container: container, key: .cityName)
        self.address = try DynamicUtils.stringTypeDecoding(container: container, key: .address)
        self.specialtyName = try DynamicUtils.stringTypeDecoding(container: container, key: .specialtyName)
        self.observations = try DynamicUtils.stringTypeDecoding(container: container, key: .observations)
        self.email = try DynamicUtils.stringTypeDecoding(container: container, key: .email)
        self.phone = try DynamicUtils.stringTypeDecoding(container: container, key: .phone)
        self.joinDate = try DynamicUtils.stringTypeDecoding(container: container, key: .joinDate)
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id", idNumber = "cedula", name = "nombre", email = "email", phone = "telefono", countryId = "id_pais", cityName = "ciudad", address = "direccion", specialtyName = "especialidad", joinDate = "fecha_ingre", observations = "observaciones"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(idNumber, forKey: .idNumber)
        try container.encode(countryId, forKey: .countryId)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
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
}

class RequestDay: Object, Codable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
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

class UserPanel: Object, Decodable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
    @Persisted var transactionStatus: String? = ""
    @Persisted var transactionPending: String? = ""
    @Persisted var transactionResponse: String? = ""
    
    @Persisted var userID = 0
    @Persisted var visitsFee = 0
    @Persisted var visitsCycle = 0
    @Persisted var visitsLastCycle = 0
    
    private enum CodingKeys: String, CodingKey {
        case id = "id", userID = "id_usuario", visitsFee = "num_visitas", visitsCycle = "noVisitsCycle", visitsLastCycle = "noVisitsLastCycle"
    }
}
