//
//  ContentView.swift
//  PRO
//
//  Created by VMO on 1/09/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack {
            if userSettings.loggedIn {
                if userSettings.initStatus {
                    switch viewRouter.currentPage {
                    case "MASTER":
                        MasterView()
                    default:
                        WrapperView()
                    }
                } else {
                    InitView()
                }
            } else {
                LoginView()
            }
        }
        .addPartialSheet()
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ViewRouter()).environmentObject(UserSettings())
    }
}
#endif
