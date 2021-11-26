//
//  LocationService.swift
//  PRO
//
//  Created by VMO on 25/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import Combine
import SwiftUI
import CoreLocation
import UIKit

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let objectWillChange = PassthroughSubject<CLLocation?, Never>()
    var locationManager: CLLocationManager
    
    var location: CLLocation? = nil {
        willSet {
            objectWillChange.send(location)
        }
    }
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("LOCATION AUTH STATUS CHANGED")
        switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                start()
            case .denied, .notDetermined, .restricted:
                print("LOCATION PERMISSION DENIED")
            @unknown default:
                print("LOCATION PERMISSION DENIED")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
        }
    }
    
}
