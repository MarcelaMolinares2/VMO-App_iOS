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
