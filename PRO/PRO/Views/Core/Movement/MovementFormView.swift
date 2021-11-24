//
//  MovementFormView.swift
//  PRO
//
//  Created by VMO on 19/01/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct MovementFormView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    
    var title = ""
    var icon = "ic-home"
    var color = Color.cPrimary
    var visitType = "NORMAL"
    
    @State var movement: Movement = Movement()
    @State var promotedProducts = [String]()
    
    var body: some View {
        VStack {
            HeaderToggleView(couldSearch: false, title: title, icon: Image(icon), color: color)
            Button(action: {
                print(movement)
            }) {
                Text("Test")
            }
            switch tabRouter.current {
                case "MATERIAL":
                    MovementFormTabMaterialView(selected: $movement.dataMaterial)
                case "PROMOTED":
                    MovementFormTabPromotedView(selected: $promotedProducts)
                case "SHOPPING":
                    MovementFormTabShoppingView(selected: $movement.dataShopping)
                case "STOCK":
                    MovementFormTabStockView(selected: $movement.dataStock)
                case "TRANSFERENCE":
                    MovementFormTabTransferenceView(selected: $movement.dataTransference)
                default:
                    MovementFormTabBasicView(movement: $movement)
            }
            MovementBottomNavigationView(tabRouter: tabRouter)
        }
    }
}

struct MovementFormTabBasicView: View {
    
    @Binding var movement: Movement
    
    var body: some View {
        ScrollView {
            VStack {
                Text("BASIC!!!!")
            }
        }
    }
    
}


struct MovementFormTabMaterialView: View {
    
    @Binding var selected: RealmSwift.List<MovementMaterial>
    
    var body: some View {
        ScrollView {
            VStack {
                Text("MATERIAL!!!!")
            }
        }
    }
    
}

struct MovementBottomNavigationView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @StateObject var tabRouter: TabRouter
    
    @State var mainTabs = [[String: Any]]()
    @State var moreTabs = [[String: Any]]()
    @State var bottomNavActive = "MAIN"
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                if bottomNavActive == "MAIN" {
                    Image("ic-visit")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(mainTabs.count + 1 + (moreTabs.isEmpty ? 0 : 1)), alignment: .center)
                        .foregroundColor(tabRouter.current == "BASIC" ? .cPrimary : .cAccent)
                        .onTapGesture {
                            tabRouter.current = "BASIC"
                        }
                    ForEach(mainTabs.indices, id: \.self) { index in
                        let key = Utils.castString(value: mainTabs[index]["key"])
                        Image(MovementUtils.iconTabs(key: key))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / CGFloat(mainTabs.count + 1 + (moreTabs.isEmpty ? 0 : 1)), alignment: .center)
                            .foregroundColor(tabRouter.current == key ? .cPrimary : .cAccent)
                            .onTapGesture {
                                tabRouter.current = key
                            }
                    }
                    if !moreTabs.isEmpty {
                        Image("ic-more")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / CGFloat(mainTabs.count + 2), alignment: .center)
                            .foregroundColor(.cAccent)
                            .onTapGesture {
                                bottomNavActive = "MORE"
                                tabRouter.current = "ROTATION"
                            }
                    }
                } else {
                    Image("ic-back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(moreTabs.count + 1), alignment: .center)
                        .foregroundColor(.cAccent)
                        .onTapGesture {
                            bottomNavActive = "MAIN"
                            tabRouter.current = "BASIC"
                        }
                    ForEach(moreTabs.indices, id: \.self) { index in
                        let key = Utils.castString(value: moreTabs[index]["key"])
                        Image(MovementUtils.iconTabs(key: key))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / CGFloat(moreTabs.count + 1), alignment: .center)
                            .foregroundColor(tabRouter.current == key ? .cPrimary : .cAccent)
                            .onTapGesture {
                                tabRouter.current = key
                            }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 46, maxHeight: 46)
        .onAppear {
            load()
        }
    }
    
    func load() {
        let tabs = MovementUtils.initTabs(data: MovementUtils.tabs(panelType: viewRouter.data.type, visitType: Utils.castString(value: viewRouter.data.options["visitType"]).lowercased()))
        mainTabs = tabs[0]
        moreTabs = tabs[1]
        tabRouter.current = "BASIC"
    }
    
    
}
