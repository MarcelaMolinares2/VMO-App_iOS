//
//  AuthRecoverPasswordView.swift
//  PRO
//
//  Created by VMO on 9/06/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI

struct AuthRecoverPasswordView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var authService = RecoverPasswordAuthService()
    
    @State var username: String = ""
    @State var domain: String = ""
    
    private var validated: Bool {
        !username.isEmpty && !domain.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.cBackgroundStatic.ignoresSafeArea()
            VStack(alignment: .center) {
                Spacer()
                Image("logo-app")
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100)
                Spacer()
                if self.authService.isProcesing {
                    LottieView(name: "login_animation", loopMode: .loop)
                        .frame(width: 300, height: 300)
                } else {
                    VStack {
                        VStack(alignment: .center, spacing: 20) {
                            if !validated {
                                Text("envAuthFormMessage")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 16))
                            }
                            CustomTextField(placeholder: Text("envAuthFormUsername"), bgColor: .cTextFieldLogin, text: $username)
                            CustomTextField(placeholder: Text("envAuthFormDomain"), bgColor: .cTextFieldLogin, text: $domain)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                            if validated {
                                Button(action: {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                    self.authService.fetch(viewRouter: viewRouter, userSettings: userSettings, username: username, domain: domain)
                                }) {
                                    Text("envValidate")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 20))
                                }
                            }
                        }
                        .padding(.vertical, 100)
                        HStack {
                            Button(action: {
                                viewRouter.currentPage = "AUTH-SIGN-IN"
                            }) {
                                Image("ic-back")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(5)
                                    .frame(width: 40, height: 40, alignment: .center)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .onAppear {
            UIApplication.setStatusBarStyle(.lightContent)
        }
    }
    
}
