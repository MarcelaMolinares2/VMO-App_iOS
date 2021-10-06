//
//  MaterialDeliveryView.swift
//  PRO
//
//  Created by VMO on 24/08/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct Restaurant: Identifiable {
    let id = UUID()
    let name: String
}

struct materialsRealM: Identifiable {
    let id = UUID()
    let name: String
}

struct MaterialDeliveryView: View {
    
    //@State private var materials: [AdvertisingMaterial] = [AdvertisingMaterial]()
    @State private var materials = [AdvertisingMaterial]()
    var mat = [materialsRealM]()
    
    @State private var selectedMaterials = [String]()
    @ObservedObject private var selectMaterialsModalToggle = ModalToggle()
    @State private var isLightOn = false
    
    let restaurants = [
        Restaurant(name: "Joe's Original"),
        Restaurant(name: "The Real Joe's Original"),
        Restaurant(name: "Original Joe's")
    ]
    
    var body: some View {
        ZStack {
            VStack {
                HeaderToggleView(couldSearch: false, title: "modMaterialDelivery", icon: Image("ic-material"), color: Color.cPanelMaterial)
                ZStack(alignment: .bottomTrailing) {
                    //Form {
                    Button(action: {
                        print("TOGGLE!!!")
                        selectMaterialsModalToggle.status.toggle()
                        print(selectedMaterials)
                    }) {
                        Text("...Material prueba...")
                    }
                    /*
                    List(restaurants) { i in
                        Text(i.name)
                    }
                    */
                    List {
                        ForEach(mat) { section in
                            Text(section.name)

                        }
                    }
                    //}
                }
                
            }
            if selectMaterialsModalToggle.status {
                GeometryReader {geo in
                    CustomDialogPicker(modalToggle: selectMaterialsModalToggle, selected: $selectedMaterials, key: "MATERIAL", multiple: true)
                }
                .background(Color.black.opacity(0.45))
            }
            
            
            
        }
        .onAppear {
            load()
        }
        
    }
    
    func load() {

        materials = MaterialDao(realm: try! Realm()).all()
        print("__________materials__________")
        print(type(of: materials))
        print(materials.description)
        print("__________materials.index__________")
        for i in materials {
            print(i)
            print(i.name!)
            //mat.append(i.name!)
            mat.append(materialsRealM(name: i.name!))
        }
        print("__________mat__________")
        print(mat)
        print("__________restaurants__________")
        print(type(of: restaurants))
        print(restaurants)
            
        
    }
    
    func haga(){
        print("fgfdg")
    }
}

struct MaterialDeliveryView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialDeliveryView()
    }
}
