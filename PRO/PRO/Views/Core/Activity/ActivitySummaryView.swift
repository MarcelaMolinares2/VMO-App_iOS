//
//  ActivitySummaryView.swift
//  PRO
//
//  Created by Fernando Garcia on 12/01/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import BottomSheetSwiftUI

struct ActivitySummaryView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Binding var activity: DifferentToVisit
    @Binding var modalSummary: Bool
    
    @State private var route = 0
    @State private var modalPanelType = false
    @State private var assistants = [PanelItemModel]()
    
    var realm = try! Realm()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $route) {
                ActivitySummaryBasicView(activity: $activity)
                    .tag(0)
                    .tabItem {
                        Text("envBasic")
                        Image("ic-basic")
                    }
                PanelSelectWrapperView(realm: realm, types: [], members: $assistants, modalPanelType: $modalPanelType)
                .tag(1)
                .tabItem {
                    Text("envAssistants")
                    Image("ic-client")
                }
            }
            .tabViewStyle(DefaultTabViewStyle())
            HStack(alignment: .bottom) {
                Spacer()
                FAB(image: "ic-edit") {
                    FormEntity(objectId: activity.objectId).go(path: "DTV-FORM", router: viewRouter)
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL + 50)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        assistants.removeAll()
        activity.assistants.forEach{ assistant in
            if let panel = PanelUtils.panel(type: assistant.panelType, objectId: assistant.panelObjectId, id: assistant.panelId) {
                assistants.append(PanelItemModel(objectId: panel.objectId, type: assistant.panelType))
            }
        }
    }
    
}

struct ActivitySummaryBasicView: View {
    
    @Binding var activity: DifferentToVisit
    
    var body: some View {
        VStack {
            ScrollView {
                
            }
        }
        .onAppear{
            load()
        }
    }
    
    func load() {
        
    }
}
