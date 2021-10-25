//
//  ViewRouter.swift
//  PRO
//
//  Created by VMO on 28/10/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import Combine
import SwiftUI
import RealmSwift

class ModuleRouter: ObservableObject {
    @Published var status: Bool = false
    
    /*
    let objectWillChange = PassthroughSubject<ModuleRouter, Never>()
    var currentPage: String = "LIST" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    */
}

class ViewRouter: ObservableObject {
    let objectWillChange = PassthroughSubject<ViewRouter, Never>()
    var currentPage: String = "MASTER" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    var data: FormEntity = FormEntity(id: 0) {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    
    func panel() -> Panel & SyncEntity {
        switch data.type {
        case "C":
            return try! Realm().object(ofType: Client.self, forPrimaryKey: data.id) ?? Client()
        default:
            return GenericPanel()
        }
    }
    
    func option(key: String, default defaultValue: String) -> String {
        if let value = data.options[key] {
            return Utils.castString(value: value)
        }
        return defaultValue
    }
}

