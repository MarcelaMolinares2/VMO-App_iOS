//
//  DynamicForm.swift
//  PRO
//
//  Created by VMO on 7/01/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import Foundation
import SwiftUI


struct DynamicFormTab: Identifiable {
    let id = UUID()
    var key: String
    var title: String
    var groups: [DynamicFormGroup]
    
    struct DynamicFormGroup: Identifiable {
        let id = UUID()
        var title: String
        var fields: [DynamicFormField]
        
        struct DynamicFormField: Identifiable, Decodable {
            let id = UUID()
            var key: String
            var label: String
            var description: String?
            var controlType: String
            var dataType: String
            var multiple: Bool
            var required: Bool
            var source: String
            var sourceType: String
            var condition: String?
            var value = ""
            
            private enum CodingKeys: String, CodingKey {
                case key, label, description, controlType, dataType, multiple, required, source, sourceType, condition
            }
        }
    }
}

