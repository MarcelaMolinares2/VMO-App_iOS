//
//  EnvObjects.swift
//  PRO
//
//  Created by VMO on 24/08/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import Foundation
import SwiftUI
import RealmSwift

class GenericSelectableItem {
    var id: String = ""
    var label: String = ""
    var complement: String = ""
    var selected: Bool = false
    
    init(id: String, label: String) {
        self.id = id
        self.label = label
    }
    
    init(id: String, label: String, complement: String) {
        self.id = id
        self.label = label
        self.complement = complement
    }
}

class GenericSelectablePanelItem {
    var selected: Bool = false
    var panel: Panel & SyncEntity
    
    init(panel: Panel & SyncEntity) {
        self.panel = panel
    }
}

struct GenericGridItem: Hashable {
    var id: String
    var color: Color
    var icon: String
    var name: String
}

struct DynamicFilter: Identifiable {
    let id = UUID()
    var key: String
    var label: String
    var controlType: String
    var sourceType: String
    var values: [String]
    var chips: [ChipItem] = []
    var modalOpen: Bool = false
    
    init(key: String, label: String, controlType: String, sourceType: String, values: [String]) {
        self.key = key
        self.label = label
        self.controlType = controlType
        self.sourceType = sourceType
        self.values = values
    }
}

struct ChipItem: Identifiable {
    let id = UUID()
    var label: String
    var image: String
    var onApplyTapped: () -> Void
    
    init(label: String, image: String, onApplyTapped: @escaping () -> Void) {
        self.label = label
        self.image = image
        self.onApplyTapped = onApplyTapped
    }
}

struct GenericPickerItem: Identifiable {
    let id = UUID()
    var value: Int
    var label: String
}

struct SortModel {
    var key: String
    var ascending: Bool
    
    init(key: String, ascending: Bool) {
        self.key = key
        self.ascending = ascending
    }
}

enum GenericListLayout {
    case list, map
}

struct BindingWrapperToast {
    let uuid: UUID = UUID()
    @Binding var error: String
    @Binding var show: Bool
}

class ModalToggle: ObservableObject {
    @Published var status: Bool = false
}

struct BindingWrapper {
    let uuid: UUID = UUID()
    @Binding var binding: [String]
}


class DynamicConditionForm: Decodable {
    var editable: [DynamicConditionGroup] = []
    var required: [DynamicConditionGroup] = []
    var value: [DynamicConditionGroup] = []
    var visible: [DynamicConditionGroup] = []
    
    private enum CodingKeys: String, CodingKey {
        case editable, required, value, visible
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.editable = try container.decode([DynamicConditionGroup].self, forKey: .editable)
        } catch DecodingError.keyNotFound {
            self.editable = [DynamicConditionGroup]()
        }
        do {
            self.required = try container.decode([DynamicConditionGroup].self, forKey: .required)
        } catch DecodingError.keyNotFound {
            self.required = [DynamicConditionGroup]()
        }
        do {
            self.value = try container.decode([DynamicConditionGroup].self, forKey: .value)
        } catch DecodingError.keyNotFound {
            self.value = [DynamicConditionGroup]()
        }
        do {
            self.visible = try container.decode([DynamicConditionGroup].self, forKey: .visible)
        } catch DecodingError.keyNotFound {
            self.visible = [DynamicConditionGroup]()
        }
    }
    
    init() {
    }
}

class DynamicConditionGroup: Decodable {
    var conditions: [DynamicConditionRow] = []
    
    private enum CodingKeys: String, CodingKey {
        case result, conditions
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            self.conditions = try container.decode([DynamicConditionRow].self, forKey: .conditions)
        } catch DecodingError.typeMismatch {
            self.conditions = []
        }
    }
    
}

class DynamicConditionRow: Decodable {
    var field = ""
    var op = "" // equal,not-equal,between,less,more
    var value: [String] = []
    var current: [String] = []
    
