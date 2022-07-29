//
//  MovementsView.swift
//  PRO
//
//  Created by Fernando Garcia on 27/01/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct MovementsAPI: Codable {
    var id_concepto: Int
    var concepto: String?
    var cuenta: Int?
    var departamento:String?
    var reembolsable:Int?
}

struct MovementsView: View {
    
    @State private var arrayCycles: [Cycle] = []
    @State private var cycle = ""
    
    @State private var array: [Movement] = []
    
    var body: some View {
        VStack{
            HeaderToggleView(title: "") {
                
            }
            HStack{
                Text(cycle)
                    .foregroundColor(.cTextHigh)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                Spacer()
                Image("ic-day-request")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 35)
                    .foregroundColor(.cTextHigh)
                    .padding(10)
            }
            Spacer()
        }
        .onAppear{
            load()
        }
    }
    
    func load(){
        arrayCycles = CycleDao(realm: try! Realm()).all()
        cycle = arrayCycles[arrayCycles.count - 1].displayName
        
        let userS = UserSettings()
        
        print(userS.userData()!)
        
        
        AppServer().postRequest(data: [
            "id_usuario": Int(userS.userData()!.id)
        ], path: "vm/movement/filter") { (successful, code, data) in
            if successful {
                let requestData = data as? Array<String> ?? []
                requestData.forEach{ value in
                    let decoded = try! JSONDecoder().decode(Movement.self, from: value.data(using: .utf8)!)
                    array.append(decoded)
                }
                print(array)
            } else {
                print(data)
                print("Error")
            }
        }
        
        
        /*
         AppServer().postRequest(data: [
             "username": username,
             "password": password,
             "type": "M",
             "fcmToken": token,
             "platform": "iOS"
         ], path: "auth/login") { (successful, code, data) in
             if successful {
                 self.isProcesing = false
                 userSettings.successfullAuth(data: data as! [String : Any])
             } else {
                 print(data)
                 let response = Utils.jsonDictionary(string: data as! String)
                 switch Utils.castInt(value: response["data"]) {
                 case 1:
                     self.handleError(message: "errLogin")
                 default:
                     self.handleError(message: "errServerConection")
                 }
             }
         }
         
        */
        
        /*
         
         AppServer().postRequest(data: [String: Any](), path: "auth/laboratory/\(domain)") { (successful, code, data) in
             if successful {
                 UserDefaults.standard.setValue(Utils.castString(value: (data as! [String: Any])["hash"]), forKey: Globals.LABORATORY_HASH)
                 UserDefaults.standard.setValue(domain, forKey: Globals.LABORATORY_PATH)
                 self.auth(userSettings: userSettings, username: username, password: password)
             } else {
                 self.handleError(message: "errLaboratoryNotFound")
             }
         }
         */
    }
}

struct MovementsView_Previews: PreviewProvider {
    static var previews: some View {
        MovementsView()
    }
}
