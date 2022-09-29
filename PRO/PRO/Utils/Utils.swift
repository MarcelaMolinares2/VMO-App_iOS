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
    
    static func objArrayToJSON<T>(_ data: RealmSwift.List<T>) -> String where T : Encodable {
        var result = [String]()
        for item in data {
            result.append(try! objToJSON(item))
        }
        return json(from: result) ?? "[]"
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
    
    static func hourFormat(date: Date, format: String = "HH:mm") -> String {
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
        UIApplication.shared.keyWindow?.rootViewController?.present(activityViewController, animated: true, completion: nil)
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
    
    static func genericList(data: String) -> [GenericSelectableItem]{
        var list = [GenericSelectableItem]()
        let json = Utils.jsonObject(string: data)
        for item in json {
            list.append(GenericSelectableItem(value: Utils.castString(value: item["id"]), label: Utils.castString(value: item["label"])))
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

class DynamicUtils {
    
    static func tableValue(key: String, selected: [String], defaultValue: String = "--") -> String {
        if !selected.isEmpty {
            switch key.uppercased() {
                case "BRICK":
                    return BrickDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "CATEGORY":
                    return CategoryDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "CITY":
                    return CityDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "COLLEGE":
                    return CollegeDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "COUNTRY":
                    return CountryDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "CYCLE":
                    return CycleDao(realm: try! Realm()).by(id: selected[0])?.displayName ?? defaultValue
                case "LINE":
                    return LineDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "MATERIAL":
                    return MaterialDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "PHARMACY-CHAIN":
                    return PharmacyChainDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "PHARMACY-TYPE":
                    return PharmacyTypeDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "PRICES-LIST":
                    return PricesListDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "PRODUCT":
                    return ProductDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "SPECIALTY":
                    return SpecialtyDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "SECOND-SPECIALTY":
                    return SpecialtyDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "STYLE":
                    return StyleDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                case "ZONE":
                    return ZoneDao(realm: try! Realm()).by(id: selected[0])?.name ?? defaultValue
                default:
                    break
            }
        }
        return defaultValue
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
        serializeForm(tabs: &tabs)
        return tabs
    }
    
    static func serializeForm(tabs: inout [DynamicFormTab]) {
        let user = UserDao(realm: try! Realm()).logged()
        tabs.indices.forEach { i in
            tabs[i].groups.indices.forEach { j in
                tabs[i].groups[j].fields.indices.forEach {
                    let field = tabs[i].groups[j].fields[$0]
                    tabs[i].groups[j].fields[$0].visible.country = field.countries.isEmpty || field.countries == "0" || field.countries.components(separatedBy: ",").contains(String(user?.countryId ?? 0))
                    tabs[i].groups[j].fields[$0].visible.city = field.cities.isEmpty || field.cities == "0" || field.cities.components(separatedBy: ",").contains(String(user?.cityId ?? 0))
                }
            }
        }
        cleanForm(tabs: &tabs)
    }
    
    static func cleanForm(tabs: inout [DynamicFormTab]) {
        tabs.indices.forEach { i in
            tabs[i].groups.indices.forEach {
                tabs[i].groups[$0].fields = tabs[i].groups[$0].fields.filter({ field in
                    field.visible.country && field.visible.city
                })
            }
        }
        tabs.indices.forEach { i in
            tabs[i].groups = tabs[i].groups.filter({ group in
                !group.fields.isEmpty
            })
        }
        tabs = tabs.filter({ tab in
            !tab.groups.isEmpty
        })
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
    
    static func boolTypeDecoding<T: CodingKey>(container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) throws -> Bool {
        do {
            return try container.decode(Bool.self, forKey: key)
        } catch DecodingError.keyNotFound {
            return false
        } catch DecodingError.typeMismatch {
            do {
                let value = try container.decode(String.self, forKey: key)
                return Utils.castInt(value: value) == 1
            } catch DecodingError.typeMismatch {
                do {
                    let value = try container.decode(Int.self, forKey: key)
                    return value == 1
                } catch DecodingError.typeMismatch {
                    return false
                }
            }
        } catch DecodingError.valueNotFound {
            return false
        }
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
        } catch DecodingError.typeMismatch {
            do {
                let value = try container.decode(Int.self, forKey: key)
                return String(value)
            } catch {
                return ""
            }
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
        } catch DecodingError.typeMismatch {
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
        } catch DecodingError.typeMismatch {
            return R()
        }
    }
    
    static func flagTypeDecoding<T: CodingKey>(container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key) throws -> Int {
        do {
            return try container.decode(Int.self, forKey: key)
        } catch DecodingError.keyNotFound {
            return 0
        } catch DecodingError.typeMismatch {
            let value = try container.decode(String.self, forKey: key)
            switch value {
                case "Y":
                    return 1
                case "N":
                    return 0
                default:
                    return Utils.castInt(value: value)
            }
        } catch DecodingError.valueNotFound {
            return 0
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
    
    static func fillFormField(form: inout DynamicForm, key: String, value: String = "") {
        for i in form.tabs.indices {
            for j in form.tabs[i].groups.indices {
                for k in form.tabs[i].groups[j].fields.indices {
                    if form.tabs[i].groups[j].fields[k].key == key {
                        form.tabs[i].groups[j].fields[k].value = value
                    }
                }
            }
        }
    }
    
    static func fillFormCategories(realm: Realm, form: inout DynamicForm, categories: [PanelCategoryPanel]) {
        for i in form.tabs.indices {
            for j in form.tabs[i].groups.indices {
                for k in form.tabs[i].groups[j].fields.indices {
                    if form.tabs[i].groups[j].fields[k].source == "category" {
                        let c = categories.filter { pcp in
                            CategoryDao(realm: realm).by(id: pcp.categoryId)?.categoryTypeId == form.tabs[i].groups[j].fields[k].moreOptions.categoryType
                        }
                        if !c.isEmpty {
                            form.tabs[i].groups[j].fields[k].value = String(c.first?.categoryId ?? 0)
                        }
                    }
                }
            }
        }
    }
    
    static func findFormField(form: DynamicForm, key: String) -> DynamicFormField? {
        var rs: DynamicFormField? = nil
        form.tabs.forEach { tab in
            tab.groups.forEach { group in
                group.fields.forEach { field in
                    if field.key == key {
                        rs = field
                    }
                }
            }
        }
        return rs
    }
    
    static func findFormField(form: DynamicForm, source: String) -> [DynamicFormField] {
        var rs: [DynamicFormField] = []
        form.tabs.forEach { tab in
            tab.groups.forEach { group in
                group.fields.forEach { field in
                    if field.source == source {
                        rs.append(field)
                    }
                }
            }
        }
        return rs
    }
    
    static func formatLabel(s: String) -> String {
        return "env\(s.components(separatedBy: ".").last?.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ").capitalized.replacingOccurrences(of: " ", with: "") ?? "")"
    }
    
    static func transactionType(action: FormAction) -> String {
        return action == .create ? "CREATE" : "UPDATE"
    }
    
    static func jsonValue(data: String, selected: [String], defaultValue: String = "envSelect") -> String {
        if !selected.isEmpty {
            let list = Utils.genericList(data: data)
            let rs = list.filter { item -> Bool in
                item.value == selected[0]
            }
            if !rs.isEmpty {
                return rs[0].label
            }
        }
        return defaultValue.localized()
    }
    
}

class TextUtils {
    
    static func dateRange(values: [String]) -> String {
        if values.count > 1 {
            return dateRange(values: [Utils.strToDate(value: values[0]), Utils.strToDate(value: values[1])])
        }
        return ""
    }
    
    static func dateRange(values: [Date]) -> String {
        if values.count > 1 {
            return String(format: NSLocalizedString("envFromTo", comment: "From %@ to %@"), Utils.dateFormat(date: values[0], format: "dd MMM yyy"), Utils.dateFormat(date: values[1], format: "dd MMM yyy"))
        }
        return ""
    }
    
    static func serializeEnv(s: String) -> String {
        return NSLocalizedString("env\(s.replacingOccurrences(of: "-", with: "_").components(separatedBy: "_").map { $0.capitalized }.joined(separator: ""))", comment: s)
    }
    
}

class EnvironmentUtils {
    
    static var osTheme: UIUserInterfaceStyle {
        return UIScreen.main.traitCollection.userInterfaceStyle
    }
    
}
