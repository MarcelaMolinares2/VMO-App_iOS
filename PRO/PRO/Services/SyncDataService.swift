//
//  SyncTertiaryService.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import RealmSwift

class SyncOnDemandService: DownloadRequestOperation {
    
    override func main() {
        debugPrint("On Demand Sync Start")
        self.prefix = "vm"
        
        services = [.config, .cycle]
        
        step = 0
        get()
    }
    
}

class SyncRecurrentService: DownloadRequestOperation {
    
    override func main() {
        debugPrint("Recurrent Sync Start")
        self.prefix = "vm"
        
        services = [.config]
        
        step = 0
        get()
    }
    
}

class SyncPrimaryService: DownloadRequestOperation {
    
    override func main() {
        debugPrint("Primary Sync Start")
        self.prefix = "vm"
        
        services = [.activity, .client, .doctor, .patient, .pharmacy, .potential]
        
        step = 0
        get()
    }
    
}

class SyncSecondaryService: DownloadRequestOperation {
    
    override func main() {
        debugPrint("Secondary Sync Start")
        self.prefix = "vm/config"
        
        step = 0
        services = [.material, .material_plain, .product, .line, .cycle]
        get()
    }
    
}

class SyncTertiaryService: DownloadRequestOperation {
    
    override func main() {
        debugPrint("Tertiary Sync Start")
        self.prefix = "vm/config"
        
        step = 0
        services = [.brick, .category, .city, .contact_control_type, .country, .menu, .pharmacy_chain, .specialty, .user, .zone]
        get()
    }
    
}

class SyncQuaternaryService: DownloadRequestOperation {
    
    override func main() {
        debugPrint("Quaternary Sync Start")
        self.prefix = "vm/config"
        
        step = 0
        services = [.college, .day_request_reason, .pharmacy_type, .prices_list, .style, .concept_expense]
        get()
    }
    
}

class SyncUploadService: UploadRequestOperation {
    
    override func main() {
        self.prefix = "vm"

        step = 0
        services = [.doctor]
        upload()
    }
    
}

class SyncUploadOnDemandService: UploadRequestOperation {
    
    init(service: UploadRequestServices) {
        super.init()
        services = [service]
    }
    
    override func main() {
        self.prefix = "vm"
        
        step = 0
        upload()
    }
    
}
