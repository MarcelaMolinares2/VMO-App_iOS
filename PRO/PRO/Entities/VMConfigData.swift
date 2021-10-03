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
    @Persisted var id = ""
    @Persisted var stock = 0
    @Persisted var delivered = 0
    @Persisted var dueDate: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "lote", dueDate = "due_date", stock, delivered
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

class Category: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String?
    @Persisted var scoreStart: Float?
    @Persisted var scoreEnd: Float?
    @Persisted var visitsFeeMedic: Int?
    @Persisted var visitsFeePharmacy: Int?
    @Persisted var visitsFeeClient: Int?
    @Persisted var isDefault: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_categoria", name = "categorias", scoreStart = "puntaje_i", scoreEnd = "puntaje_f", visitsFeeMedic = "num_visitas_m", visitsFeePharmacy = "num_visitas_f", visitsFeeClient = "num_visitas_c", isDefault = "predefinida"
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

class Country: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var name: String?
    
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
    @Persisted var cycle = 0
    @Persisted var year = 0
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_ciclo", cycle = "ciclo", year = "ano"
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
    
    var displayName: String {
        return "\(cycle) - \(year)"
    }
}

class FreeDayReason: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var content: String?
    @Persisted var availableIn: String?
    
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
    @Persisted var name: String?
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
    @Persisted var code: String?
    @Persisted var name: String?
    @Persisted var competitors: String?
    @Persisted var hasToVerifyStock = 0
    @Persisted var lineId: Int?
    @Persisted var countryId: Int?
    
    var line: Line?
    var country: Country?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_producto", code = "codigo", name = "producto", hasToVerifyStock = "verificar_existencia", lineId = "id_linea", countryId = "id_pais", competitors
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
    @Persisted var name: String?
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
    @Persisted var name: String?
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
    @Persisted var dni: String?
    @Persisted var name: String?
    @Persisted var email: String?
    @Persisted var type: Int?
    @Persisted var city: Int?
    @Persisted var zone: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_usuario", dni = "identificacion", name = "nombre", type = "tipo", city = "id_ciudad", zone = "id_zona", email
    }
    
    static func primaryCodingKey() -> String {
        let codingKey: CodingKeys
        codingKey = .id
        return codingKey.rawValue
    }
}

class VisitingHour: Object, Codable {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var id = 0
    @Persisted var dayOfWeek: Int?
    @Persisted var hourStart: Int?
    @Persisted var hourEnd: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "visiting_hour_id", dayOfWeek = "day_of_week", hourStart = "hour_start", hourEnd = "hour_end"
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
