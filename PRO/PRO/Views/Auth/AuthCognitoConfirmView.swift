//
//  AuthCognitoConfirmView.swift
//  PRO
//
//  Created by VMO on 13/06/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import AlertToast
import Amplify


struct AuthCognitoConfirmView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var code: String = ""
    @State private var isProcesing = false
    
    @State private var toastMessage = ""
    @State private var toastShow = false
    
    @State private var resendStatus = false
    @State private var resendCount = 60
    
    private var validated: Bool {
        !code.isEmpty
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
                if self.isProcesing {
                    LottieView(name: "login_animation", loopMode: .loop)
                        .frame(width: 300, height: 300)
                } else {
                    VStack {
                        VStack(alignment: .center, spacing: 20) {
                            Text("envAuthCognitoMessage")
                                .foregroundColor(Color.white)
                                .font(.system(size: 16))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                            Text("envAuthCognitoComplement")
                                .foregroundColor(Color.cTextMedium)
                                .font(.system(size: 14))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                            CustomTextField(placeholder: Text("envAuthFormCode"), bgColor: .cTextFieldLogin, text: $code)
                                .keyboardType(.numberPad)
                            Button(action: {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                validateCode()
                            }) {
                                Text("envValidate")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 20))
                            }
                            .opacity(validated ? 1 : 0.5)
                            .disabled(!validated)
                        }
                        .padding(.vertical, 100)
                        HStack {
                            Button(action: {
                                resendCode()
                            }) {
                                Text("envAuthResendCode")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 16))
                            }
                            .opacity(resendStatus ? 1 : 0.5)
                            .disabled(!resendStatus)
                            Spacer()
                            if !resendStatus {
                                Text("00:\(Utils.zero(n: resendCount))")
                                    .foregroundColor(Color.cTextMedium)
                                    .font(.system(size: 14))
                                    .lineLimit(0)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    .padding(.horizontal, 40)
                    
                }
                Spacer()
            }
        }
        .toast(isPresenting: $toastShow) {
            return AlertToast(type: .regular, title: NSLocalizedString(toastMessage, comment: ""))
        }
        .onAppear {
            UIApplication.setStatusBarStyle(.lightContent)
            fireTimer()
        }
    }
    
    func validateCode() {
        self.isProcesing = true
        let username = UserDefaults.standard.string(forKey: Globals.COGNITO_USERNAME) ?? ""
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: self.code) { result in
            switch result {
                case .success:
                    print("Confirm signUp succeeded")
                    toastMessage = "envAuthCognitoSuccess"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        viewRouter.currentPage = "AUTH-SIGN-IN"
                    }
                case .failure(let error):
                    print("An error occurred while confirming sign up \(error)")
                    toastMessage = "errCognitoConfirm"
            }
            self.isProcesing = false
            toastShow = true
        }
    }
    
    func fireTimer() {
        resendStatus = false
        resendCount = 59
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            resendCount -= 1
            if resendCount <= 0 {
                resendStatus = true
                timer.invalidate()
            }
        }
    }
    
    func resendCode() {
        let username = UserDefaults.standard.string(forKey: Globals.COGNITO_USERNAME) ?? ""
        Amplify.Auth.resendSignUpCode(for: username) { result in
            switch result {
                case .success:
                    print("Confirm signUp code sent")
                    toastMessage = "envAuthCognitoCodeSent"
                    DispatchQueue.main.async {
                        fireTimer()
                    }
                case .failure(let error):
                    print("An error occurred while resendign sign up code \(error)")
                    toastMessage = "errServerConection"
            }
            toastShow = true
        }
    }
    
}
