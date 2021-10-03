//
//  Utils.swift
//  PRO
//
//  Created by VMO on 28/10/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import GoogleMaps

class Utils {
    
    static func castInt(value: Any?, defaultValue: Int = 0) -> Int {
        if let new = value as? Int {
            return new
        }
        if let str = value as? String {
            if Int(str) != nil {
                return Int(str)!
            }
        }
        return defaultValue
    }
    
    static func castDouble(value: Any?, defaultValue: Double = 0) -> Double {
        if let new = value as? Double {
            return new
        } else if let new = (value as? NSString)?.doubleValue {
            return new
        }
        return defaultValue
    }
    
    static func castFloat(value: Any?, defaultValue: Float = 0) -> Float {
        if let new = value as? Float {
            return new
        } else if let new = (value as? NSString)?.floatValue {
            return new
        }
        return defaultValue
    }
    
    static func castString(value: Any?, defaultValue: String = "") -> String {
        if let new = value as? String {
            return new
        }
        return defaultValue
    }
    
    static func dictionaryToJSON(data: Any) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: data, options: [])
        return String(data: jsonData, encoding: .utf8)!
    }
    
    static func arrayToJSON(data: [[String: Any]]) -> Any? {
        var result = [String]()
        for item in data {
            if let json = self.json(from: item) {
                result.append(json)
            }
        }
        return result
    }
    
    static func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    static func jsonDictionary(string: String) -> Dictionary<String, Any> {
        let data = string.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
            {
                return jsonArray
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        return Dictionary<String, Any>()
    }
    
    static func jsonObject(string: String) -> [Dictionary<String, Any>] {
        let data = string.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
            {
                return jsonArray
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        return [Dictionary<String, Any>]()
    }
    
    static func strToDate(value: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        guard let date = formatter.date(from: value) else {
            return Date()
        }
        return date
    }
    
    static func dateFormat(date: Date, format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    static func shortDate(value: String) -> String {
        return dateFormat(date: strToDate(value: value), format: "MMM d")
    }
    
    static func currentDate() -> String {
        return dateFormat(date: Date())
    }
    
    static func currentDateTime() -> String {
        return dateFormat(date: Date(), format: "yyyy-MM-dd HH:mm:ss")
    }
    
    static func shareText(text: String, fileName: String) {
        let textData = text.data(using: .utf8)
        let textURL = textData?.dataToFile(fileName: "\(fileName).txt")
        var filesToShare = [Any]()
        filesToShare.append(textURL!)
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    static func appVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static func addDaysToDate(days: Int, to date: Date) -> Date {
        var dayComponent = DateComponents()
        dayComponent.day = days
        let theCalendar = Calendar.current
        return theCalendar.date(byAdding: dayComponent, to: date) ?? Date()
    }
    
    static func objToJSON<T>(_ value: T) throws -> String where T : Encodable {
        do {
            let enc = try JSONEncoder().encode(value)
            return String(data: enc, encoding: .utf8) ?? ""
        } catch let error {
            print(error)
        }
        return ""
    }
    
}


class JWTUtils {
    
    static func decode(jwtToken jwt: String) -> [String: Any] {
      let segments = jwt.components(separatedBy: ".")
      return decodeJWTPart(segments[1]) ?? [:]
    }

    static func base64UrlDecode(_ value: String) -> Data? {
      var base64 = value
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")

      let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
      let requiredLength = 4 * ceil(length / 4.0)
      let paddingLength = requiredLength - length
      if paddingLength > 0 {
        let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
        base64 = base64 + padding
      }
      return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }

    static func decodeJWTPart(_ value: String) -> [String: Any]? {
      guard let bodyData = base64UrlDecode(value),
        let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
          return nil
      }

      return payload
    }
    
    static func sub() -> Int {
        if let token = UserDefaults.standard.string(forKey: Globals.ACCESS_TOKEN) {
            return Utils.castInt(value: JWTUtils.decode(jwtToken: token)["sub"])
        }
        return 0
    }
    
}

class PanelUtils {
    
    static func colorByPanelType(panel: Panel) -> Color {
        return valueByPanelType(by: .color, panel: panel) as! Color
    }
    
    static func imageByPanelType(panel: Panel) -> String {
        return valueByPanelType(by: .icon, panel: panel) as! String
    }
    
    static func formByPanelType(panel: Panel) -> String {
        return valueByPanelType(by: .form, panel: panel) as! String
    }
    
    static func valueByPanelType(by type: PanelValueType, panel: Panel) -> Any {
        let data = [
            [
                "M": Color.cPanelMedic,
                "F": Color.cPanelPharmacy,
                "C": Color.cPanelClient,
                "P": Color.cPanelPatient,
                "D": Color.cPrimary
            ],
            [
                "M": "ic-medic",
                "F": "ic-pharmacy",
                "C": "ic-client",
                "P": "ic-patient",
                "D": "ic-home"
            ],
            [
                "M": "MEDIC-FORM",
                "F": "PHARMACY-FORM",
                "C": "CLIENT-FORM",
                "P": "PATIENT-FORM",
                "D": "MASTER"
            ],
            [
                "M": "modMedic",
                "F": "modPharmacy",
                "C": "modClient",
                "P": "modPatient",
                "D": ""
            ]
        ]
        var index = -1
        switch type {
        case .color:
            index = 0
        case .icon:
            index = 1
        case .form:
            index = 2
        case .title:
            index = 3
        }
        
        if let val = data[index][panel.type] {
            return val
        } else {
            return data[index]["D"] as Any
        }
    }
    
    static func panelByType(id: Int, type: String) -> Panel? {
        switch type {
        case "M":
            return try! Realm().object(ofType: Doctor.self, forPrimaryKey: id)
        case "F":
            return try! Realm().object(ofType: Pharmacy.self, forPrimaryKey: id)
        case "C":
            return try! Realm().object(ofType: Client.self, forPrimaryKey: id)
        case "P":
            return try! Realm().object(ofType: Patient.self, forPrimaryKey: id)
        case "T":
            return try! Realm().object(ofType: PotentialProfessional.self, forPrimaryKey: id)
        default:
            return nil
        }
    }
    
    enum PanelValueType {
        case color, icon, form, title
    }
    
}

class GMSUtils {
    
    static func coordinateFromPanelLocation(location: PanelLocation) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(Utils.castDouble(value: location.latitude)), longitude: CLLocationDegrees(Utils.castDouble(value: location.longitude)))
    }
    
    static func boundsMapToMarkers(mapView: GMSMapView, locations: RealmSwift.List<PanelLocation>) {
        if !locations.isEmpty {
            let firstLocation = GMSUtils.coordinateFromPanelLocation(location: locations[0])
            var bounds = GMSCoordinateBounds(coordinate: firstLocation, coordinate: firstLocation)
            
            locations.forEach { item in
                bounds = bounds.includingCoordinate(GMSUtils.coordinateFromPanelLocation(location: item))
            }
            let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(15))
            mapView.animate(with: update)
        }
    }
    
}

