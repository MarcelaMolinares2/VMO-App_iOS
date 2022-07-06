//
//  RouteFormView.swift
//  PRO
//
//  Created by VMO on 5/01/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI

struct RouteFormView2: View {
    
    @State private var name = ""
    @State private var items = [Panel & SyncEntity]()
    @State private var isValidationOn = false
    
    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    
    var body: some View {
        VStack {
            HeaderToggleView(couldSearch: false, title: "modPeopleRoute", icon: Image("ic-people-route"), color: Color.cPanelRequestDay)
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    VStack {
                        Text("envName")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(isValidationOn && name.isEmpty ? .cDanger : .cTextHigh)
                        TextField("", text: $name)
                    }
                    .padding(.horizontal, 20)
                    ScrollView {
                        LazyVStack {
                            ForEach(items, id: \.id) { element in
                                PanelItem(panel: element)
                            }
                        }
                    }
                    FAB(image: "ic-cloud") {
                        if validate() {
                            save()
                        }
                    }
                }
            }
        }
    }
    
    func validate() -> Bool {
        isValidationOn = true
        if items.isEmpty {
            return false
        }
        return true
    }
    
    func save() {
        
    }
    
}

struct RouteFormView2_Previews: PreviewProvider {
    static var previews: some View {
        RouteFormView2()
    }
}
