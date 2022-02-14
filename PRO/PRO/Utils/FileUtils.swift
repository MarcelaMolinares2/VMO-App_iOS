//
//  FileUtils.swift
//  PRO
//
//  Created by VMO on 15/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import Foundation
import SwiftUI
import RealmSwift

class MediaUtils {
    
    static func store(file: String, table: String, field: String, id: Int, localId: String) {
        let media = item(table: table, field: field, id: id, localId: localId)
        media.date = Utils.currentDateTime()
    }
    
    static func item(table: String, field: String, id: Int, localId: String) -> MediaItem {
        let media = MediaItem()
        media.table = table
        media.field = field
        media.item = id
        media.localItem = localId
        return media
    }
    
    static func store(uiImage: UIImage?, table: String, field: String, id: Int, localId: String) {
        let media = item(table: table, field: field, id: id, localId: localId)
        media.date = Utils.currentDateTime()
        media.ext = "jpg"
        
        if let data = uiImage?.jpegData(compressionQuality: 0.9) {
            FileUtils.create(path: "media/\(media.table)/\(media.localItem)/\(media.field)")
            try? data.write(to: mediaURL(media: media))
            MediaItemDao(realm: try! Realm()).store(mediaItem: media)
        }
    }
    
    static func mediaURL(media: MediaItem) -> URL {
        return mediaPath(media: media)
            .appendingPathComponent("resource")
            .appendingPathExtension(media.ext)
    }
    
    static func mediaPath(media: MediaItem) -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url
            .appendingPathComponent("media")?
            .appendingPathComponent("\(media.table)")
            .appendingPathComponent("\(media.localItem)")
            .appendingPathComponent("\(media.field)") {
            return pathComponent
        }
        return NSURL() as URL
    }
    
    static func awsPath(media: MediaItem) -> String {
        if let laboratoryHash = UserDefaults.standard.string(forKey: Globals.LABORATORY_HASH) {
            return "\(laboratoryHash)/\(media.table)/\(media.id)/\(media.field)/resource.\(media.ext)"
        }
        return "\("LAB-PATH")/\(media.table)/\(media.id)/\(media.field)/resource.\(media.ext)"
    }
    
}

class FileUtils {
    
    static func create(path: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent(path)
        if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("\(path): \(error.localizedDescription)")
            }
        }
    }
    
    static func exists(media: MediaItem) -> Bool {
        let pathComponent = MediaUtils.mediaURL(media: media)
        print(pathComponent)
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return true
        }
        return false
    }
    
}