class MovementUtils {
    
    static func tabs(panel: Panel, visitType: String) -> [String: [String: Any]] {
        let jsonString = Config.get(key: "MOV_TABS").complement ?? ""
        let data = Utils.jsonDictionary(string: jsonString)
        
        var tabs = [String: [String: Any]]()
        data.forEach { (key: String, value: Any) in
            print(key)
            let panelOpts = value as! Dictionary<String,Any>
            let visitTypes = panelOpts[panel.type] as! Dictionary<String,Any>
            let opts = visitTypes[visitType] as! Dictionary<String,Any>
            if let visible = opts["visible"] as? Int {
                if visible == 1 {
                    tabs[key] = [
                        "required": Utils.castInt(value: opts["required"]) == 1,
                        "index": jsonString.index(of: key)
                    ]
                }
            }
        }
        return tabs
    }
    
    static func initTabs(data: [String: [String: Any]]) -> [[[String: Any]]] {
        var mainTabs = [[String: Any]]()
        var moreTabs = [[String: Any]]()
        
        var i = 0
        data.sorted(by: { (el1: (key: String, value: [String : Any]), el2: (key: String, value: [String : Any])) -> Bool in
            if Utils.castInt(value: el1.value["index"]) < Utils.castInt(value: el2.value["index"]) {
                return true
            }
            return false
        }).forEach { (key: String, value: [String : Any]) in
            print(value)
            if i > 2 {
                moreTabs.append(["key": key, "required": value["required"] as! Bool])
            } else {
                mainTabs.append(["key": key, "required": value["required"] as! Bool])
            }
            i += 1
        }
        print(mainTabs)
        print(moreTabs)
        return [mainTabs, moreTabs]
    }
    
    static func iconTabs(key: String) -> String {
        let data = [
            "MATERIAL": "ic-material",
            "PROMOTED": "ic-promoted",
            "ROTATION": "ic-rotation",
            "SHOPPING": "ic-shopping",
            "STOCK": "ic-stock",
            "TRANSFERENCE": "ic-shopping-list"
        ]
        return data[key] ?? "ic-home"
    }
    
}
