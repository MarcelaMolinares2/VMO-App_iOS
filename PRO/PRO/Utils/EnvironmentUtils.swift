//
//  EnvironmentUtils.swift
//  PRO
//
//  Created by VMO on 24/06/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import Foundation

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
