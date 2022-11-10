//
//  MovementSummaryView.swift
//  PRO
//
//  Created by VMO on 9/11/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import GoogleMaps
import RealmSwift

struct MovementSummaryView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Binding var movementReport: MovementReport
    @Binding var modalSummary: Bool

    @State private var movement: Movement = Movement()
    @State private var route = 0
    @State private var isProcessing = false
    
    let realm = try! Realm()
    
    var body: some View {
        VStack {
            if isProcessing {
                Spacer()
                LottieView(name: "sync_animation", loopMode: .loop, speed: 1)
                    .frame(width: 300, height: 200)
                Spacer()
            } else {
                ZStack(alignment: .bottom) {
                    TabView(selection: $route) {
                        MovementSummaryBasicView(realm: realm, movement: $movement)
                            .tag(0)
                            .tabItem {
                                Text("envBasic")
                                Image("ic-basic")
                            }
                    }
                    .tabViewStyle(DefaultTabViewStyle())
                    HStack(alignment: .bottom) {
                        Spacer()
                        if MovementUtils.isCycleActive(realm: realm, id: movement.cycleId) && movementReport.reportedBy == JWTUtils.sub() && movement.executed == 1 {
                            FAB(image: "ic-edit") {
                                FormEntity(objectId: nil, type: "", options: [ "oId": movement.objectId.stringValue, "id": String(movement.id) ]).go(path: "MOVEMENT-FORM", router: viewRouter)
                            }
                        }
                    }
                    .padding(.bottom, Globals.UI_FAB_VERTICAL + 50)
                    .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
                }
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        isProcessing = true
        if let m = MovementDao(realm: realm).by(objectId: movementReport.objectId.stringValue) {
            movement = Movement(value: m)
        } else {
            getMovement(id: String(movementReport.serverId))
        }
    }
    
    func getMovement(id: String) {
        AppServer().postRequest(data: [:], path: "vm/movement/mobile/detail/\(id)") { success, code, data in
            if success {
                if let rs = data as? Dictionary<String, Any> {
                    let item = Utils.dictionaryToJSON(data: rs)
                    if let decoded = try? JSONDecoder().decode(Movement.self, from: item.data(using: .utf8)!) {
                        movement = decoded
                    }
                }
            }
            DispatchQueue.main.async {
                isProcessing = false
            }
        }
    }
}

struct MovementSummaryBasicView: View {
    let realm: Realm
    @Binding var movement: Movement
    
    @State private var dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_MOV_FORM_ADDITIONAL").complement ?? "")
    @State private var dynamicForm = DynamicForm(tabs: [DynamicFormTab]())
    @State private var dynamicOptions = DynamicFormFieldOptions(table: "movement", op: .view)
    
    var body: some View {
        VStack {
            MovementSummaryMapView(item: movement.report(realm: realm))
                .frame(maxHeight: 200)
            ScrollView {
                CustomForm {
                    CustomSection {
                        VStack{
                            Text(movement.comment ?? "--")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    ForEach($dynamicForm.tabs) { $tab in
                        DynamicFormSummaryView(form: $dynamicForm, tab: $tab, options: dynamicOptions)
                    }
                    ScrollViewFABBottom()
                }
            }
        }
        .onAppear{
            load()
        }
    }
    
    func load() {
        dynamicOptions.objectId = movement.objectId
        dynamicOptions.item = movement.id
        
        dynamicForm.tabs = DynamicUtils.initForm(data: dynamicData).sorted(by: { $0.key > $1.key })
        
        if let fields = movement.additionalFields {
            if !fields.isEmpty {
                DynamicUtils.fillForm(form: &dynamicForm, base: fields)
            }
        }
    }
}

struct MovementSummaryMapView: View {
    
    var item: MovementReport
    
    @State private var markers = [GMSMarker]()
    @State private var goToMyLocation = false
    @State private var fitToBounds = false
    
    var body: some View {
        CustomMarkerMapView(markers: $markers, goToMyLocation: $goToMyLocation, fitToBounds: $fitToBounds) { marker in }
            .onAppear {
                markers.removeAll()
                if item.latitude > 0 && item.longitude > 0 {
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(item.latitude), longitude: Double(item.longitude)))
                    markers.append(marker)
                }
                fitToBounds = true
            }
    }
    
}
