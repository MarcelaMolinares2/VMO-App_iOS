//
//  MaterialDeliveryView.swift
//  PRO
//
//  Created by VMO on 24/08/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct MaterialDeliveryView: View {
    
    @State private var materials: [AdvertisingMaterial] = [AdvertisingMaterial]()
    
    @State private var selectedMaterials = [String]()
    @ObservedObject private var selectMaterialsModalToggle = ModalToggle()
    
    var body: some View {
        ZStack {
            VStack {
                HeaderToggleView(couldSearch: false, title: "modMaterialDelivery", icon: Image("ic-material"), color: Color.cPanelMaterial)
                ZStack(alignment: .bottomTrailing) {
                    Form {
                        Button(action: {
                            print("TOGGLE!!!")
                            selectMaterialsModalToggle.status.toggle()
                        }) {
                            Text("...Materials...")
                        }
                    }
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
    }
}

struct MaterialDeliveryView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialDeliveryView()
    }
}
