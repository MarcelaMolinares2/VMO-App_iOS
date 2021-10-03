//
//  NotificationPanelView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI

struct NotificationPanelView: View {
    private enum Tab: Hashable {
        case dashboard
        case birthday
        case message
        case notification
    }
    
    @State private var selectedTab: Tab = .dashboard

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    
                }) {
                    Image("ic-left-arrow")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 44, alignment: .center)
                        .padding(2)
                }
                Spacer()
                Button(action: {
                    
                }) {
                    Image("logo-header")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 44)
                }
            }
            TabView(selection: $selectedTab) {
                DashboardTabView()
                    .tag(0)
                    .tabItem {
                        Text("envDashboard")
                        Image(systemName: "house.fill")
                    }
                BirthdayTabView()
                    .tag(1)
                    .tabItem {
                        Text("envBirthdays")
                        Image(systemName: "magnifyingglass")
                    }
                MessageTabView()
                    .tag(2)
                    .tabItem {
                        Text("envMessages")
                        Image(systemName: "person.crop.circle")
                    }
                NotificationTabView()
                    .tag(3)
                    .tabItem {
                        Text("envNotifications")
                        Image(systemName: "gear")
                    }
            }
        }
    }
}

struct NotificationPanelView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPanelView()
    }
}