    private enum CodingKeys: String, CodingKey {
        case field, op = "operator", value, current
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            do {
                self.value = try container.decode([String].self, forKey: .value)
            } catch DecodingError.typeMismatch {
                do {
                    let value = try container.decode(String.self, forKey: .value)
                    self.value = value.components(separatedBy: ",")
                } catch DecodingError.typeMismatch {
                    do {
                        let value = try container.decode([Int].self, forKey: .value)
                        self.value = value.map { String($0) }
                    } catch DecodingError.typeMismatch {
                        do {
                            let value = try container.decode(Int.self, forKey: .value)
                            self.value = String(value).components(separatedBy: ",")
                        } catch DecodingError.typeMismatch {
                            do {
                                let value = try container.decode(Bool.self, forKey: .value)
                                self.value = [value ? "1" : "0"]
                            } catch DecodingError.typeMismatch {
                                self.value = []
                            }
                        }
                    }
                }
            }
        } catch DecodingError.valueNotFound {
            self.value = []
        }
        self.current = []
        
        self.field = try container.decode(String.self, forKey: .field)
        self.op = try container.decode(String.self, forKey: .op)
    }
}

class DynamicFormFieldOptions {
    var table: String = ""
    var op: FormAction
    var type: String = ""
    var panelType: String = ""
    var item: Int = 0
    var objectId: ObjectId
    
    init(table: String, op: FormAction, panelType: String = "") {
        self.table = table
        self.op = op
        self.panelType = panelType
        self.objectId = ObjectId()
    }
}

struct DynamicFormFieldUserOpts: Decodable {
    var country: Bool = true
    var city: Bool = true
    var user: Bool = true
    var createUserTypes: String
    var updateUserTypes: String
    
    private enum CodingKeys: String, CodingKey {
        case createUserTypes, updateUserTypes
    }
}

struct DynamicFormFieldMoreOptions: Decodable {
    var table: String = ""
    var categoryType: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case table, categoryType
    }
}

class CustomAdditionalField: Codable {
    var data: String
}

class MasterDashboardTab {
    var key: String = ""
    var icon: String = ""
    var label: String = ""
    var route: String = ""
    
    init(key: String, icon: String, label: String, route: String) {
        self.key = key
        self.icon = icon
        self.label = label
        self.route = route
    }
    
}

struct MovementTab: Identifiable {
    var id = UUID()
    var key: String = ""
    var icon: String = ""
    var label: String = ""
    var required: Bool = false
    
    init(key: String, icon: String, label: String, required: Bool) {
        self.key = key
        self.icon = icon
        self.label = label
        self.required = required
    }
    
}

class MasterLaboratory: Codable {
    var id: Int = 0
    var name: String = ""
    var hash: String = ""
    var path: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case id, name = "nombre", hash = "hash_", path
    }
    
}

class MasterLaboratoryUser: Codable {
    var id: Int = 0
    var name: String = ""
    var dni: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_usuario", name = "nombre", dni = "identificacion"
    }
    
}

class AdvertisingMaterialDeliveryReport: Codable {
    var id: Int = 0
    var transactionType: String = "D"
    var operationType: String = "O"
    var quantity: Int = 0
    var comment: String? = ""
    var date: String = ""
    
    var material: AdvertisingMaterial?
    var set: AdvertisingMaterialSet?
    var madeBy: User?
    
    private enum CodingKeys: String, CodingKey {
        case id = "material_operation_id", transactionType = "transaction_type", operationType = "operation_type", quantity, comment = "observations", date = "date_time", material, set = "material_set", madeBy = "made_by_user"
    }
    
}

class PanelLocationModel: ObservableObject, Identifiable {
    var uuid = UUID()
    @Published var id: Int = 0
    @Published var address: String = ""
    @Published var latitude: Float = 0
    @Published var longitude: Float = 0
    @Published var type: String = ""
    @Published var geocode: String = ""
    @Published var cityId: Int = 0
    @Published var complement: String = ""
    
    init() {
    }
    
    init(id: Int, address: String, latitude: Float, longitude: Float, type: String, geocode: String, cityId: Int, complement: String) {
        self.id = id
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.type = type
        self.geocode = geocode
        self.cityId = cityId
        self.complement = complement
    }
}

