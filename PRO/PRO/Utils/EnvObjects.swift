//
//  EnvObjects.swift
//  PRO
//
//  Created by VMO on 24/08/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import Foundation
import SwiftUI

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
    
    init(table: String, op: String) {
        self.table = table
        self.op = op
    }
}
