//
//  MasterLaboratoryUserView.swift
//  PRO
//
//  Created by VMO on 9/06/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import AlertToast

struct MasterLaboratoryUserView: View {
    let laboratory: MasterLaboratory
    let onBackPressed: () -> Void
    
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var authService = MasterAppAuthService()
    
    @State var users: [MasterLaboratoryUser] = []
    
    @State private var toastError = ""
    @State private var toastShow = false
    
    var body: some View {
        let toastWrapper = BindingWrapperToast(error: $toastError, show: $toastShow)
        VStack {
            if self.authService.isProcesing {
                Spacer()
                Image("logo-app")
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100)
                Spacer()
                LottieView(name: "login_animation", loopMode: .loop)
                    .frame(width: 300, height: 300)
                Spacer()
            } else {
                HStack {
                    Button(action: {
                        onBackPressed()
                    }) {
                        Image("ic-back")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: 40, height: 40, alignment: .center)
                            .foregroundColor(.white)
                    }
                    Text(laboratory.name)
                    Spacer()
                }
                List(users, id: \.id) { user in
                    HStack {
                        VStack {
                            Text(user.name)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                            Text(user.dni)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                                .font(.system(size: 14))
                        }
                        Button(action: {
                            authService.fetch(viewRouter: viewRouter, userSettings: userSettings, id: user.id, toastWrapper: toastWrapper)
                        }) {
                            Image("ic-input")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(5)
                                .frame(width: 40, height: 40, alignment: .center)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .toast(isPresenting: $toastShow) {
            return AlertToast(type: .error(.cDanger), title: NSLocalizedString(toastError, comment: ""))
        }
        .onAppear {
            loadUsers()
        }
    }
    
    private func loadUsers() {
        UserDefaults.standard.setValue(laboratory.hash, forKey: Globals.LABORATORY_HASH)
        UserDefaults.standard.setValue(laboratory.path, forKey: Globals.LABORATORY_PATH)
        MasterServer().getRequest(path: "master/users") { success, code, data in
            if success {
                if let rs = data as? [String] {
                    for item in rs {
                        let object = Utils.jsonDictionary(string: item)
                        users.append(try! MasterLaboratoryUser(from: object))
                    }
                }
            }
        }
    }
}
