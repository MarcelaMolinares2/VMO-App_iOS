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
import SwiftTryCatch
import CryptoKit

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
    
    static func anyToString(value: Any?) -> String {
        if let new = value as? String {
            return new
        } else {
            if let new = value as? NSNumber {
                return new.stringValue
            }
        }
        return "\(String(describing: value))"
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
    
    static func json(from object: Any) -> String? {
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
    
    static func jsonObjectArray(string: String) -> [String: Any] {
        let data = string.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any]
            {
                return jsonArray
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        return [String: Any]()
    }
    
    static func strToDate(value: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        guard let date = formatter.date(from: value) else {
            formatter.dateFormat = "yyyy-MM-dd"
            guard let date = formatter.date(from: value) else {
                return Date()
            }
            return date
        }
        return date
    }
    
    static func strDateFormat(value: String, format: String = "dd, MMM yyy") -> String {
        return dateFormat(date: strToDate(value: value))
    }
    
    static func dateFormat(date: Date, format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    static func dateFormat(value: String, toFormat: String = "yyyy-MM-dd", fromFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let date = strToDate(value: value, format: fromFormat)
        let formatter = DateFormatter()
        formatter.dateFormat = toFormat
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
    
    static func formatStringDate(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let newDate = dateFormatter.date(from: date)
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM d, yyyy")
        return dateFormatter.string(from: newDate!)
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
    
    static func genericList(data: String) -> [GenericSelectableItem]{
        var list = [GenericSelectableItem]()
        let json = Utils.jsonObject(string: data)
        for item in json {
            list.append(GenericSelectableItem(id: Utils.castString(value: item["id"]), label: Utils.castString(value: item["label"])))
        }
        return list
    }
    
    static func md5(string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
        
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    static func zero(n: Int) -> String {
        if n < 10 {
            return "0\(n)"
        }
        return String(describing: n)
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
    
    static func panel(type: String, objectId: String) -> Panel? {
        switch type {
            case "M":
                return try? DoctorDao(realm: try! Realm()).by(objectId: ObjectId(string: objectId))
            case "F":
                return try? PharmacyDao(realm: try! Realm()).by(objectId: ObjectId(string: objectId))
            case "C":
                return try? ClientDao(realm: try! Realm()).by(objectId: ObjectId(string: objectId))
            case "P":
                return try? PatientDao(realm: try! Realm()).by(objectId: ObjectId(string: objectId))
            case "T":
                return try? PotentialDao(realm: try! Realm()).by(objectId: ObjectId(string: objectId))
            case "CT":
                return try? ContactDao(realm: try! Realm()).by(objectId: ObjectId(string: objectId))
            default:
                break
        }
        return nil
    }
    
    static func colorByPanelType(panel: Panel) -> Color {
        return valueByPanelType(by: .color, panelType: panel.type) as! Color
    }
    
    static func imageByPanelType(panel: Panel) -> String {
        return valueByPanelType(by: .icon, panelType: panel.type) as! String
    }
    
    static func formByPanelType(panel: Panel) -> String {
        return valueByPanelType(by: .form, panelType: panel.type) as! String
    }
    
    static func formByPanelType(type: String) -> String {
        return valueByPanelType(by: .form, panelType: type) as! String
    }
    
    static func valueByPanelType(by type: PanelValueType, panelType: String) -> Any {
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
                "M": "DOCTOR-FORM",
                "F": "PHARMACY-FORM",
                "C": "CLIENT-FORM",
                "P": "PATIENT-FORM",
                "T": "POTENTIAL-FORM",
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
        
        if let val = data[index][panelType] {
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
    
    static func tabs(panelType: String, visitType: String) -> [String: [String: Any]] {
        let jsonString = Config.get(key: "MOV_TABS").complement ?? ""
        let data = Utils.jsonDictionary(string: jsonString)
        
        var tabs = [String: [String: Any]]()
        let visitTypes = data[panelType] as! Dictionary<String,Any>
        let opts = visitTypes[visitType] as! Dictionary<String,Any>
        
        opts.forEach { (key: String, value: Any) in
            let tabOpts = value as! Dictionary<String,Any>
            if let visible = tabOpts["visible"] as? Int {
                if visible == 1 {
                    tabs[key] = [
                        "required": Utils.castInt(value: tabOpts["required"]) == 1,
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

class DynamicUtils {
    
    static func tableValue(key: String, selected: [String]) -> String? {
        if !selected.isEmpty {
            switch key.uppercased() {
                case "BRICK":
                    return BrickDao(realm: try! Realm()).by(id: selected[0])?.name
                case "CATEGORY":
                    return CategoryDao(realm: try! Realm()).by(id: selected[0])?.name
                case "CITY":
                    return CityDao(realm: try! Realm()).by(id: selected[0])?.name
                case "COLLEGE":
                    return CollegeDao(realm: try! Realm()).by(id: selected[0])?.name
                case "COUNTRY":
                    return CountryDao(realm: try! Realm()).by(id: selected[0])?.name
                case "CYCLE":
                    return CycleDao(realm: try! Realm()).by(id: selected[0])?.displayName
                case "LINE":
                    return LineDao(realm: try! Realm()).by(id: selected[0])?.name
                case "MATERIAL":
                    return MaterialDao(realm: try! Realm()).by(id: selected[0])?.name
                case "PHARMACY-CHAIN":
                    return PharmacyChainDao(realm: try! Realm()).by(id: selected[0])?.name
                case "PHARMACY-TYPE":
                    return PharmacyTypeDao(realm: try! Realm()).by(id: selected[0])?.name
                case "PRICES-LIST":
                    return PricesListDao(realm: try! Realm()).by(id: selected[0])?.name
                case "SPECIALTY":
                    return SpecialtyDao(realm: try! Realm()).by(id: selected[0])?.name
                case "SECOND-SPECIALTY":
                    return SpecialtyDao(realm: try! Realm()).by(id: selected[0])?.name
                case "STYLE":
                    return StyleDao(realm: try! Realm()).by(id: selected[0])?.name
                case "ZONE":
                    return ZoneDao(realm: try! Realm()).by(id: selected[0])?.name
                default:
                    break
            }
        }
        return "--"
    }
    
    static func initForm(data: Dictionary<String, Any>) -> [DynamicFormTab] {
        var tabs = [DynamicFormTab]()
        data.forEach { (key: String, value: Any) in
            let tab = value as! Dictionary<String, Any>
            var groups = [DynamicFormGroup]()
            let groupsData = tab["groups"] as! [Dictionary<String, Any>]
            groupsData.forEach { group in
                var fields = [DynamicFormField]()
                let fieldsData = group["fields"] as! [Dictionary<String, Any>]
                
                fieldsData.forEach { field in
                    //print(field)
                    fields.append(try! DynamicFormField(from: field))
                }
                //print(fields)
                groups.append(DynamicFormGroup(title: Utils.castString(value: group["title"]), fields: fields))
            }
            tabs.append(DynamicFormTab(key: key, title: Utils.castString(value: tab["title"]), groups: groups))
        }
        return tabs
    }
    
    static func validate(form: DynamicForm) -> Bool {
        var valid = true
        form.tabs.forEach { tab in
            tab.groups.forEach { group in
                group.fields.forEach { field in
                    if field.localRequired && field.value.isEmpty {
                        valid = false
                    }
                }
            }
        }
        return valid
    }
    
    static func toJSON(form: DynamicForm) -> String {
        var data = [String: Any]()
        form.tabs.forEach { tab in
            tab.groups.forEach { group in
                group.fields.forEach { field in
                    data[field.key] = field.value
                }
            }
        }
        return (Utils.json(from: data) ?? "{}")
    }
    
    static func intTypeDecoding<T: CodingKey>(container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) throws -> Int {
        do {
            return try container.decode(Int.self, forKey: key)
        } catch DecodingError.keyNotFound {
            return 0
        } catch DecodingError.typeMismatch {
            let value = try container.decode(String.self, forKey: key)
            return Utils.castInt(value: value)
        } catch DecodingError.valueNotFound {
            return 0
        }
    }
    
    static func floatTypeDecoding<T: CodingKey>(container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) throws -> Float {
        do {
            return try container.decode(Float.self, forKey: key)
        } catch DecodingError.keyNotFound {
            return 0
        } catch DecodingError.typeMismatch {
            let value = try container.decode(String.self, forKey: key)
            return Utils.castFloat(value: value)
        } catch DecodingError.valueNotFound {
            return 0
        }
    }
    
    static func stringTypeDecoding<T: CodingKey>(container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) throws -> String {
        do {
            return try container.decode(String.self, forKey: key)
        } catch DecodingError.keyNotFound {
            return ""
        } catch DecodingError.valueNotFound {
            return ""
        }
    }
    
    static func adFieldsTypeDecoding<T: CodingKey>(container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) throws -> String {
        do {
            let obj = try container.decode(CustomAdditionalField.self, forKey: key)
            return obj.data
        } catch DecodingError.keyNotFound {
            return "{}"
        } catch DecodingError.valueNotFound {
            return "{}"
        }
    }
    
    static func listTypeDecoding<T: CodingKey, R: Object & Decodable>(container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) throws -> RealmSwift.List<R> {
        do {
            return try container.decode(RealmSwift.List<R>.self, forKey: key)
        } catch DecodingError.keyNotFound {
            return RealmSwift.List<R>()
        } catch DecodingError.valueNotFound {
            return RealmSwift.List<R>()
        }
    }
    
    static func objectTypeDecoding<T: CodingKey, R: Object & Decodable>(container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) throws -> R {
        do {
            return try container.decode(R.self, forKey: key)
        } catch DecodingError.keyNotFound {
            return R()
        } catch DecodingError.valueNotFound {
            return R()
        }
    }
    
    static func cloneObject<T: Object>(main: T?, temporal: T, skipped: [String]) {
        for (_, attr) in Mirror(reflecting: temporal).children.enumerated() {
            if let propertyName = attr.label as String? {
                let property = propertyName.replacingOccurrences(of: "_", with: "")
                if !skipped.contains(property) {
                    SwiftTryCatch.try({
                        main?.setValue(temporal.value(forKey: property), forUndefinedKey: property)
                    }, catch: { (error) in
                        print(String(describing: error?.description))
                    }, finally: {
                    })
                }
            }
        }
    }
    
    static func generateAdditional(form: DynamicForm) -> String {
        var data = [String: Any]()
        form.tabs.forEach { tab in
            tab.groups.forEach { group in
                group.fields.forEach { field in
                    if field.isAdditional {
                        data[field.key] = field.value
                    }
                }
            }
        }
        return Utils.json(from: data) ?? "{}"
    }
    
    static func fillForm(form: inout DynamicForm, base: String, additional: String = "{}") {
        let baseDict = Utils.jsonDictionary(string: base)
        let additionalDict = Utils.jsonDictionary(string: additional)
        for i in form.tabs.indices {
            for j in form.tabs[i].groups.indices {
                for k in form.tabs[i].groups[j].fields.indices {
                    let key = form.tabs[i].groups[j].fields[k].key
                    if let val = baseDict[key] {
                        form.tabs[i].groups[j].fields[k].value = Utils.anyToString(value: val)
                    } else if let val = additionalDict[key] {
                        form.tabs[i].groups[j].fields[k].value = Utils.anyToString(value: val)
                    }
                }
            }
        }
    }
    
}
