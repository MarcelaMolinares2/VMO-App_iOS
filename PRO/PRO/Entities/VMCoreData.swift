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

/*
var neighborhood: String? { get set }
var institution: String? { get set }
var specialty: Specialty? { get set }
var contacts: List<Contact> { get set }
*/

protocol SyncEntity {
    var objectId: ObjectId { get set }
    var id: Int { get set }
    var transactionStatus: String? { get set }
    var transactionPending: String? { get set }
    var transactionResponse: String? { get set }
}

protocol Panel {
    var idNumber: String? { get set }
    var type: String { get set }
    var name: String? { get set }
    var email: String? { get set }
    var phone: String? { get set }
    
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

class Client: Object, Codable, Panel, SyncEntity {
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
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}
/*
class ClientOld: Object, Codable, Panel {
    @Persisted var type = "C"
    @Persisted var neighborhood: String?
    @Persisted var institution: String?
    
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String?
    @Persisted var abbreviation: String?
    @Persisted var nit: String?
    @Persisted var phone: String?
    @Persisted var email: String?
    @Persisted var comment: String?
    @Persisted var isMarked = 0
    @Persisted var shouldVisitFTF = 0
    @Persisted var shouldVisitVirtual = 0
    @Persisted var purchasingManager: String?
    @Persisted var financialManager: String?
    @Persisted var paymentDayStart = 0
    @Persisted var paymentDayEnd = 0
    @Persisted var orderDayStart = 0
    @Persisted var orderDayEnd = 0
    //@Persisted var dataStock: String?
    @Persisted var transaction = ""
    @Persisted var lastUpdate = ""
    
    var brick: Brick?
    var category: Category?
    var city: City?
    var country: Country?
    var lastMovement: MovementSimple?
    var pricesList: PricesList?
    var specialty: Specialty?
    var zone_: Zone?
    var locations = List<PanelLocation>()
    var contacts = List<Contact>()
    var userPanel = List<UserPanel>()
    var visitingHours = List<VisitingHour>()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_cliente", name = "nombre", abbreviation = "abreviatura", nit = "nit", phone = "telefono", email = "email", comment = "observaciones", shouldVisitFTF = "visit_ftf", shouldVisitVirtual = "visit_virtual", purchasingManager = "gerente_compras", financialManager = "gerente_financiero", paymentDayStart = "fecha_pago_i", paymentDayEnd = "fecha_pago_f", orderDayStart = "fecha_pedido_i", orderDayEnd = "fecha_pedido_f", lastMovement = "last_movement", pricesList = "prices_list", userPanel = "panel_user", visitingHours = "visiting_hours", zone_ = "zone", isMarked, locations, contacts
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(abbreviation, forKey: .abbreviation)
        try container.encode(nit, forKey: .nit)
        try container.encode(phone, forKey: .phone)
        try container.encode(email, forKey: .email)
        try container.encode(comment, forKey: .comment)
        try container.encode(shouldVisitFTF, forKey: .shouldVisitFTF)
        try container.encode(shouldVisitVirtual, forKey: .shouldVisitVirtual)
        //try container.encode(dataStock, forKey: .dataStock)
        try container.encode(brick?.id, forKey: Client.CodingKeys(rawValue: "brick")!)
        try container.encode(city?.id, forKey: Client.CodingKeys(rawValue: "id_ciudad")!)
        try container.encode(country?.id, forKey: Client.CodingKeys(rawValue: "id_pais")!)
        try container.encode(zone_?.id, forKey: Client.CodingKeys(rawValue: "zona")!)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}
*/

class Contact: Object, Decodable, SyncEntity {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted(indexed: true) var id = 0
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
    @Persisted var type: String?
    @Persisted var transaction = ""
    @Persisted var lastUpdate = ""
    @Persisted var cityId = 0
    @Persisted var countryId = 0
    var city: City?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_contacto", name = "nombres", position = "cargo", address = "direccion", phone = "telefono", mobilePhone = "celular", email = "correo_electronico", birthMonth = "mes_cumpleanos", birthDay = "dia_cumpleanos", specialty = "especialidad", hd = "habeas_data", type = "tipo", cityId = "ciudad"
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

class Doctor: Object, Codable, Panel, SyncEntity {
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
    @Persisted var categoryId: Int?
    @Persisted var cityId: Int?
    @Persisted var countryId: Int?
    @Persisted var pricesListId: Int?
    @Persisted var zoneId: Int?
    @Persisted var isMarked: Int
    @Persisted var score: Float?
    @Persisted var visitFTF: Int?
    @Persisted var visitVirtual: Int?
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
        case id = "id_medico", idNumber = "dni", email = "email", phone = "telefono_consulta", brickId = "id_brick", categoryId = "id_categoria", cityId = "id_ciudad", countryId = "id_pais", pricesListId = "id_lista_precios", zoneId = "id_zona", score = "puntaje", visitFTF = "visit_ftf", visitVirtual = "visit_virtual", documentType = "tipo_documento", firstName = "nombres", lastName = "apellidos", code = "codigo", neighborhood = "barrio", institution = "institucion", emailVerified = "email_verificado", hasNoEmail = "no_email", habeasData = "habeas_data", gender = "sexo", hq = "sede", mobilePhone = "telefono_movil", secretary = "nombre_secretaria", birthDate = "md_cumpleanos", birthDateSecretary = "md_cumpleanos_secretaria", joinDate = "fecha_ingreso", prepaidEntities = "entidades_prepagadas", relatedTo = "asoc", formulation = "formulacion", photo = "foto", lines = "lineas", collegeId = "id_universidad", clientId = "id_cliente", specialtyId = "id_especialidad", secondSpecialtyId = "id_especialidad_secundaria", styleId = "id_estilo", isMarked, cdi
    }
    
    private enum EncodingKeys: String, CodingKey {
        case id = "id_medico"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(id, forKey: .id)
        /*
         visitingHours = "visiting_hours"
         locations
         */
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
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

class Patient: Object, Codable, Panel, SyncEntity {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class Pharmacy: Object, Codable, Panel, SyncEntity {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}

class PotentialProfessional: Object, Codable, Panel, SyncEntity {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
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