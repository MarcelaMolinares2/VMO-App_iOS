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
                    let value = try container.decode(Int.self, forKey: .value)
                    self.value = String(value).components(separatedBy: ",")
                }
            }
        }
        /*do {
            self.current = try container.decode([String].self, forKey: .current)
        } catch DecodingError.typeMismatch {
            self.current = []
        }*/
        self.current = []
        
        self.field = try container.decode(String.self, forKey: .field)
        self.op = try container.decode(String.self, forKey: .op)
    }
}

class DynamicFormFieldOptions {
    var table: String = ""
    var op: String = ""
    var type: String = ""
    var panelType: String = ""
    var item: Int = 0
    var objectId: ObjectId?
    
    init(table: String, op: String) {
        self.table = table
        self.op = op
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
    var comment: String = ""
    var date: String = ""
    
    var material: AdvertisingMaterial?
    var set: AdvertisingMaterialSet?
    var madeBy: User?
    
    private enum CodingKeys: String, CodingKey {
        case id = "material_operation_id", transactionType = "transaction_type", operationType = "operation_type", quantity, comment = "observations", date = "date_time", material, set = "material_set", madeBy = "made_by_user"
    }
    
}
