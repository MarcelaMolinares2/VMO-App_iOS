//
//  SyncTertiaryService.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import RealmSwift

class SyncPrimaryService: RequestOperation {
    
    override func main() {
        debugPrint("Primary Sync Start")
        self.prefix = "vm"
        
        services = [.activity, .client, .doctor, .patient, .pharmacy, .potential]
        
        /*let realm = try! Realm()
        try! realm.write {
            let allItems = realm.objects(Client.self)
            realm.delete(allItems)
        }*/
        
        step = 0
        get()
    }
    
}

class SyncSecondaryService: RequestOperation {
    
    override func main() {
        debugPrint("Secondary Sync Start")
        self.prefix = "vm/config"
        
        step = 0
        services = [.material, .product, .line]
        get()
    }
    
}

class SyncTertiaryService: RequestOperation {
    
    override func main() {
        debugPrint("Tertiary Sync Start")
        self.prefix = "vm/config"
        
        step = 0
        services = [.brick, .category, .city, .college, .config, .country, .cycle, .day_request_reason, .pharmacy_chain, .prices_list, .specialty, .style, .user, .zone]
        get()
    }
    
}
