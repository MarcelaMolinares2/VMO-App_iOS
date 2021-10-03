//
//  GMSView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    
    @ObservedObject var locationManager = LocationManager()
    private let zoom: Float = 15.0//4.6187452,-74.1592274,15z
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: locationManager.latitude, longitude: locationManager.longitude, zoom: zoom)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: locationManager.latitude, longitude: locationManager.longitude))
    }
    
}

struct PanelLocationMapsView: UIViewRepresentable {
    
    @ObservedObject var locationManager = LocationManager()
    private let zoom: Float = 15.0
    var locations = RealmSwift.List<PanelLocation>()
    
    func makeCoordinator() -> PanelLocationMapsCoordinator {
        return PanelLocationMapsCoordinator()
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: locationManager.latitude, longitude: locationManager.longitude, zoom: zoom)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        if locations.isEmpty {
            mapView.animate(toLocation: CLLocationCoordinate2D(latitude: locationManager.latitude, longitude: locationManager.longitude))
        } else {
            mapView.clear()
            locations.forEach { item in
                addMarker(mapView: mapView, panelLocation: item)
            }
            GMSUtils.boundsMapToMarkers(mapView: mapView, locations: locations)
        }
    }
    
    func addMarker(mapView: GMSMapView, panelLocation: PanelLocation) {
        let position = CLLocationCoordinate2D(latitude: Utils.castDouble(value: panelLocation.latitude), longitude: Utils.castDouble(value: panelLocation.longitude))
        let marker = GMSMarker(position: position)
        let city = try! Realm().object(ofType: City.self, forPrimaryKey: panelLocation.cityId)
        marker.title = "\(panelLocation.address ?? ""), \(city?.name ?? "")"
        marker.map = mapView
    }
    
}

class PanelLocationMapsCoordinator: NSObject, GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("INFO TAPPED")
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("MARKER TAPPED")
        return true
    }
}
