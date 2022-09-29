//
//  VMConfigData.swift
//  PRO
//
//  Created by VMO on 2/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import RealmSwift

class AdvertisingMaterial: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var code: String?
    @Persisted var name: String?
    @Persisted var type: Int?
    @Persisted var countryId: Int?
    @Persisted var isSample: String?
    @Persisted var isActive: Int?
    @Persisted var isOrderAvailable: Int?
    @Persisted var isTransferenceAvailable: Int?
    @Persisted var color: String?
    @Persisted var price: Float?
    @Persisted var description_: String?
    @Persisted var sets = List<AdvertisingMaterialSet>()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_material", code = "codigo", name = "nombre", type = "tipo", countryId = "id_pais", isSample = "muestra_m", isActive = "activo", isOrderAvailable = "disponible_pedidos", isTransferenceAvailable = "transferencia", color, price = "costo", description_ = "descripcion", sets
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.code = try DynamicUtils.stringTypeDecoding(container: container, key: .code)
        self.name = try DynamicUtils.stringTypeDecoding(container: container, key: .name)
        self.type = try DynamicUtils.intTypeDecoding(container: container, key: .type)
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.isSample = try DynamicUtils.stringTypeDecoding(container: container, key: .isSample)
        self.isActive = try DynamicUtils.intTypeDecoding(container: container, key: .isActive)
        self.isOrderAvailable = try DynamicUtils.intTypeDecoding(container: container, key: .isOrderAvailable)
        self.isTransferenceAvailable = try DynamicUtils.intTypeDecoding(container: container, key: .isTransferenceAvailable)
        self.color = try DynamicUtils.stringTypeDecoding(container: container, key: .color)
        self.price = try DynamicUtils.floatTypeDecoding(container: container, key: .price)
        self.description_ = try DynamicUtils.stringTypeDecoding(container: container, key: .description_)
        self.sets = try DynamicUtils.listTypeDecoding(container: container, key: .sets)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class AdvertisingMaterialSet: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var label = ""
    @Persisted var stock = 0
    @Persisted var delivered = 0
    @Persisted var dueDate: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "material_set_id", label = "set_id", dueDate = "due_date", stock, delivered
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.label = try DynamicUtils.stringTypeDecoding(container: container, key: .label)
        self.stock = try DynamicUtils.intTypeDecoding(container: container, key: .stock)
        self.delivered = try DynamicUtils.intTypeDecoding(container: container, key: .delivered)
        self.dueDate = try DynamicUtils.stringTypeDecoding(container: container, key: .dueDate)
    }
}

class AdvertisingMaterialPlain: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var code: String?
    @Persisted var name: String?
    @Persisted var type: Int?
    @Persisted var countryId: Int?
    @Persisted var isActive: Int?
    @Persisted var description_: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_material", code = "codigo", name = "nombre", type = "tipo", countryId = "id_pais", isActive = "activo", description_ = "descripcion"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class Brick: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String?
    @Persisted var city: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_brick", name = "brick", city = "ciudad"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class City: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String?
    @Persisted var region: Int?
    @Persisted var indicator: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_ciudad", name = "Ciudad", region = "id_region", indicator = "indicador"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}

class College: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String?
    @Persisted var initials: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_universidad", name = "nombre", initials = "sigla"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}

class Config: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = ""
    @Persisted var value = 0
    @Persisted var complement: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "key_", value = "value_", complement = "complemento"
    }
    
    static func get(key: String, defaultValue: Int = 0) -> Config {
        if let config = try! Realm().objects(self).filter("id = %@", key).first {
            return config
        }
        let config = Config()
        config.id = key
        config.value = defaultValue
        return config
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class ContactControlType: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "contact_control_type_id", name = "name_"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class Country: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_pais", name = "pais"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class Cycle: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name = 0
    @Persisted var alias = ""
    @Persisted var year = 0
    @Persisted var lineId = 0
    @Persisted var countryId = 0
    @Persisted var isActive = ""
    @Persisted var dateFrom = ""
    @Persisted var dateTo = ""
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_ciclo", name = "ciclo", alias, year = "ano", lineId = "id_linea", countryId = "id_pais", isActive = "activo", dateFrom = "fecha_inicial", dateTo = "fecha_final"
    }
    
    override init() {
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.name = try DynamicUtils.intTypeDecoding(container: container, key: .name)
        self.alias = try DynamicUtils.stringTypeDecoding(container: container, key: .alias)
        self.year = try DynamicUtils.intTypeDecoding(container: container, key: .year)
        self.lineId = try DynamicUtils.intTypeDecoding(container: container, key: .lineId)
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.isActive = try DynamicUtils.stringTypeDecoding(container: container, key: .isActive)
        self.dateFrom = try DynamicUtils.stringTypeDecoding(container: container, key: .dateFrom)
        self.dateTo = try DynamicUtils.stringTypeDecoding(container: container, key: .dateTo)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
    var displayName: String {
        return "\(name) - \(year)"
    }
}

