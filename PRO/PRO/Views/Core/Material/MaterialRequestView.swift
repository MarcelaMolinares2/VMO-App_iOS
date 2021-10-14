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
                    .onDelete(perform: self.delete)
                }
                .buttonStyle(PlainButtonStyle())
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
    
    private func delete(at offsets: IndexSet) {
        self.deliveries.remove(atOffsets: offsets)
    }
}

struct CardDelivery: View {
    @State var observacion: String = ""
    @State var tvNumber: Int = 0
    var item: AdvertisingMaterialDelivery
    var body: some View {
        VStack{
            HStack {
                Text(item.material?.name ?? "")
                Spacer()
                Button(action: {
                    
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
            VStack{
                HStack {
                    Text(String(item.material?.sets[0].id ?? ""))
                    Spacer()
                    Text(String(item.material?.sets[0].dueDate ?? ""))
                }
                Spacer()
                HStack {
                    Button(action: {
                        tvNumber = tvNumber - 1
                        if tvNumber <= 0 {tvNumber = 0}
                    }, label: {
                        Text("-")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    })
                    .background(Color.white)
                    Spacer()
                    VStack {
                        Text("\(String(tvNumber))")
                        Text(String((item.material?.sets[0].stock ?? 0) - (item.material?.sets[0].delivered ?? 0)))
                    }
                    Spacer()
                    Button(action: {
                        tvNumber = tvNumber + 1
                    }, label: {
                        Text("+")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    })
                    .background(Color.white)
                }
                TextField("Observaciones...", text: $observacion)
            }
        }
    }
}

struct MaterialRequestView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialRequestView()
    }
}
