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

struct CustomMarkerStaticMapView: UIViewRepresentable {
    @Binding var marker: GMSMarker
    
    private let zoom: Float = 15.0
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: zoom)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = false
        mapView.isUserInteractionEnabled = false
        if EnvironmentUtils.osTheme == .dark {
            do {
                if let styleURL = Bundle.main.url(forResource: "map_style_dark", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(self)
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.clear()
        marker.map = mapView
        let camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: zoom)
        mapView.animate(to: camera)
    }
    
    final class MapViewCoordinator: NSObject, GMSMapViewDelegate {
        var mapViewControllerBridge: CustomMarkerStaticMapView
        
        init(_ mapViewControllerBridge: CustomMarkerStaticMapView) {
            self.mapViewControllerBridge = mapViewControllerBridge
        }
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            return true
        }
    }
}

struct CustomMarkerMapView: UIViewRepresentable {
    
    @ObservedObject var locationManager = LocationManager()
    private let zoom: Float = 15.0
    @Binding var markers: [GMSMarker]
    @Binding var goToMyLocation: Bool
    @Binding var fitToBounds: Bool
    
    var onMarkerTapped: (GMSMarker) -> ()
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: locationManager.latitude, longitude: locationManager.longitude, zoom: zoom)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        if EnvironmentUtils.osTheme == .dark {
            do {
                if let styleURL = Bundle.main.url(forResource: "map_style_dark", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.clear()
        var bounds = GMSCoordinateBounds()
        markers.forEach { marker in
            marker.map = mapView
            bounds = bounds.includingCoordinate(marker.position)
        }
        if fitToBounds {
            mapView.animate(with: GMSCameraUpdate.fit(bounds))
            DispatchQueue.main.async {
                fitToBounds = false
            }
        }
        if goToMyLocation {
            if let location = locationManager.location {
                let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoom)
                mapView.animate(to: camera)
            }
            DispatchQueue.main.async {
                goToMyLocation = false
            }
        }
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(self)
    }
    
    final class MapViewCoordinator: NSObject, GMSMapViewDelegate {
        var mapViewControllerBridge: CustomMarkerMapView
        
        init(_ mapViewControllerBridge: CustomMarkerMapView) {
            self.mapViewControllerBridge = mapViewControllerBridge
        }
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            self.mapViewControllerBridge.onMarkerTapped(marker)
            return true
        }
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
        marker.title = "\(panelLocation.address), \(city?.name ?? "")"
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
