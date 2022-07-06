//
//  LoginView.swift
//  PRO
//
//  Created by VMO on 30/10/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import AlertToast

struct AuthSignInView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var authService = AppAuthService()

    @State var username: String = ""
    @State var password: String = ""
    @State var domain: String = ""
    
    @State private var toastError = ""
    @State private var toastShow = false
    
    private var validated: Bool {
        !username.isEmpty && !password.isEmpty && !domain.isEmpty
    }
    
    var body: some View {
        let toastWrapper = BindingWrapperToast(error: $toastError, show: $toastShow)
        ZStack {
            Color.cBackgroundStatic.ignoresSafeArea()
            VStack(alignment: .center) {
                Spacer()
                Image("logo-app")
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100)
                    .onTapGesture(count: 4) {
                        viewRouter.currentPage = "APP-MASTER"
                    }
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
                            CustomSecureField(placeholder: Text("envAuthFormPassword"), bgColor: .cTextFieldLogin, text: $password)
                            CustomTextField(placeholder: Text("envAuthFormDomain"), bgColor: .cTextFieldLogin, text: $domain)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                            if validated {
                                Button(action: {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                    self.authService.fetch(viewRouter: viewRouter, userSettings: userSettings, username: username, password: password, domain: domain, toastWrapper: toastWrapper)
                                }) {
                                    Text("envAuthSignIn")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 20))
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                        HStack {
                            Spacer()
                            Button(action: {
                                viewRouter.currentPage = "AUTH-RECOVER-PASSWORD"
                            }) {
                                Text("envAuthForgotPassword")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 16))
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .toast(isPresenting: $toastShow) {
            return AlertToast(type: .error(.cDanger), title: NSLocalizedString(toastError, comment: ""))
        }
        .onAppear {
            UIApplication.setStatusBarStyle(.lightContent)
        }
    }
    
}
