//
//  MovementFormView.swift
//  PRO
//
//  Created by VMO on 19/01/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI

struct MovementFormView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    
    var title = ""
    var icon = "ic-home"
    var color = Color.cPrimary
    var panel: Panel?
    var visitType = "NORMAL"
    
    init(viewRouter: ViewRouter) {
        if viewRouter.data.id > 0 {
            panel = PanelUtils.panelByType(id: viewRouter.data.id, type: viewRouter.data.type)
            visitType = Utils.castString(value: viewRouter.data.options["visitType"])
        }
    }
    
    var body: some View {
        VStack {
            HeaderToggleView(couldSearch: false, title: title, icon: Image(icon), color: color)
            ScrollView {
                VStack {
                    Text("\(tabRouter.current)")
                }
            }
            MovementBottomNavigationView(tabRouter: tabRouter, panel: panel)
        }
    }
}

struct MovementBottomNavigationView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @StateObject var tabRouter: TabRouter
    var panel: Panel?
    
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
            let tabs = MovementUtils.initTabs(data: MovementUtils.tabs(panel: panel!, visitType: Utils.castString(value: viewRouter.data.options["visitType"]).lowercased()))
            mainTabs = tabs[0]
            moreTabs = tabs[1]
            tabRouter.current = "BASIC"
        }
    }
    
    
}
