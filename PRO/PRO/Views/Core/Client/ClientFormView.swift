//
//  ClientFormView.swift
//  PRO
//
//  Created by VMO on 4/12/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast

struct ClientFormView: View {
    
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    
    @State var client: Client?
    @State var plainData = ""
    @State var additionalData = ""
    @State var dynamicData = Dictionary<String, Any>()
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "client", op: "")
    @State private var showValidationError = false
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    func initForm() {
        if viewRouter.data.objectId.isEmpty {
            client = Client()
        } else {
            client = Client(value: try! PharmacyDao(realm: try! Realm()).by(objectId: ObjectId(string: viewRouter.data.objectId)) ?? Client())
            plainData = try! Utils.objToJSON(client)
            additionalData = client?.additionalFields ?? "{}"
        }
        options.objectId = client?.objectId
        options.item = client?.id ?? 0
        options.op = viewRouter.data.objectId.isEmpty ? "create" : "update"
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_CLI_DYNAMIC_FORM").complement ?? "")
        
        initDynamic(data: dynamicData)
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        form.tabs = DynamicUtils.initForm(data: data).sorted(by: { $0.key > $1.key })
        if !plainData.isEmpty {
            DynamicUtils.fillForm(form: &form, base: plainData, additional: additionalData)
        }
    }
    
    func save() {
        if DynamicUtils.validate(form: form) && client != nil {
            DynamicUtils.cloneObject(main: client, temporal: try! JSONDecoder().decode(Pharmacy.self, from: DynamicUtils.toJSON(form: form).data(using: .utf8)!), skipped: ["objectId", "id", "type"])
            client?.additionalFields = DynamicUtils.generateAdditional(form: form)
            ClientDao(realm: try! Realm()).store(doctor: client!)
            viewRouter.currentPage = "MASTER"
        } else {
            showValidationError = true
        }
    }
    
    
    func onTabSelected(_ tab: String) {
        tabRouter.current = tab
    }
}
