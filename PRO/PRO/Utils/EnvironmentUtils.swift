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
    
    static func visitsBackground(user: PanelUser) -> Color {
        if user.visitsCycle == 0 {
            return Color.cTrafficLightRed
        } else if user.visitsCycle >= user.visitsFee {
            return Color.cTrafficLightGreen
        }
        return Color.cTrafficLightYellow
    }
    
    enum PanelValueType {
        case color, icon, form, title
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
    
}