class PanelContactControlModel: ObservableObject, Identifiable {
    var contactControlType: ContactControlType
    @Published var status: Bool = false
    
    init(contactControlType: ContactControlType, status: Bool) {
        self.contactControlType = contactControlType
        self.status = status
    }
}

class PanelVisitingHourModel: ObservableObject, Identifiable {
    @Published var dayOfWeek: Int = 0
    @Published var amHourStart: Date
    @Published var amHourEnd: Date
    @Published var pmHourStart: Date
    @Published var pmHourEnd: Date
    @Published var amStatus: Bool = false
    @Published var pmStatus: Bool = false
    
    init(dayOfWeek: Int) {
        self.dayOfWeek = dayOfWeek
        self.amHourStart = Utils.strToDate(value: "08:00", format: "HH:mm")
        self.amHourEnd = Utils.strToDate(value: "12:30", format: "HH:mm")
        self.pmHourStart = Utils.strToDate(value: "13:30", format: "HH:mm")
        self.pmHourEnd = Utils.strToDate(value: "18:00", format: "HH:mm")
        self.amStatus = false
        self.pmStatus = false
    }
    
    init(dayOfWeek: Int, amHourStart: String, amHourEnd: String, pmHourStart: String, pmHourEnd: String, amStatus: Bool, pmStatus: Bool) {
        self.dayOfWeek = dayOfWeek
        self.amHourStart = Utils.strToDate(value: amHourStart, format: "HH:mm")
        self.amHourEnd = Utils.strToDate(value: amHourEnd, format: "HH:mm")
        self.pmHourStart = Utils.strToDate(value: pmHourStart, format: "HH:mm")
        self.pmHourEnd = Utils.strToDate(value: pmHourEnd, format: "HH:mm")
        self.amStatus = amStatus
        self.pmStatus = pmStatus
    }
}

class MovementProductStockModel: ObservableObject, Identifiable {
    @Published var productId: Int = 0
    @Published var hasStock: Bool = false
    @Published var quantity: Float = 0
    @Published var noStockReason: String = ""
}

class MovementProductShoppingModel: ObservableObject, Identifiable {
    @Published var productId: Int = 0
    @Published var price: Float = 0
    @Published var competitors = [MovementProductShoppingCompetitorModel]()
}

class MovementProductShoppingCompetitorModel: ObservableObject, Identifiable {
    var id: String = ""
    @Published var price: Float = 0
}

class MovementProductTransferenceModel: ObservableObject, Identifiable {
    @Published var productId: Int = 0
    @Published var quantity: Float = 0
    @Published var price: Float = 0
    @Published var bonusProduct: Int = 0
    @Published var bonusQuantity: Float = 0
}

class PanelCategorizationSettings: Decodable {
    var automatic: Bool = false
    var attachVisitsFee: Bool = false
    var allowEditVisitsFee: Bool = true
    
    private enum CodingKeys: String, CodingKey {
        case automatic, attachVisitsFee, allowEditVisitsFee
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.automatic = try DynamicUtils.boolTypeDecoding(container: container, key: .automatic)
        self.attachVisitsFee = try DynamicUtils.boolTypeDecoding(container: container, key: .attachVisitsFee)
        self.allowEditVisitsFee = try DynamicUtils.boolTypeDecoding(container: container, key: .allowEditVisitsFee)
    }
    
    init() {}
    
}

enum FormAction {
    case create, update, view
}

struct EnumMap<Enum: CaseIterable & Hashable, Value> {
    private let values: [Enum : Value]
    
    init(resolver: (Enum) -> Value) {
        var values = [Enum : Value]()
        
        for key in Enum.allCases {
            values[key] = resolver(key)
        }
        
        self.values = values
    }
    
    subscript(key: Enum) -> Value {
        // Here we have to force-unwrap, since there's no way
        // of telling the compiler that a value will always exist
        // for any given key. However, since it's kept private
        // it should be fine - and we can always add tests to
        // make sure things stay safe.
        return values[key]!
    }
}
