//
//  DashboardRouter.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import Combine
import SwiftUI

class DashboardRouter: ObservableObject {
    let objectWillChange = PassthroughSubject<DashboardRouter, Never>()
    var currentPage: String = "LIST" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
}

class TabRouter: ObservableObject {
    let objectWillChange = PassthroughSubject<TabRouter, Never>()
    var current: String = "TITLE" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
}
