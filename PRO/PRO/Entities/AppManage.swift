//
//  AppManage.swift
//  PRO
//
//  Created by VMO on 4/12/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import Foundation
import RealmSwift

class FormEntity {
    var objectId: ObjectId? = nil
    var type = ""
    var options = [String: Any]()
    
    init(objectId: ObjectId?, type: String = "", options: [String: Any] = [String: Any]() ) {
        self.objectId = objectId
        self.type = type
        self.options = options
    }
    
    func go(path: String, router: ViewRouter) {
        router.data = self
        router.currentPage = path
    }
}

class SectionCard {
    
    var title: String
    var details: [SectionDetail]
    
    init(title: String, details: [SectionDetail]) {
        self.title = title
        self.details = details
    }
    
    static func to(client: Client) -> [SectionCard] {
        var data = [SectionCard]()
        
        var detailBasic = [SectionDetail]()
        detailBasic.append(SectionDetail(title: "envFullName", content: client.name ?? "", field: ""))
        detailBasic.append(SectionDetail(title: "envDNI", content: client.idNumber, field: ""))
        /*detailBasic.append(SectionDetail(title: "envLocation", content: "\(client.city?.name ?? ""), \(client.country?.name ?? "")", field: ""))
        detailBasic.append(SectionDetail(title: "envZone", content: client.zone?.name ?? "", field: ""))
        detailBasic.append(SectionDetail(title: "envBrick", content: client.brick?.name ?? "", field: ""))
        detailBasic.append(SectionDetail(title: "envPhone", content: client.phone ?? "", field: "", type: .phone))
        detailBasic.append(SectionDetail(title: "envEmail", content: client.email ?? "", field: "", type: .email))
        */
        data.append(SectionCard(title: "envBasic", details: detailBasic))
        
        var detailAdditional = [SectionDetail]()

        var visitTypes = [String]()
        if client.visitFTF == 1 {
            visitTypes.append(NSLocalizedString("envFTF", comment: ""))
        }
        if client.visitVirtual == 1 {
            visitTypes.append(NSLocalizedString("envVirtual", comment: ""))
        }
        
        detailAdditional.append(SectionDetail(title: "envVisitType", content: visitTypes.joined(separator: " / "), field: ""))
        
        data.append(SectionCard(title: "envAdditionalInfo", details: detailAdditional))
        return data
    }
    
}

class SectionDetail {
    
    var title: String
    var content: String
    var field: String
    var type: ContentType
    
    init(title: String, content: String, field: String, type: ContentType = .text) {
        self.title = title
        self.content = content
        self.field = field
        self.type = type
    }
    
}

enum ContentType {
    case text, email, phone, image, url
}

enum ViewLayout {
    case list, map, filter
}

enum PanelLayout {
    case doctor, pharmacy, client, patient, potential, none
}

enum WrapperLayout {
    case list, form
}

enum ConnectionStatus {
    case unknown, connected, error
}

enum PanelGlobalSearchLayout {
    case list, searching, error
}
