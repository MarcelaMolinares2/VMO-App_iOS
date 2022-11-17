//
//  AuthService.swift
//  PRO
//
//  Created by VMO on 2/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import Combine
import SwiftUI
import Firebase
import Amplify
import AWSCognitoAuthPlugin

class AppAuthService: ObservableObject {
    var toastWrapper: BindingWrapperToast?
    var viewRouter: ViewRouter?
    
    let objectWillChange = PassthroughSubject<Bool, Never>()

    var isProcesing = false {
        willSet {
            objectWillChange.send(isProcesing)
        }
    }
    
    func fetch(viewRouter: ViewRouter, userSettings: UserSettings, username: String, password: String, domain: String, toastWrapper: BindingWrapperToast) {
        self.viewRouter = viewRouter
        self.toastWrapper = toastWrapper
        self.isProcesing = true
        AppServer().postRequest(data: [String: Any](), path: "auth/laboratory/\(domain)") { (successful, code, data) in
            if successful {
                UserDefaults.standard.setValue(Utils.castString(value: (data as! [String: Any])["hash"]), forKey: Globals.LABORATORY_HASH)
                UserDefaults.standard.setValue(domain, forKey: Globals.LABORATORY_PATH)
                self.auth(userSettings: userSettings, username: username, password: password)
            } else {
                self.handleError(message: "errLaboratoryNotFound")
            }
        }
    }
    
    func auth(userSettings: UserSettings, username: String, password: String) {
        Amplify.Auth.signOut { result in
            print(result)
        }
        Messaging.messaging().token { token, error in
            if let error = error {
                self.isProcesing = false
                print("Error fetching FCM registration token: \(error)")
                self.handleError(message: "errServerConection")
            } else if let token = token {
                print(token)
                AppServer().postRequest(data: [
                    "username": username,
                    "password": password,
                    "type": "M",
                    "fcmToken": token,
                    "platform": "iOS"
                ], path: "auth/login") { (successful, code, data) in
                    print(successful, code, data)
                    if successful {
                        let d = data as! [String : Any]
                        print(d)
                        let s3Username = Utils.castString(value: d["s3_username"])
                        let s3Password = Utils.castString(value: d["s3_password"])
                        Amplify.Auth.signIn(username: s3Username, password: s3Password) { result in
                            switch result {
                                case .success:
                                    print("Sign in succeeded")
                                    DispatchQueue.main.async {
                                        self.isProcesing = false
                                        self.viewRouter?.currentPage = "MASTER"
                                        userSettings.successfullAuth(data: data as! [String : Any])
                                    }
                                case .failure(let error):
                                    let email = Utils.castString(value: d["email"])
                                    self.awsSignUp(s3Username: s3Username, s3Password: s3Password, email: email)
                                    print("Sign in failed \(error)")
                            }
                        }
                        //userSettings.successfullAuth(data: data as! [String : Any])
                    } else {
                        print(data)
                        let response = Utils.jsonDictionary(string: data as! String)
                        switch Utils.castInt(value: response["data"]) {
                        case 1:
                            self.handleError(message: "errLogin")
                        default:
                            self.handleError(message: "errServerConection")
                        }
                    }
                }
            }
        }
    }
    
    func awsSignUp(s3Username: String, s3Password: String, email: String) {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        
        UserDefaults.standard.set(s3Username, forKey: Globals.COGNITO_USERNAME)
        
        Amplify.Auth.signUp(username: s3Username, password: s3Password, options: options) { result in
            switch result {
                case .success(let signUpResult):
                    if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                        print("Delivery details \(String(describing: deliveryDetails))")
                    } else {
                        print("SignUp Complete")
                    }
                    self.goToConfirm()
                case .failure(let error):
                    print("Sign in failed \(error)")
                    self.goToConfirm()
            }
        }
    }
    
    func goToConfirm() {
        DispatchQueue.main.async {
            self.isProcesing = false
            self.viewRouter?.currentPage = "AUTH-COGNITO-CONFIRM"
        }
    }
    
    func handleAmplifyError(viewRouter: ViewRouter, s3Username: String, s3Password: String, email: String) {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        Amplify.Auth.signUp(username: s3Username, password: s3Password, options: options) { result in
            switch result {
                case .success(let signUpResult):
                    viewRouter.currentPage = "AWS-VERIFY"
                    if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                        print("Delivery details \(String(describing: deliveryDetails))")
                    } else {
                        print("SignUp Complete")
                    }
                case .failure(let error):
                    print("An error occurred while registering a user \(error)")
            }
        }
        //AWS-VERIFY
    }
    
    func handleError(message: String) {
        self.isProcesing = false
        toastWrapper?.error = message
        toastWrapper?.show = true
    }
    
}

class MasterAuthService: ObservableObject {
    var toastWrapper: BindingWrapperToast?
    
    let objectWillChange = PassthroughSubject<Bool, Never>()
    
    var isProcesing = false {
        willSet {
            objectWillChange.send(isProcesing)
        }
    }
    
    func fetch(viewRouter: ViewRouter, userSettings: UserSettings, password: String, toastWrapper: BindingWrapperToast) {
        self.toastWrapper = toastWrapper
        self.isProcesing = true
        self.auth(viewRouter: viewRouter, userSettings: userSettings, password: password)
    }
    
