//
//  FileUtils.swift
//  PRO
//
//  Created by VMO on 15/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import Foundation
import SwiftUI

class MediaUtils {
    
    static func store(uiImage: UIImage?) {
        
        if let data = uiImage?.jpegData(compressionQuality: 0.9) {
            try? data.write(to: mediaURL(media: []))
        }
    }
    
    static func mediaURL(media: Any) -> URL {
        /*let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url
            .appendingPathComponent("resources")?
            .appendingPathComponent("\(resource.id)")
            .appendingPathComponent("resource")
            .appendingPathExtension(resource.extension_ ?? "saf") {
            return pathComponent
        }*/
        return NSURL() as URL
    }
    
}
