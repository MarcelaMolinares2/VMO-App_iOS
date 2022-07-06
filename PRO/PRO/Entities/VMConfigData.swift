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
        case id = "id_material", name = "nombre", type = "tipo", countryId = "id_pais", isSample = "muestra_m", isActive = "activo", isOrderAvailable = "disponible_pedidos", isTransferenceAvailable = "transferencia", color, price = "costo", description_ = "descripcion", sets
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
    @Persisted var name = "0"
    @Persisted var year = 0
    @Persisted var lineId = 0
    @Persisted var countryId = 0
    @Persisted var isActive = ""
    @Persisted var dateFrom = ""
    @Persisted var dateTo = ""
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_ciclo", name = "ciclo", year = "ano", lineId = "id_linea", countryId = "id_pais", isActive = "activo", dateFrom = "fecha_inicial", dateTo = "fecha_final"
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

class FailReason: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var panelType: String
    @Persisted var environment: String
    @Persisted var content: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "free_day_reason_id", panelType = "panel_type", environment, content
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

class PanelCategory: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String?
    @Persisted var scoreStart: Float?
    @Persisted var scoreEnd: Float?
    @Persisted var isDefault: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_categoria", name = "categorias", scoreStart = "puntaje_i", scoreEnd = "puntaje_f", isDefault = "predefinida"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
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
    
    var line: Line?
    var country: Country?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_producto", name = "producto", code = "codigo", presentation = "id_presentacion", competitors = "competidores",
             verifyExistence = "verificar_existencia", brandId = "brand_id", lineId = "id_linea", countryId = "id_pais"
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
    
    private enum CodingKeys: String, CodingKey {
        case id = "product_brand_id", name = "name_"
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
        case id = "id_usuario", dni = "identificacion", name = "nombre", type = "tipo", countryId = "id_pais", regionId = "id_region",
             cityId = "id_ciudad", zoneId = "id_zona", lineId = "id_linea", hierarchy, permissions, permissionsInCharge = "permissions_in_charge"
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
