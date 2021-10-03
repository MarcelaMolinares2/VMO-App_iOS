//
//  LoginView.swift
//  PRO
//
//  Created by VMO on 30/10/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var authService = AuthService()

    @State var username: String = ""
    @State var password: String = ""
    @State var domain: String = ""
    
    private var validated: Bool {
        !username.isEmpty && !password.isEmpty && !domain.isEmpty
    }
    
    var body: some View {
        ZStack {
            if #available(iOS 14.0, *) {
                Color.cPrimary.ignoresSafeArea()
            } else {
                Color.cPrimary.edgesIgnoringSafeArea(.all)
            }
            VStack(alignment: .center) {
                Spacer()
                Image("logo-app")
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 80)
                Spacer()
                VStack(alignment: .center, spacing: 20) {
                    CustomTextField(placeholder: Text("formUsername"), bgColor: .cTextFieldLogin, text: $username)
                    CustomSecureField(placeholder: Text("formPassword"), bgColor: .cTextFieldLogin, text: $password)
                    CustomTextField(placeholder: Text("formDomain"), bgColor: .cTextFieldLogin, text: $domain)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                        self.authService.fetch(userSettings: userSettings, username: username, password: password, domain: domain)
                    }) {
                        Text("formSignIn")
                            .foregroundColor(Color.white)
                            .font(.system(size: 20))
                    }
                    .opacity(validated ? 1 : 0.5)
                    .disabled(!validated)
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 100)
                Spacer()
            }
            if self.authService.isProcesing {
                GeometryReader { geo in
                    Loader()
                        .position(x:geo.frame(in:.global).midX,y:geo.frame(in:.global).midY)
                }
                .background(Color.black.opacity(0.45))
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            UIApplication.setStatusBarStyle(.lightContent)
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(ViewRouter()).environmentObject(UserSettings())
    }
}
#endif
