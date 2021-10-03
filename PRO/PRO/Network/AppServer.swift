//
//  AppServer.swift
//  Sin Appuros
//
//  Created by VMO on 4/09/20.
//  Copyright © 2020 VMO. All rights reserved.
//

class AppServer: NetworkService {
    
    override init() {
        super.init(server: .application)
    }
    
    public func postRequest(data: [String:Any], path: String, completion: @escaping (Bool, Int16, Any)->()) {
        let request = generateRequest(data: data, method: "POST", path: path)
        taskRequest(request: request, completion: completion)
    }
    
    public func getRequest(path: String, completion: @escaping (Bool, Int16, Any)->()) {
        let request = generateRequest(data: [String: Any](), method: "GET", path: path)
        taskRequest(request: request, completion: completion)
    }
    
    public func putRequest(data: [String:Any], path: String, completion: @escaping (Bool, Int16, Any)->()) {
        let request = generateRequest(data: data, method: "PUT", path: path)
        taskRequest(request: request, completion: completion)
    }
    
    public func deleteRequest(data: [String:Any], path: String, completion: @escaping (Bool, Int16, Any)->()) {
        let request = generateRequest(data: data, method: "DELETE", path: path)
        taskRequest(request: request, completion: completion)
    }
}
