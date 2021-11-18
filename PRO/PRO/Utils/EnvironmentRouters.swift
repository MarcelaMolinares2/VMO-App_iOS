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
    let objectWillChange = PassthroughSubject<ModuleRouter, Never>()
    var currentPage: String = "LIST" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    var objectId: String = "" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
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
    var data: FormEntity = FormEntity(objectId: "") {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    
    func panel() -> Panel & SyncEntity {
        /*
         case "C":
         return try! Realm().object(ofType: Client.self, forPrimaryKey: data.id) ?? Client()
         */
        switch data.type {
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

