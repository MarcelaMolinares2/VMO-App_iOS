//
//  UserSettings.swift
//  PRO
//
//  Created by VMO on 28/10/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import Foundation
import RealmSwift

class UserSettings: ObservableObject {
    @Published var loggedIn: Bool = UserDefaults.standard.bool(forKey: Globals.SESSION_STATUS)
    @Published var initStatus: Bool = UserDefaults.standard.bool(forKey: Globals.INIT_STATUS)
    
    func successfullAuth(data: [String: Any]) {
        UserDefaults.standard.setValue(Utils.castString(value: data["access_token"]), forKey: Globals.ACCESS_TOKEN)
        UserDefaults.standard.setValue(Utils.castString(value: data["media_token"]), forKey: Globals.MEDIA_TOKEN)
        toggle(status: true)
    }
    
    func successfullLogin(data: [String: Any]) {
        let userData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
        UserDefaults.standard.set(userData, forKey: Globals.USER_DATA)
        toggle(status: true)
    }
    
    func toggleInit(value: Bool) {
        UserDefaults.standard.setValue(value, forKey: Globals.INIT_STATUS)
        initStatus = value
    }
    
    func successfullLogout() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        toggle(status: false)
        toggleInit(value: false)
    }
    
    func toggle(status: Bool) {
        UserDefaults.standard.setValue(status, forKey: Globals.SESSION_STATUS)
        loggedIn = status
    }
    
    func userData() -> User? {
        let usr = try! Realm().objects(User.self).filter("id = %@", JWTUtils.sub()).first
        return usr
    }

}
