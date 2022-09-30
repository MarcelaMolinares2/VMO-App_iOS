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
        services = [.brick, .category, .city, .contact_control_type, .country, .menu, .pharmacy_chain, .product_brand, .specialty, .user, .zone, .user_preference, .movement_fail_reason, .panel_delete_reason]
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

class SyncOnDemandPanelsService: DownloadRequestOperation {
    
    override func main() {
        debugPrint("SyncOnDemandPanelsService")
        self.prefix = "vm"
        
        services = [.client, .doctor, .patient, .pharmacy, .potential]
        
        step = 0
        get()
    }
    
}

class SyncOnDemandGeneralConfigService: DownloadRequestOperation {
    
    override func main() {
        debugPrint("SyncOnDemandGeneralConfigService")
        self.prefix = "vm"
        
        services = [.config]
        
        step = 0
        get()
    }
    
}

class SyncOnDemandGeneralConfigNestedService: DownloadRequestOperation {
    
    override func main() {
        debugPrint("SyncOnDemandGeneralConfigService")
        self.prefix = "vm/config"
        
        services = [.cycle, .material, .material_plain]
        
        step = 0
        get()
    }
    
}

class SyncOnDemandDiaryService: DownloadRequestOperation {
    
    override func main() {
        debugPrint("SyncOnDemandDiaryService")
        self.prefix = "vm"
        
        services = [.diary]
        
        step = 0
        get()
    }
    
}
