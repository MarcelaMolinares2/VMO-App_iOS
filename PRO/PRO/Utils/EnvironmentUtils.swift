//
//  EnvironmentUtils.swift
//  PRO
//
//  Created by VMO on 24/06/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

class SyncUtils {
    
    static let keys: [SyncOperationLevel: String] = [
        .onDemand: "",
        .recurrent: "SYNC_OP_RECURRENT",
        .primary: "SYNC_OP_PRIMARY",
        .secondary: "SYNC_OP_SECONDARY",
        .tertiary: "SYNC_OP_TERTIARY",
        .quaternary: "SYNC_OP_QUATERNARY"
    ]
    
    static func updateInterval(level: SyncOperationLevel, timestamp: Double = NSDate().timeIntervalSince1970) {
        guard let key = keys[level] else { return }
        UserDefaults.standard.set(timestamp, forKey: key)
    }
    
    static func clear() {
        keys.forEach { (key: SyncOperationLevel, value: String) in
            if !value.isEmpty {
                updateInterval(level: key, timestamp: 0)
            }
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
    
    static func initTabs(data: [String: [String: Any]]) -> [[MovementTab]] {
        var mainTabs = [MovementTab]()
        var moreTabs = [MovementTab]()
        
        mainTabs.append(MovementTab(key: "BASIC", icon: iconTabs(key: "BASIC"), label: "envBasic", required: true))
        moreTabs.append(MovementTab(key: "BACK", icon: iconTabs(key: "BACK"), label: "envBack", required: true))
        
        var i = 0
        let baseTabs = data.sorted(by: { (el1: (key: String, value: [String : Any]), el2: (key: String, value: [String : Any])) -> Bool in
            if Utils.castInt(value: el1.value["index"]) < Utils.castInt(value: el2.value["index"]) {
                return true
            }
            return false
        })
        baseTabs.forEach { (key: String, value: [String : Any]) in
            if baseTabs.count > 4 && i > 2 {
                moreTabs.append(MovementTab(key: key, icon: iconTabs(key: key), label: "env\(key.capitalized)", required: value["required"] as! Bool))
            } else {
                mainTabs.append(MovementTab(key: key, icon: iconTabs(key: key), label: "env\(key.capitalized)", required: value["required"] as! Bool))
            }
            i += 1
        }
        if baseTabs.count > 4 {
            mainTabs.append(MovementTab(key: "MORE", icon: iconTabs(key: "MORE"), label: "envMore", required: true))
        }
        return [mainTabs, moreTabs]
    }
    
    static func iconTabs(key: String) -> String {
        let data = [
            "MATERIAL": "ic-material",
            "PROMOTED": "ic-promoted",
            "ROTATION": "ic-rotation",
            "SHOPPING": "ic-shopping",
            "STOCK": "ic-stock",
            "TRANSFERENCE": "ic-transference",
            "BACK": "ic-back",
            "MORE": "ic-more"
        ]
        return data[key] ?? "ic-dynamic-tab-basic"
    }
    
    static func existsMovementOpen(objectId: ObjectId, type: String) -> Bool {
        return true
    }
    
}

class PanelUtils {
    
    static func panel(type: String, objectId: ObjectId) -> Panel? {
        switch type {
            case "M":
                return DoctorDao(realm: try! Realm()).by(objectId: objectId)
            case "F":
                return PharmacyDao(realm: try! Realm()).by(objectId: objectId)
            case "C":
                return ClientDao(realm: try! Realm()).by(objectId: objectId)
            case "P":
                return PatientDao(realm: try! Realm()).by(objectId: objectId)
            case "T":
                return PotentialDao(realm: try! Realm()).by(objectId: objectId)
            case "CT":
                return ContactDao(realm: try! Realm()).by(objectId: objectId)
            default:
                break
        }
        return nil
    }
    
    static func panel(type: String, id: Int) -> Panel? {
        switch type {
            case "M":
                return DoctorDao(realm: try! Realm()).by(id: String(id))
            case "F":
                return PharmacyDao(realm: try! Realm()).by(id: String(id))
            case "C":
                return ClientDao(realm: try! Realm()).by(id: String(id))
            case "P":
                return PatientDao(realm: try! Realm()).by(id: String(id))
            case "T":
                return PotentialDao(realm: try! Realm()).by(id: String(id))
            case "CT":
                return ContactDao(realm: try! Realm()).by(id: String(id))
            default:
                break
        }
        return nil
    }
    
    static func colorByPanelType(panel: Panel) -> Color {
        return valueByPanelType(by: .color, panelType: panel.type) as! Color
    }
    
    static func colorByPanelType(panelType: String) -> Color {
        return valueByPanelType(by: .color, panelType: panelType) as! Color
    }
    
    static func iconByPanelType(panel: Panel) -> String {
        return valueByPanelType(by: .icon, panelType: panel.type) as! String
    }
    
    static func iconByPanelType(panelType: String) -> String {
        return valueByPanelType(by: .icon, panelType: panelType) as! String
    }
    
    static func formByPanelType(panel: Panel) -> String {
        return valueByPanelType(by: .form, panelType: panel.type) as! String
    }
    
    static func formByPanelType(type: String) -> String {
        return valueByPanelType(by: .form, panelType: type) as! String
    }
    
    static func titleByPanelType(panelType: String) -> String {
        return valueByPanelType(by: .title, panelType: panelType) as! String
    }
    
    static func duplicationKeyByPanelType(panelType: String) -> String {
        return valueByPanelType(by: .duplication, panelType: panelType) as! String
    }
    
    static func valueByPanelType(by type: PanelValueType, panelType: String) -> Any {
        let data = [
            [
                "M": Color.cPanelMedic,
                "F": Color.cPanelPharmacy,
                "C": Color.cPanelClient,
                "P": Color.cPanelPatient,
                "T": Color.cPanelPotential,
                "D": Color.cPrimary
            ],
            [
                "M": "ic-doctor",
                "F": "ic-pharmacy",
                "C": "ic-client",
                "P": "ic-patient",
                "T": "ic-potential",
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
                "M": "modDoctor",
                "F": "modPharmacy",
                "C": "modClient",
                "P": "modPatient",
                "T": "modPotential",
                "D": ""
            ],
            [
                "M": "P_DOC_DUPLICATION_FIELDS",
                "F": "P_PHA_DUPLICATION_FIELDS",
                "C": "P_CLI_DUPLICATION_FIELDS",
                "P": "P_PAT_DUPLICATION_FIELDS",
                "T": "P_PPT_DUPLICATION_FIELDS",
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
            case .duplication:
                index = 4
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
    
    static func visitsBackground(user: PanelUser) -> Color {
        if user.visitsCycle == 0 {
            return Color.cTrafficLightRed
        } else if user.visitsCycle >= user.visitsFee {
            return Color.cTrafficLightGreen
        }
        return Color.cTrafficLightYellow
    }
    
    enum PanelValueType {
        case color, icon, form, title, duplication
    }
    
    static func castLocations(lm: [PanelLocationModel]) -> [PanelLocation] {
        var locations = [PanelLocation]()
        lm.forEach { l in
            let location = PanelLocation()
            location.id = l.id
            location.address = l.address
            location.latitude = l.latitude
            location.longitude = l.longitude
            location.type = l.type
            location.geocode = l.geocode
            location.cityId = l.cityId
            location.complement = l.complement
            locations.append(location)
        }
        return locations
    }
    
    static func castContactControl(cc: [PanelContactControlModel]) -> [ContactControlPanel] {
        var ccs = [ContactControlPanel]()
        cc.forEach { c in
            let contactControlPanel = ContactControlPanel()
            contactControlPanel.contactControlTypeId = c.contactControlType.id
            contactControlPanel.status = c.status ? 1 : 0
            ccs.append(contactControlPanel)
        }
        return ccs
    }
    
    static func castVisitingHours(vh: [PanelVisitingHourModel]) -> [PanelVisitingHour] {
        var visitingHours = [PanelVisitingHour]()
        vh.forEach { v in
            let visitingHour = PanelVisitingHour()
            visitingHour.dayOfWeek = v.dayOfWeek
            visitingHour.amHourStart = Utils.dateFormat(date: v.amHourStart, format: "HH:mm")
            visitingHour.amHourEnd = Utils.dateFormat(date: v.amHourEnd, format: "HH:mm")
            visitingHour.pmHourStart = Utils.dateFormat(date: v.pmHourStart, format: "HH:mm")
            visitingHour.pmHourEnd = Utils.dateFormat(date: v.pmHourEnd, format: "HH:mm")
            visitingHour.amStatus = v.amStatus ? 1 : 0
            visitingHour.pmStatus = v.pmStatus ? 1 : 0
            visitingHours.append(visitingHour)
        }
        return visitingHours
    }
    
    static func duplication<T: Object & Codable>(from: T.Type, object: T, panelType: String, classKeys: [String: String]) -> [T] {
        if let keyValue = Config.get(key: duplicationKeyByPanelType(panelType: panelType)).complement {
            if !keyValue.isEmpty {
                let fields = keyValue.components(separatedBy: ",")
                var orConditions: [String] = []
                fields.forEach { field in
                    let keys = field.components(separatedBy: ":")
                    var andConditions: [String] = []
                    keys.forEach { key in
                        let classAttr = findClassKey(classKeys: classKeys, k: key)
                        if let keyType = findClassKeyType(object: object, key: classAttr) {
                            if keyType == Persisted<String>.self || keyType == Persisted<Optional<String>>.self {
                                andConditions.append("\(classAttr) == '\(Utils.castString(value: object.value(forKey: classAttr)))'")
                            } else {
                                andConditions.append("\(classAttr) == \(Utils.castString(value: object.value(forKey: classAttr)))")
                            }
                        }
                    }
                    orConditions.append("(\(andConditions.joined(separator: " and ")))")
                }
                let realm = try! Realm()
                return Array(realm.objects(from.self).filter(orConditions.joined(separator: " or ")))
            }
        }
        return []
    }
    
    static func couldValidDuplicates(panelType: String) -> Bool {
        if let keyValue = Config.get(key: duplicationKeyByPanelType(panelType: panelType)).complement {
            return !keyValue.isEmpty
        }
        return false
    }
    
    static func findClassKeyType<T: Object & Codable>(object: T, key: String) -> Any.Type? {
        var foundType: Any.Type = Any.self
        for property in Mirror(reflecting: object).children {
            if Utils.castString(value: property.label) == "_\(key)" {
                foundType = type(of: property.value)
            }
        }
        return foundType
    }
    
    static func findClassKey(classKeys: [String: String], k: String) -> String {
        var rs = ""
        classKeys.forEach { (key: String, value: String) in
            if value == k {
                rs = key
            }
        }
        return rs
    }
    
    static func defaultVisitsFee(by type: String) -> Int {
        let obj = Utils.jsonDictionary(string: Config.get(key: "MOV_DEFAULT_FEES").complement ?? "{}")
        print(obj)
        if let value = obj[type] {
            return Utils.castInt(value: value, defaultValue: 1)
        }
        return 1
    }
    
    func categorization(field: DynamicFormField) -> Int {
        return 0
    }
    
    static func categorizationSettings(by type: String) -> PanelCategorizationSettings {
        let obj = Utils.jsonDictionary(string: Config.get(key: "P_CATEGORIZATION_SETTINGS").complement ?? "{}")
        if let value = obj[type] {
            do {
                return try JSONDecoder().decode(PanelCategorizationSettings.self, from: Utils.castString(value: value).data(using: .utf8)!)
            } catch {
                print(error)
            }
        }
        return PanelCategorizationSettings()
    }
    
}

class TimeUtils {
    
    static func day(_ by: Int) -> String {
        let days = [
            NSLocalizedString("envMonday", comment: "Monday"),
            NSLocalizedString("envTuesday", comment: "Tuesday"),
            NSLocalizedString("envWednesday", comment: "Wednesday"),
            NSLocalizedString("envThursday", comment: "Thursday"),
            NSLocalizedString("envFriday", comment: "Friday"),
            NSLocalizedString("envSaturday", comment: "Saturday"),
            NSLocalizedString("envSunday", comment: "Sunday")
        ]
        return days[by]
    }
    
    static func months() -> [GenericPickerItem] {
        return [
            GenericPickerItem(value: 1, label: NSLocalizedString("envJanuary", comment: "")),
            GenericPickerItem(value: 2, label: NSLocalizedString("envFebruary", comment: "")),
            GenericPickerItem(value: 3, label: NSLocalizedString("envMarch", comment: "")),
            GenericPickerItem(value: 4, label: NSLocalizedString("envApril", comment: "")),
            GenericPickerItem(value: 5, label: NSLocalizedString("envMay", comment: "")),
            GenericPickerItem(value: 6, label: NSLocalizedString("envJune", comment: "")),
            GenericPickerItem(value: 7, label: NSLocalizedString("envJuly", comment: "")),
            GenericPickerItem(value: 8, label: NSLocalizedString("envAugust", comment: "")),
            GenericPickerItem(value: 9, label: NSLocalizedString("envSeptember", comment: "")),
            GenericPickerItem(value: 10, label: NSLocalizedString("envOctober", comment: "")),
            GenericPickerItem(value: 11, label: NSLocalizedString("envNovember", comment: "")),
            GenericPickerItem(value: 12, label: NSLocalizedString("envDecember", comment: ""))
        ]
    }
    
    static func monthDays(m: Int) -> [GenericPickerItem] {
        var days = [GenericPickerItem]()
        for d in 1..<monthDayLimit(month: m) + 1 {
            days.append(GenericPickerItem(value: d, label: String(d)))
        }
        return days
    }
    
    static func monthDayLimit(month: Int) -> Int {
        switch month {
            case 2:
                return 29
            case 4, 6, 9, 11:
                return 30
            default:
                return 31
        }
    }
    
    static func monthName(m: Int) -> String {
        if let month = months().first(where: { gpi in
            gpi.value == m
        }) {
            return month.label
        }
        return ""
    }
    
    static func hourTo(time: Date) -> Int {
        return hourTo(time: Utils.hourFormat(date: time))
    }
    
    static func hourTo(time: String) -> Int {
        return Utils.castInt(value: time.replacingOccurrences(of: ":", with: ""))
    }
    
}
