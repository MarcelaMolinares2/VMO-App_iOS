//
//  MasterServer.swift
//  PRO
//
//  Created by VMO on 9/06/22.
//  Copyright © 2022 VMO. All rights reserved.
//

class MasterServer: NetworkService {
    
    override init() {
        super.init(server: .master)
    }
    
    public func postRequest(data: [String:Any], path: String, completion: @escaping (Bool, Int16, Any)->()) {
        let request = generateRequest(data: data, method: "POST", path: path)
        taskRequest(request: request, completion: completion)
    }
    
    public func getRequest(path: String, completion: @escaping (Bool, Int16, Any)->()) {
        let request = generateRequest(data: [String: Any](), method: "GET", path: path)
        taskRequest(request: request, completion: completion)
    }
}
