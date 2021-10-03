//
//  NetworkService.swift
//  Sin Appuros
//
//  Created by VMO on 4/09/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import Foundation

class NetworkService {
    
    enum Server: String {
        case master, application, media
    }
    
    var server: Server!
    var urlServer: String!
    
    var defaults: UserDefaults!
    
    init() {
        self.server = .application
        defaults = UserDefaults.standard
    }
    
    init(server: Server) {
        defaults = UserDefaults.standard
        self.server = server
        switch self.server {
        case .application:
            self.urlServer = Globals.APP_SERVER
        case .media:
            self.urlServer = Globals.MEDIA_SERVER
        default:
            break
        }
    }
    
    func taskRequest(request: URLRequest, completion: @escaping (Bool, Int16, Any) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false, 1, error.debugDescription)
                return
            }
            
            //debugPrint(String(data: data, encoding: .utf8))
            DispatchQueue.main.async {
                if let responseData = self.responseJSONData(data: data) {
                    completion(true, 1, responseData)
                } else {
                    completion(false, 2, String(data: data, encoding: .utf8) as Any)
                }
            }
        }
        
        task.resume()
    }
    
    func params(data: [String:Any]) -> String {
        var q = ""
        
        if data.count > 0 {
            var params = [String]()
            for d in data {
                let escapedParam = String(describing: d.value).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                params.append("\(d.key)=\(escapedParam!)")
            }
            q = "?\(params.joined(separator: "&"))"
        }
        
        return q
    }
    
    func generateRequest(data: [String:Any], method: String, path: String) -> URLRequest {
        let defaults = UserDefaults.standard
        //let jsonData = try? JSONSerialization.data(withJSONObject: data)
        
        var dataURL = "\(urlServer!)\(path)"
        if !data.isEmpty {
            dataURL = "\(dataURL)\(params(data: data))"
        }
        print(dataURL)
        let url = URL(string: dataURL)!
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        //request.httpBody = jsonData
        
        switch server {
        case .application:
            request.addValue(Globals.APP_KEY, forHTTPHeaderField: "app-key")
            if let laboratoryHash = defaults.string(forKey: Globals.LABORATORY_HASH) {
                request.addValue(laboratoryHash, forHTTPHeaderField: "app-lab")
            }
            //print(defaults.string(forKey: Globals.ACCESS_TOKEN))
            if let accessToken = defaults.string(forKey: Globals.ACCESS_TOKEN) {
                if !accessToken.isEmpty {
                    //print(accessToken)
                    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                }
            }
        case .media:
            request.addValue(Globals.MEDIA_KEY, forHTTPHeaderField: "app-key")
            if let mediaToken = defaults.string(forKey: Globals.MEDIA_TOKEN) {
                if !mediaToken.isEmpty {
                    request.addValue("Bearer \(mediaToken)", forHTTPHeaderField: "Authorization")
                }
            }
        default:
            break
        }
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    func responseJSONData(data: Data) -> Any? {
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        if let responseJSON = responseJSON as? [String: Any] {
            if responseJSON.contains(where: { $0.key == "success" }) {
                if responseJSON["success"] as! Int == 1 {
                    if let list = responseJSON["data"] as? [[String : Any]] {
                        return Utils.arrayToJSON(data: list)
                    } else if let list = responseJSON["data"] as? [String : Any] {
                        return list
                    } else if let n = responseJSON["data"] as? Int {
                        return n
                    } else if let s = responseJSON["data"] as? String {
                        return s
                    } else {
                        return 0
                    }
                }
            }
            
            if responseJSON.contains(where: { $0.key == "token_type" }) {
                return responseJSON
            }
        }
        
        return nil
    }
}
