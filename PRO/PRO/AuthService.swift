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

class AuthService: ObservableObject {
    
    let objectWillChange = PassthroughSubject<Bool, Never>()

    var isProcesing = false {
        willSet {
            objectWillChange.send(isProcesing)
        }
    }
    
    func fetch(userSettings: UserSettings, username: String, password: String, domain: String) {
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
                    if successful {
                        self.isProcesing = false
                        userSettings.successfullAuth(data: data as! [String : Any])
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
        Widgets.toast(message: NSLocalizedString(message, comment: ""))
    }
    
}
