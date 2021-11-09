//
//  MedicFormView.swift
//  PRO
//
//  Created by VMO on 10/01/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct MedicFormView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    
    var medic: Doctor?
    var plainData = "{}"
    var dynamicData = Dictionary<String, Any>()
    @State var form = DynamicForm(tabs: [DynamicFormTab]())
    
    init(viewRouter: ViewRouter) {
        if viewRouter.data.id > 0 {
            medic = try! Realm().object(ofType: Doctor.self, forPrimaryKey: viewRouter.data.id)
            plainData = try! Utils.objToJSON(medic)
            print(plainData)
        } else {
            medic = Doctor()
            //medic?.id = UUID()
        }
        dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_DOC_DYNAMIC_FORM").complement ?? "")
    }
    
    var body: some View {
        VStack {
            HeaderToggleView(couldSearch: false, title: medic?.name ?? "modMedic", icon: Image("ic-medic"), color: Color.cPanelMedic)
            switch tabRouter.current {
            case "LOCATIONS":
                PanelLocationView(panel: medic, couldAdd: true)
            default:
                ZStack(alignment: .bottomTrailing) {
                    ForEach(form.tabs, id: \.id) { tab in
                        if tab.key == tabRouter.current {
                            if let ix = form.tabs.firstIndex(where: { $0.key == tabRouter.current }) {
                                DynamicFormView(form: $form, tab: $form.tabs[ix])
                            }
                        }
                    }
                    FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                        print(1)
                    }
                }
            }
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(form.tabs, id: \.id) { tab in
                        Text(tab.key)
                        Image("ic-home")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / CGFloat(form.tabs.count + 1), alignment: .center)
                            .foregroundColor(tabRouter.current == tab.key ? .cPrimary : .cAccent)
                            .onTapGesture {
                                tabRouter.current = tab.key
                            }
                    }
                    Image("ic-map")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(form.tabs.count + 1), alignment: .center)
                        .foregroundColor(tabRouter.current == "LOCATIONS" ? .cPrimary : .cAccent)
                        .onTapGesture {
                            tabRouter.current = "LOCATIONS"
                        }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 46, maxHeight: 46)
        }
        .onAppear {
            tabRouter.current = "BASIC"
            initDynamic(data: dynamicData)
        }
    }
    
    func initDynamic(data: Dictionary<String, Any>) {
        data.forEach { (key: String, value: Any) in
            let tab = value as! Dictionary<String, Any>
            var groups = [DynamicFormGroup]()
            let groupsData = tab["groups"] as! [Dictionary<String, Any>]
            groupsData.forEach { group in
                var fields = [DynamicFormField]()
                let fieldsData = group["fields"] as! [Dictionary<String, Any>]
                
                fieldsData.forEach { field in
                    //print(field)
                    fields.append(try! DynamicFormField(from: field))
                }
                groups.append(DynamicFormGroup(title: Utils.castString(value: group["title"]), fields: fields))
            }
            form.tabs.append(DynamicFormTab(key: key, title: Utils.castString(value: tab["title"]), groups: groups))
        }
        print(form.tabs[0])
    }
    
    func load() {
        //medic?.firstName = ""
    }
}

extension Decodable {
  init(from: Any) throws {
    let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
    let decoder = JSONDecoder()
    self = try decoder.decode(Self.self, from: data)
  }
}
