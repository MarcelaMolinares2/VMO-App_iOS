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
        case .master:
            self.urlServer = Globals.APP_SERVER
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
            q = params.joined(separator: "&")
        }
        
        return q
    }
    
    /*
     func queryItems(data: [String:Any]) -> [URLQueryItem] {
     var items = [URLQueryItem]()
     data.forEach { (key: String, value: Any) in
     items.append(URLQueryItem(name: key, value: Utils.castString(value: value)))
     }
     print(items)
     return items
     }
     let dataURL = URL(string: "\(urlServer!)\(path)")!
     let url = dataURL.appending(queryItems(data: data))!
     */
    
    func generateRequest(data: [String:Any], method: String, path: String) -> URLRequest {
        let defaults = UserDefaults.standard
        
        var request: URLRequest
        if method == "GET" {
            var dataURL = "\(urlServer!)\(path)"
            if !data.isEmpty {
                dataURL = "\(dataURL)?\(params(data: data))"
            }
            let url = URL(string: dataURL)!
            request = URLRequest(url: url)
            
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        } else {
            let dataEncoded : Data = params(data: data).data(using: .utf8)!
            request = URLRequest(url: URL(string: "\(urlServer!)\(path)")!)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpBody = dataEncoded
        }
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.httpMethod = method
        
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
            case .master:
                request.addValue(Globals.APP_KEY, forHTTPHeaderField: "app-key")
                if let laboratoryHash = defaults.string(forKey: Globals.LABORATORY_HASH) {
                    request.addValue(laboratoryHash, forHTTPHeaderField: "app-lab")
                }
                if let masterHash = defaults.string(forKey: Globals.MASTER_HASH) {
                    request.addValue(masterHash, forHTTPHeaderField: "master-hash")
                }
            default:
                break
        }
        
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
