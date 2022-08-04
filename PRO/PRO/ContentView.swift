//
//  ContentView.swift
//  PRO
//
//  Created by VMO on 1/09/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import AlertToast

struct ContentView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack {
            if userSettings.loggedIn {
                switch viewRouter.currentPage {
                    case "MASTER":
                        MasterView()
                    default:
                        WrapperView()
                }
            } else {
                switch viewRouter.currentPage {
                    case "APP-MASTER":
                        MasterLoginView()
                    case "APP-MASTER-LAB":
                        MasterLaboratoryView()
                    case "AUTH-COGNITO-CONFIRM":
                        AuthCognitoConfirmView()
                    case "AUTH-RECOVER-PASSWORD":
                        AuthRecoverPasswordView()
                    default:
                        AuthSignInView()
                }
            }
        }
        .attachPartialSheetToRoot()
    }
    
    func load() {
        let operationQueue = OperationQueue()
        let syncUploadOperation = SyncUploadService()
        operationQueue.addOperations([syncUploadOperation], waitUntilFinished: false)
    }
}