    func auth(viewRouter: ViewRouter, userSettings: UserSettings, password: String) {
        Messaging.messaging().token { token, error in
            if let error = error {
                self.isProcesing = false
                print("Error fetching FCM registration token: \(error)")
                self.handleError(message: "errServerConection")
            } else if let token = token {
                print(token)
                AppServer().postRequest(data: [
                    "password": password,
                    "type": "M",
                    "fcmToken": token,
                    "platform": "iOS"
                ], path: "master/auth") { (successful, code, data) in
                    print(successful, code, data)
                    if successful {
                        self.isProcesing = false
                        let d = data as! [String : Any]
                        UserDefaults.standard.setValue(Utils.castString(value: d["access_token"]), forKey: Globals.MASTER_HASH)
                        viewRouter.currentPage = "APP-MASTER-LAB"
                    } else {
                        print(data)
                        let response = Utils.jsonDictionary(string: data as! String)
                        switch Utils.castInt(value: response["data"]) {
                            case 1:
                                self.handleError(message: "errMasterPassword")
                            default:
                                self.handleError(message: "errServerConection")
                        }
                    }
                }
            }
        }
    }
    
    func handleError(message: String) {
        self.isProcesing = false
        toastWrapper?.error = message
        toastWrapper?.show = true
    }
    
}

class RecoverPasswordAuthService: ObservableObject {
    var toastWrapper: BindingWrapperToast?
    
    let objectWillChange = PassthroughSubject<Bool, Never>()
    
    var isProcesing = false {
        willSet {
            objectWillChange.send(isProcesing)
        }
    }
    
    func fetch(viewRouter: ViewRouter, userSettings: UserSettings, username: String, domain: String) {
        self.isProcesing = true
        AppServer().postRequest(data: [String: Any](), path: "auth/laboratory/\(domain)") { (successful, code, data) in
            if successful {
                UserDefaults.standard.setValue(Utils.castString(value: (data as! [String: Any])["hash"]), forKey: Globals.LABORATORY_HASH)
                UserDefaults.standard.setValue(domain, forKey: Globals.LABORATORY_PATH)
                self.validate(viewRouter: viewRouter, userSettings: userSettings, username: username)
            } else {
                self.handleError(message: "errLaboratoryNotFound")
            }
        }
    }
    
    func validate(viewRouter: ViewRouter, userSettings: UserSettings, username: String) {
        Messaging.messaging().token { token, error in
            if let error = error {
                self.isProcesing = false
                print("Error fetching FCM registration token: \(error)")
                self.handleError(message: "errServerConection")
            } else if let token = token {
                print(token)
                AppServer().postRequest(data: [
                    "username": username
                ], path: "master/auth") { (successful, code, data) in
                    print(successful, code, data)
                    /*if successful {
                        self.isProcesing = false
                        let d = data as! [String : Any]
                        UserDefaults.standard.setValue(Utils.castString(value: d["access_token"]), forKey: Globals.MASTER_HASH)
                        viewRouter.currentPage = "APP-MASTER-LAB"
                    } else {
                        print(data)
                        let response = Utils.jsonDictionary(string: data as! String)
                        switch Utils.castInt(value: response["data"]) {
                            case 1:
                                self.handleError(message: "errMasterPassword")
                            default:
                                self.handleError(message: "errServerConection")
                        }
                    }*/
                }
            }
        }
    }
    
    func handleError(message: String) {
        self.isProcesing = false
        toastWrapper?.error = message
        toastWrapper?.show = true
    }
    
}

class MasterAppAuthService: ObservableObject {
    var toastWrapper: BindingWrapperToast?
    var viewRouter: ViewRouter?
    
    let objectWillChange = PassthroughSubject<Bool, Never>()
    
    var isProcesing = false {
        willSet {
            objectWillChange.send(isProcesing)
        }
    }
    
    func fetch(viewRouter: ViewRouter, userSettings: UserSettings, id: Int, toastWrapper: BindingWrapperToast) {
        self.viewRouter = viewRouter
        self.toastWrapper = toastWrapper
        self.isProcesing = true
        self.auth(userSettings: userSettings, id: id)
    }
    
    func auth(userSettings: UserSettings, id: Int) {
        Amplify.Auth.signOut { result in
            print(result)
        }
        Messaging.messaging().token { token, error in
            if let error = error {
                self.isProcesing = false
                print("Error fetching FCM registration token: \(error)")
                self.handleError(message: "errServerConection")
            } else if let token = token {
                print(token)
                MasterServer().postRequest(data: [
                    "id": id,
                    "type": "M",
                    "fcmToken": token,
                    "platform": "iOS"
                ], path: "master/login") { (successful, code, data) in
                    print(successful, code, data)
                    if successful {
                        self.isProcesing = false
                        let d = data as! [String : Any]
                        print(d)
                        let s3Username = Utils.md5(string: "apps@vmocentral.com")
                        let s3Password = Utils.md5(string: "apps@vmocentral.comVmonline$2020")
                        Amplify.Auth.signIn(username: s3Username, password: s3Password) { result in
                            switch result {
                                case .success:
                                    print("Sign in succeeded")
                                    DispatchQueue.main.async {
                                        userSettings.successfullAuth(data: data as! [String : Any])
                                        self.viewRouter?.currentPage = "MASTER"
                                    }
                                case .failure(let error):
                                    print("Sign in failed \(error)")
                                    self.handleError(message: "errServerConection")
                            }
                        }
                    } else {
                        print(data)
                        let response = Utils.jsonDictionary(string: data as! String)
                        switch Utils.castInt(value: response["data"]) {
                            case 1:
                                self.handleError(message: "errLogin")
                            default:
                                self.handleError(message: "errServerConection")
                        }
                    }
                }
            }
        }
    }
    
    func handleError(message: String) {
        self.isProcesing = false
        toastWrapper?.error = message
        toastWrapper?.show = true
    }
    
}
