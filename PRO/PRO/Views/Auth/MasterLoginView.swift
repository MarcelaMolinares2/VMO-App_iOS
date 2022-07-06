//
//  MasterLoginView.swift
//  PRO
//
//  Created by VMO on 9/03/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import AlertToast

struct MasterLoginView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var authService = MasterAuthService()
    
    @State var password: String = ""
    
    @State private var toastError = ""
    @State private var toastShow = false
    
    private var validated: Bool {
        !password.isEmpty
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
                        viewRouter.currentPage = "LOGIN"
                    }
                Spacer()
                if self.authService.isProcesing {
                    LottieView(name: "login_animation", loopMode: .loop)
                        .frame(width: 300, height: 300)
                } else {
                    VStack(alignment: .center, spacing: 20) {
                        CustomSecureField(placeholder: Text("envAuthFormPassword"), bgColor: .cTextFieldLogin, text: $password)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                        Button(action: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                            self.authService.fetch(viewRouter: viewRouter, userSettings: userSettings, password: password, toastWrapper: toastWrapper)
                        }) {
                            Text("envAuthSignIn")
                                .foregroundColor(Color.white)
                                .font(.system(size: 20))
                        }
                        .opacity(validated ? 1 : 0.5)
                        .disabled(!validated)
                    }
                    .padding(.horizontal, 60)
                    .padding(.vertical, 100)
                }
                Spacer()
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