class ExpenseConcept: Object, Codable, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_concepto", name = "concepto"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class MovementFailReason: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var panelType: String
    @Persisted var environment: String
    @Persisted var content: String
    @Persisted var countryId: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case id = "movement_fail_reason_id", panelType = "panel_type", environment, content, countryId = "country_id"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class FreeDayReason: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var content: String
    @Persisted var availableIn: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "free_day_reason_id", availableIn = "available_in", content
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class Line: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String
    @Persisted var abbreviation: String?
    @Persisted var countryId: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_linea", name = "linea", abbreviation = "abreviatura", countryId = "id_pais"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class Menu: Object, Codable, Identifiable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var languageTag: String
    @Persisted var routerLink: String
    @Persisted var parent: Int = 0
    @Persisted var icon: String
    @Persisted var order: Int = 0
    @Persisted var module: String
    @Persisted var userTypes: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "menu_id", languageTag = "language_tag", routerLink = "router_link", parent, icon, order = "order_", module, userTypes = "user_types"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class PanelCategory: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String?
    @Persisted var scoreStart: Float?
    @Persisted var scoreEnd: Float?
    @Persisted var isDefault: Int?
    @Persisted var categoryTypeId: Int?
    @Persisted var visitsFeeDoctor: Int = 1
    @Persisted var visitsFeePharmacy: Int = 1
    @Persisted var visitsFeeClient: Int = 1
    @Persisted var visitsFeePatient: Int = 1
    @Persisted var visitsFeePotential: Int = 1
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_categoria", name = "categorias", scoreStart = "puntaje_i", scoreEnd = "puntaje_f", isDefault = "predefinida", categoryTypeId = "category_type_id", visitsFeeDoctor = "num_visitas_m", visitsFeePharmacy = "num_visitas_f", visitsFeeClient = "num_visitas_c", visitsFeePatient = "num_visitas_p", visitsFeePotential = "num_visitas_t"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.name = try DynamicUtils.stringTypeDecoding(container: container, key: .name)
        self.scoreStart = try DynamicUtils.floatTypeDecoding(container: container, key: .scoreStart)
        self.scoreEnd = try DynamicUtils.floatTypeDecoding(container: container, key: .scoreEnd)
        self.isDefault = try DynamicUtils.intTypeDecoding(container: container, key: .isDefault)
        self.categoryTypeId = try DynamicUtils.intTypeDecoding(container: container, key: .categoryTypeId)
        self.visitsFeeDoctor = try DynamicUtils.intTypeDecoding(container: container, key: .visitsFeeDoctor)
        self.visitsFeePharmacy = try DynamicUtils.intTypeDecoding(container: container, key: .visitsFeePharmacy)
        self.visitsFeeClient = try DynamicUtils.intTypeDecoding(container: container, key: .visitsFeeClient)
        self.visitsFeePatient = try DynamicUtils.intTypeDecoding(container: container, key: .visitsFeePatient)
        self.visitsFeePotential = try DynamicUtils.intTypeDecoding(container: container, key: .visitsFeePotential)
    }
    
}

class PanelDeleteReason: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var panelType: String
    @Persisted var content: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "panel_delete_reason_id", panelType = "panel_type", content
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class PharmacyChain: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String?
    @Persisted var dni: String?
    @Persisted var address: String?
    @Persisted var phone: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_genfarmacia", name = "nombre", dni = "identificacion", address = "direccion", phone = "tel"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class PharmacyType: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "pharmacy_type_id", name = "name_"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class PredefinedComment: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var content: String
    @Persisted var table: String
    @Persisted var field: String
    @Persisted var types: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_comentario", content = "contenido", table = "tabla", field = "campo", types = "tipo"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class PricesList: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String?
    @Persisted var description_: String?
    @Persisted var countryId: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_lista", name = "nombre", description_ = "descripcion", countryId = "id_pais"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}

