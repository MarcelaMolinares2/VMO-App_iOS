//
//  NotificationCenterView.swift
//  PRO
//
//  Created by VMO on 12/10/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct NotificationCenterView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    
    var hierarchy = UserDao(realm: try! Realm()).hierarchy()
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "envNotifications") {
                viewRouter.currentPage = "MASTER"
            }
            TabView(selection: $tabRouter.current) {
                if hierarchy.count > 0 {
                    NotificationRequestsView()
                        .tag("REQUESTS")
                        .tabItem {
                            Text("envRequests".localized())
                            Image("ic-notification")
                        }
                }
                NotificationListView()
                    .tag("NOTIFICATIONS")
                    .tabItem {
                        Text("envNotifications".localized())
                        Image("ic-notification")
                    }
            }
        }
        .onAppear {
            if hierarchy.count > 0 {
                tabRouter.current = "REQUESTS"
            } else {
                tabRouter.current = "NOTIFICATIONS"
            }
        }
    }
    
}

struct NotificationRequestsView: View {
    
    var body: some View {
        ScrollView {
            
        }
        .refreshable {
            
        }
    }
    
}

struct NotificationListView: View {
    
    var body: some View {
        ScrollView {
            
        }
    }
    
}
