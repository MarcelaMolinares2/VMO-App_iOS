//
//  EnvObjects.swift
//  PRO
//
//  Created by VMO on 24/08/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import Foundation

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

class ModalToggle: ObservableObject {
    @Published var status: Bool = false
}
