//
//  DynamicForm.swift
//  PRO
//
//  Created by VMO on 7/01/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import Foundation
import SwiftUI

struct DynamicForm: Identifiable {
    let id = UUID()
    var tabs: [DynamicFormTab]
}

struct DynamicFormTab: Identifiable {
    let id = UUID()
    var key: String
    var title: String
    var groups: [DynamicFormGroup]
}

struct DynamicFormGroup: Identifiable {
    let id = UUID()
    var title: String
    var fields: [DynamicFormField]
}

struct DynamicFormField: Identifiable, Decodable {
    let id = UUID()
    var key: String
    var label: String
    var description: String?
    var controlType: String
    var dataType: String
    var requiredUserTypes: String = ""
    var visible: DynamicFormFieldUserOpts
    var editable: DynamicFormFieldUserOpts
    var multiple: Bool
    var maxLength: Int
    var multiline: Bool
    var mask: String
    var acceptedValues: String?
    var acceptOtherValue: Bool
    var defaultValue: String?
    var source: String
    var sourceType: String
    var condition: String?
    var countries: String
    var cities: String
    var options: String
    var minValue: String?
    var maxValue: String?
    var value = ""
    var isAdditional: Bool = false
    var localEditable: Bool = true
    var localRequired: Bool = false
    var localVisible: Bool = true
    
    private enum CodingKeys: String, CodingKey {
        case key, label, description, controlType, dataType, requiredUserTypes, visible, editable, multiple, maxLength, multiline, mask, acceptedValues, acceptOtherValue, defaultValue, source, sourceType, condition, countries, cities, options, minValue, maxValue, isAdditional
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.multiple = try container.decode(Bool.self, forKey: .multiple)
        } catch DecodingError.typeMismatch {
            let value = try container.decode(Int.self, forKey: .multiple)
            self.multiple = value == 1
        }
        do {
            self.multiline = try container.decode(Bool.self, forKey: .multiline)
        } catch DecodingError.typeMismatch {
            let value = try container.decode(Int.self, forKey: .multiline)
            self.multiline = value == 1
        }
        do {
            self.minValue = try container.decode(String?.self, forKey: .minValue)
        } catch DecodingError.keyNotFound {
            self.minValue = ""
        }
        do {
            self.maxValue = try container.decode(String?.self, forKey: .maxValue)
        } catch DecodingError.keyNotFound {
            self.maxValue = ""
        }
        do {
            self.condition = try container.decode(String?.self, forKey: .condition)
        } catch DecodingError.typeMismatch {
            self.condition = ""
        }
        do {
            self.acceptedValues = try container.decode(String?.self, forKey: .acceptedValues)
        } catch DecodingError.keyNotFound {
            self.acceptedValues = ""
        }
        do {
            self.isAdditional = try container.decode(Bool.self, forKey: .isAdditional)
        } catch DecodingError.typeMismatch {
            do {
                let value = try container.decode(Int.self, forKey: .isAdditional)
                self.isAdditional = value == 1
            } catch DecodingError.typeMismatch {
                self.isAdditional = false
            }
        }
        
        self.key = try container.decode(String.self, forKey: .key)
        self.label = try container.decode(String.self, forKey: .label)
        self.description = try container.decode(String?.self, forKey: .description)
        self.controlType = try DynamicUtils.stringTypeDecoding(container: container, key: .controlType)
        self.dataType = try DynamicUtils.stringTypeDecoding(container: container, key: .dataType)
        self.requiredUserTypes = try container.decode(String.self, forKey: .requiredUserTypes)
        
        self.visible = try container.decode(DynamicFormFieldUserOpts.self, forKey: .visible)
        self.editable = try container.decode(DynamicFormFieldUserOpts.self, forKey: .editable)
        
        self.maxLength = try container.decode(Int.self, forKey: .maxLength)
        self.mask = try DynamicUtils.stringTypeDecoding(container: container, key: .mask)
        self.acceptOtherValue = try container.decode(Bool.self, forKey: .acceptOtherValue)
        self.defaultValue = try container.decode(String?.self, forKey: .defaultValue)
        self.source = try DynamicUtils.stringTypeDecoding(container: container, key: .source)
        self.sourceType = try DynamicUtils.stringTypeDecoding(container: container, key: .sourceType)
        self.countries = try DynamicUtils.stringTypeDecoding(container: container, key: .countries)
        self.cities = try DynamicUtils.stringTypeDecoding(container: container, key: .cities)
        self.options = try DynamicUtils.stringTypeDecoding(container: container, key: .options)
    }
    
    mutating func setValue(value: String) {
        self.value = value
    }
}

struct DynamicFormFieldUserOpts: Decodable {
    var createUserTypes: String
    var updateUserTypes: String
    
    private enum CodingKeys: String, CodingKey {
        case createUserTypes, updateUserTypes
    }
}

