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
                            print("_______deliveries append__________")
                            for i in material.sets {
                                print(i.id)
                                print(i.objectId)
                                print(i.dueDate ?? "")
                                print(i.stock)
                                print(i.delivered)
                            }
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
    @State var observacion: String = ""
    var item: AdvertisingMaterialDelivery
    var item_Material: AdvertisingMaterialSet
    var array_Material = [AdvertisingMaterialSet]()
    var body: some View{
        VStack{
            HStack {
                Text(item.material?.name ?? "")
                Spacer()
                Button(action: {
                    print("trash")
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
            Spacer()
            List {
                /*
                ForEach(array_Material) { i in
                    Text(i)
                }
                */
                /*
                VStack{
                    HStack {
                        Text(String(item.material?.id ?? 0))
                        Spacer()
                        Text("fecha")
                    }
                    Spacer()
                    HStack {
                        Button(action: {
                            print("menos")
                        }, label: {
                            Text("-")
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        })
                        .background(Color.white)
                        Spacer()
                        VStack {
                            Text("0")
                            Text("Saldo: 037")
                        }
                        Spacer()
                        Button(action: {
                            print("mas")
                        }, label: {
                            Text("+")
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        })
                        .background(Color.white)
                    }
                    TextField("Observaciones...", text: $observacion)
                }
                */
            }
        }
    }
}

struct MaterialRequestView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialRequestView()
    }
}
