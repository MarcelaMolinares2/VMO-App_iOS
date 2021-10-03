//
//  MediaServer.swift
//  Sin Appuros
//
//  Created by VMO on 4/09/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import UIKit

class MediaServer: NetworkService {
    
    override init() {
        super.init(server: .media)
    }
    
    func loadRequest(path: String) -> URLRequest {
        return generateRequest(data: [String : Any](), method: "GET", path: path)
    }
    
    func uploadRequest(data: [String:Any], base64: String, completion: @escaping (Bool, Int16, Any)->()) {
        let request = upload(data: data, base64: base64)
        taskRequest(request: request, completion: completion)
    }
    
    func upload(data: [String:Any], base64: String) -> URLRequest {
        let defaults = UserDefaults.standard
        let dataURL = "\(Globals.MEDIA_SERVER)/upload"
        let url = URL(string: dataURL)!
        var bodyData = "base64=\(base64)&\(params(data: data))"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        bodyData = bodyData.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        bodyData = bodyData.replacingOccurrences(of: "+", with: "%2B")
        bodyData = bodyData.replacingOccurrences(of: "%0D", with: "")
        bodyData = bodyData.replacingOccurrences(of: "%0A", with: "")
        debugPrint(bodyData.data(using: .utf8) as Any)
        request.httpBody = bodyData.data(using: .utf8)
        request.addValue("lV4N1yq1lmRFwDPlH0btR1igODXrBWUL", forHTTPHeaderField: "app-key")
        request.addValue(defaults.string(forKey: "laboratory")!, forHTTPHeaderField: "app-lab")
        request.addValue("Bearer \(defaults.string(forKey: "media-token")!)", forHTTPHeaderField: "Autorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        return request
    }
    
}