class Product: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String
    @Persisted var code: String?
    @Persisted var presentation: String?
    @Persisted var competitors: String?
    @Persisted var verifyExistence: Int?
    @Persisted var brandId: Int?
    @Persisted var lineId: Int?
    @Persisted var countryId: Int?
    @Persisted var status: Int = 1
    
    @Persisted var pharmacyChains: List<ProductPharmacyChain>
    
    var line: Line?
    var country: Country?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_producto", name = "producto", code = "codigo", presentation = "id_presentacion", competitors = "competidores",
             verifyExistence = "verificar_existencia", brandId = "brand_id", lineId = "id_linea", countryId = "id_pais", status = "status_", pharmacyChains = "pharmacy_chains"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class ProductBrand: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String
    @Persisted var status: Int = 1
    
    private enum CodingKeys: String, CodingKey {
        case id = "product_brand_id", name = "name_", status = "status_"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class ProductPharmacyChain: Object, Codable {
    @Persisted var id: Int? = 0
    @Persisted var pharmacyChainId: Int
    @Persisted var eanCode: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "pharmacy_chain_product_id", pharmacyChainId = "pharmacy_chain_id", eanCode = "ean_code"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class Specialty: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String
    @Persisted var isPrimary: Int?
    @Persisted var isSecondary: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_especialidad", name = "especialidad", isPrimary = "primaria", isSecondary = "secundaria"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}

class Style: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String
    @Persisted var color: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_estilo", name = "estilo", color = "color"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
}

class User: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var dni: String
    @Persisted var name: String
    @Persisted var email: String?
    @Persisted var type: Int = 1
    @Persisted var countryId: Int
    @Persisted var regionId: Int?
    @Persisted var cityId: Int
    @Persisted var zoneId: Int
    @Persisted var lineId: Int?
    
    @Persisted var hierarchy: List<UserHierarchy>
    @Persisted var permissions: List<UserPermission>
    @Persisted var permissionsInCharge: List<UserPermissionInCharge>
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_usuario", dni = "identificacion", name = "nombre", email, type = "tipo", countryId = "id_pais", regionId = "id_region",
             cityId = "id_ciudad", zoneId = "id_zona", lineId = "id_linea", hierarchy, permissions, permissionsInCharge = "permissions_in_charge"
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try DynamicUtils.intTypeDecoding(container: container, key: .id)
        self.dni = try DynamicUtils.stringTypeDecoding(container: container, key: .dni)
        self.name = try DynamicUtils.stringTypeDecoding(container: container, key: .name)
        self.email = try DynamicUtils.stringTypeDecoding(container: container, key: .email)
        self.type = try DynamicUtils.intTypeDecoding(container: container, key: .type)
        self.countryId = try DynamicUtils.intTypeDecoding(container: container, key: .countryId)
        self.regionId = try DynamicUtils.intTypeDecoding(container: container, key: .regionId)
        self.cityId = try DynamicUtils.intTypeDecoding(container: container, key: .cityId)
        self.zoneId = try DynamicUtils.intTypeDecoding(container: container, key: .zoneId)
        self.lineId = try DynamicUtils.intTypeDecoding(container: container, key: .lineId)
        self.hierarchy = try DynamicUtils.listTypeDecoding(container: container, key: .hierarchy)
        self.permissions = try DynamicUtils.listTypeDecoding(container: container, key: .permissions)
        self.permissionsInCharge = try DynamicUtils.listTypeDecoding(container: container, key: .permissionsInCharge)
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class UserHierarchy: Object, Codable {
    @Persisted var id = 0
    @Persisted var userId: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "user_hierarchy_id", userId = "user_id"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class UserPermission: Object, Codable {
    @Persisted var id = 0
    @Persisted var module: String
    @Persisted var environment: String
    @Persisted var read: Int
    @Persisted var create: Int
    @Persisted var update: Int
    @Persisted var delete: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "user_permission_id", module, environment, read = "read_", create = "create_", update = "update_", delete = "delete_"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class UserPermissionInCharge: Object, Codable {
    @Persisted var id = 0
    @Persisted var module: String
    @Persisted var environment: String
    @Persisted var read: Int
    @Persisted var create: Int
    @Persisted var update: Int
    @Persisted var delete: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "user_permission_in_charge_id", module, environment, read = "read_", create = "create_", update = "update_", delete = "delete_"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class UserPreference: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var userId: Int
    @Persisted var environment: String
    @Persisted var module: String
    @Persisted var type: String
    @Persisted var value: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "user_preference_id", userId = "user_id", environment, module, type = "type_", value = "value_"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class Zone: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String?
    @Persisted var city: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_zona", name = "zona", city = "id_ciudad"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class CurrentOperation: Object, Identifiable {
    @Persisted(primaryKey: true) var type: String
    @Persisted var current: String = ""
    @Persisted var status: Int = 0
}
