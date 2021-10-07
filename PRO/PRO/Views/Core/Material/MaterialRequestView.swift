//
//  MaterialRequestView.swift
//  PRO
//
//  Created by VMO on 24/08/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct MaterialRequestView: View {
    
    
    @ObservedObject private var selectMaterialsModalToggle = ModalToggle()
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var selectedMaterials = [String]()
    @State private var deliveries = [AdvertisingMaterialDelivery]()
    
    var body: some View {
        ZStack {
            VStack {
                HeaderToggleView(couldSearch: false, title: "modMaterialDelivery", icon: Image("ic-material"), color: Color.cPanelMaterial)
                ZStack(alignment: .bottomTrailing) {
                    Button(action: {
                        selectMaterialsModalToggle.status.toggle()
                    }) {
                        Text("...Material prueba...")
                    }
                }
                List {
                    ForEach(deliveries, id: \.materialId) { item in
                        CardDelivery(item: item)
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-cloud", foregroundColor: .cPrimaryLight) {
                        self.goTo(page: "MATERIAL-DELIVERY")
                    }
                }
            }
            if selectMaterialsModalToggle.status {
                GeometryReader {geo in
                    CustomDialogPicker(modalToggle: selectMaterialsModalToggle, selected: $selectedMaterials, key: "MATERIAL", multiple: true)
                }
                .background(Color.black.opacity(0.45))
                .onDisappear {
                    selectedMaterials.forEach { id in
                        if let material = MaterialDao(realm: try! Realm()).by(id: id) {
                            let delivery = AdvertisingMaterialDelivery()
                            delivery.materialId = material.id
                            delivery.material =  material
                            deliveries.append(delivery)
                        }
                    }
                }
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        
    }
    
    func goTo(page: String) {
        viewRouter.currentPage = page
    }
}

struct CardDelivery: View {
    var item: AdvertisingMaterialDelivery
    var body: some View{
        VStack{
            HStack {
                Text(item.material?.name ?? "")
                Spacer()
                Button(action: {
                    print("hh")
                }, label: {
                    Image("ic-delete")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                    /*
                    Label("", systemImage: "trash.fill")
                        .foregroundColor(.cIconLight)
                    */
                })
                .background(Color.white)
            }
            VStack{
                HStack {
                    Text("ffff")
                    Spacer()
                    Text("fff")
                }
                HStack {
                    Button(action: {
                        print("hh")
                    }, label: {
                        Text("-")
                    })
                    .background(Color.white)
                    Spacer()
                    Text("ffff")
                    Spacer()
                    Button(action: {
                        print("hh")
                    }, label: {
                        Text("+")
                    })
                    .background(Color.white)
                }
                
            }
        }
    }
}

struct MaterialRequestView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialRequestView()
    }
}
