//
//  PROApp.swift
//  PRO
//
//  Created by VMO on 24/06/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import Firebase
import Amplify
import AWSCognitoAuthPlugin
import AWSS3StoragePlugin
import GoogleMaps
import GooglePlaces

@main
struct PROApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 26)
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Amplify configured with auth plugin")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
        
        GMSServices.provideAPIKey("AIzaSyAlK1aWCKRqEKN94i8Y9EsEF7NW0OFDjhU")
        GMSPlacesClient.provideAPIKey("AIzaSyAlK1aWCKRqEKN94i8Y9EsEF7NW0OFDjhU")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ViewRouter())
                .environmentObject(MasterRouter())
                .environmentObject(UserSettings())
        }
    }
}
