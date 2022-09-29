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
    
    static func store(file: String, table: String, field: String, id: Int, localId: ObjectId) {
        let media = item(table: table, field: field, id: id, localId: localId)
        media.date = Utils.currentDateTime()
    }
    
    static func item(table: String, field: String, id: Int, localId: ObjectId) -> MediaItem {
        let media = MediaItem()
        media.table = table
        media.field = field
        media.serverId = id
        media.localId = localId
        return media
    }
    
    static func store(uiImage: UIImage?, table: String, field: String, id: Int, localId: ObjectId) {
        let media = item(table: table, field: field, id: id, localId: localId)
        media.date = Utils.currentDateTime()
        media.ext = "jpg"
        
        if let data = uiImage?.jpegData(compressionQuality: 0.3) {
            FileUtils.create(path: "media/\(media.table)/\(media.localId.stringValue)/\(media.field)")
            try? data.write(to: mediaURL(media: media))
            MediaItemDao(realm: try! Realm()).store(mediaItem: media)
        }
    }
    
    static func remove(table: String, field: String, localId: ObjectId) {
        let media = MediaItem(value: MediaItemDao(realm: try! Realm()).by(table: table, field: field, localId: localId))
        MediaItemDao(realm: try! Realm()).remove(mediaItem: media)
        FileUtils.remove(media: media)
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
            .appendingPathComponent("\(media.localId.stringValue)")
            .appendingPathComponent("\(media.field)") {
            return pathComponent
        }
        return NSURL() as URL
    }
    
    static func awsPath(media: MediaItem) -> String {
        if let laboratoryHash = UserDefaults.standard.string(forKey: Globals.LABORATORY_HASH) {
            return "\(laboratoryHash)/\(media.table)/\(media.serverId)/\(media.field)/resource.\(media.ext)"
        }
        return "\("LAB-PATH")/\(media.table)/\(media.serverId)/\(media.field)/resource.\(media.ext)"
    }
    
}

class FileUtils {
    
    static func syncZip(type: String) -> URL {
        create(path: "sync")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(fileURLWithPath: documentsDirectory)
        let dataPath = docURL.appendingPathComponent("sync/\(UserDefaults.standard.string(forKey: Globals.LABORATORY_PATH) ?? "")_\(JWTUtils.sub())_\(type)_\(Utils.dateFormat(date: Date(), format: "yyyyMMddHHmmss")).zip")
        return dataPath
    }
    
    static func sync(type: String, data: [String]) -> URL {
        create(path: "sync")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(fileURLWithPath: documentsDirectory)
        let dataPath = docURL.appendingPathComponent("sync/\(type).txt")
        do {
            try data.joined(separator: "\n").write(to: dataPath, atomically: false, encoding: .utf8)
        } catch let error as NSError {
            print("SYNC FILE WRITE", error)
        }
        return dataPath
    }
    
    static func create(path: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(fileURLWithPath: documentsDirectory)
        let dataPath = docURL.appendingPathComponent(path)
        if !FileManager.default.fileExists(atPath: dataPath.relativePath) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.relativePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("\(path): \(error.localizedDescription)")
            }
        }
    }
    
    static func folder(path: String) -> URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(fileURLWithPath: documentsDirectory)
        let dataPath = docURL.appendingPathComponent(path)
        return dataPath
    }
    
    static func exists(media: MediaItem) -> Bool {
        let pathComponent = MediaUtils.mediaURL(media: media)
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return true
        }
        return false
    }
    
    static func remove(media: MediaItem) {
        let pathComponent = MediaUtils.mediaURL(media: media)
        if exists(media: media) {
            do {
                try FileManager.default.removeItem(at: pathComponent)
            } catch {
                print("\(pathComponent.path): \(error.localizedDescription)")
            }
        }
    }
    
}
