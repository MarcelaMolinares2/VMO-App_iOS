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
                        Text("modMaterialDelivery")
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
    //let x_1 = "materialRemainder1"
    //let x_2 = "materialRemainder2"
    let materialRemainder = NSLocalizedString("materialRemainder", comment: "")
    let expDate = NSLocalizedString("expDate", comment: "")
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
                    //Text("materialRemainder1" + String(item.material?.sets[0].dueDate ?? "") + "materialRemainder2")
                    
                    Text(String(item.material?.sets[0].dueDate ?? ""))
                    //Text(String(format: expDate, String(item.material?.sets[0].dueDate ?? "")))
                    //let x = String(item.material?.sets[0].dueDate ?? "").split(separator: -)
                    //Text(String(format: expDate, Double(String(item.material?.sets[0].dueDate ?? "").split(separator: "-")[2])))
                    //String(item.material?.sets[0].dueDate ?? "").split(separator: "-")[2]
                    //Text(String(format: expDate, formatter.number(from: "9,999.99")))
                    //Text(String(item.material?.sets[0].dueDate ?? ""))
                    //Text(String(format: materialRemainder, 20))
                    //Text("\(x_1) \(String(item.material?.sets[0].dueDate ?? "")) \(x_2)")
                }
                Spacer()
                HStack {
                    Button(action: {
                        tvNumber = tvNumber - 1
                        if tvNumber <= 0 {tvNumber = 0}
                    }, label: {
                        //let a = "Hello"
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
