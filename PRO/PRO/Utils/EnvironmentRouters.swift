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

class MasterRouter: ObservableObject {
    let objectWillChange = PassthroughSubject<MasterRouter, Never>()
    var date: Date = Date() {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    var search: String = "" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    var slide: Int = 1 {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    var tabLeft: String = "" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    var tabCenter: String = "home" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    var tabRight: String = "dashboard" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    var diaryLayout: DiaryFormLayout = .main {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
}

class ModuleRouter: ObservableObject {
    let objectWillChange = PassthroughSubject<ModuleRouter, Never>()
    var currentPage: String = "LIST" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    var objectId: ObjectId? = nil {
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
    var data: FormEntity = FormEntity(objectId: nil) {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
    var parentMenuId: Int = 0 {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }

    func option(key: String, default defaultValue: String) -> String {
        if let value = data.options[key] {
            return Utils.castString(value: value)
        }
        return defaultValue
    }
}
