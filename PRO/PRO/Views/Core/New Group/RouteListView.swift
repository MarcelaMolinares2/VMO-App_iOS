//
//  RouteListView.swift
//  PRO
//
//  Created by VMO on 5/01/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI

struct RouteListView2: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    
    var body: some View {
        VStack {
            HeaderToggleView(couldSearch: true, title: "modPeopleRoute", icon: Image("ic-people-route"), color: Color.cPanelRequestDay)
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    
                }
                FAB(image: "ic-plus") {
                    viewRouter.currentPage = "ROUTE-FORM"
                }
            }
        }
    }
}

struct RouteListView2_Previews: PreviewProvider {
    static var previews: some View {
        RouteListView2()
    }
}
