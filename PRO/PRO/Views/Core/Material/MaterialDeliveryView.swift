//
//  MaterialDeliveryView.swift
//  PRO
//
//  Created by VMO on 24/08/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast

struct MaterialDeliveryView: View {
    @ObservedObject private var moduleRouter = ModuleRouter()
    var body: some View {
        switch moduleRouter.currentPage {
        case "LIST":
            MaterialDeliveryListView(moduleRouter: moduleRouter)
        case "FORM":
            MaterialDeliveryFormView(moduleRouter: moduleRouter)
        default:
            Text("")
        }
    }
}

struct Stock {
    var name: String
    var lot: String
    var quantity: Int
    var date: String
}

struct StockApi: Codable {
    var status_: Int
    var observaciones: String
    var id_ajuste: Int
    var material: MaterialAPI
    var id_material: Int
    var id_usuario_ajusta: Int
    var lote: String
    var id_usuario_destino: Int
    var categoria_mat: String? = nil
    var tipo_ajuste: String
    var aceptado: Int
    var cantidad: Int
    var id_usuario: Int
    var fecha: String
    var id_usuario_recibe: Int
}

struct MaterialAPI: Codable {
    var codigo: String
    var color: String
    var mensaje_promocional: String
    var disponible_pedidos: Int
    var nuevo: Int
    var transferencia: Int
    var muestra_m: String
    var cantidad: Int
    var id_pais: Int
    var aplica_tv: Int
    var status_: Int
    var id_material: Int
    var id_linea: Int
    var imagen: String? = nil
    var categoria: String? = nil
    var nombre: String
    var siempre_disponible: Int? = nil
    var id_producto: Int
    var descripcion: String
    var tipo: Int
    var activo: Int
}

struct MaterialDeliveryListView: View {
    
    @ObservedObject var moduleRouter: ModuleRouter
    
    @State private var deliveries = MaterialDeliveryDao(realm: try! Realm()).all()
    @State private var array: [Stock] = []
    
    var body: some View {
        ZStack {
            VStack{
                HeaderToggleView(couldSearch: false, title: "modMaterialDelivery", icon: Image("ic-material"), color: Color.cPanelMaterial)
                Spacer()
                List {
                    ForEach(array, id: \.date) { item in
                        MaterialDeliveryListCardView(item: item)
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                        moduleRouter.currentPage = "FORM"
                    }
                }
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        for i in deliveries{
            if let material = MaterialDao(realm: try! Realm()).by(id: String(i.materialId)) {
                array.append(Stock(name: material.name ?? "", lot: material.sets[0].id, quantity: i.sets[0].quantity, date: i.date))
            }
        }
        let appServer = AppServer()
        appServer.postRequest(data: [String: Any](), path: "vm/material-delivery/filter") { (bool, int, any) in
            let b = any as? Array<String> ?? []
            for i in b{
                let decoded = try! JSONDecoder().decode(StockApi.self, from: i.data(using: .utf8)!)
                array.append(Stock(name: decoded.material.nombre, lot: decoded.lote, quantity: decoded.cantidad, date: decoded.fecha))
            }
        }
    }
}

struct MaterialDeliveryListCardView: View {
    var item: Stock
    var body: some View {
        VStack(alignment: .leading, spacing: 5){
            VStack{
                HStack{
                    Text(item.name)
                    Spacer()
                }
                Spacer()
                Divider()
                 .frame(height: 1)
                 .padding(.horizontal, 5)
                 .background(Color.gray)
                Spacer()
                HStack{
                    Text(String(item.lot))
                    Spacer()
                    Text(String(format: NSLocalizedString("materialQuantity", comment: ""), String(item.quantity)))
                        .font(.system(size: 18, weight: .heavy, design: .default))
                }
                Spacer()
                Divider()
                 .frame(height: 1)
                 .padding(.horizontal, 5)
                 .background(Color.gray)
                Spacer()
                HStack{
                    Spacer()
                    Text(formatStringDate(date: item.date))
                        .font(.system(size: 14))
                }
            }
            .padding(7)
        }
        .background(Color(red: 100, green: 100, blue: 100))
        .frame(alignment: Alignment.center)
        .clipped()
        .shadow(color: Color.gray, radius: 4, x: 0, y: 0)
    }
    func formatStringDate(date: String) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let newDate = dateFormatter.date(from: date)
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM d, yyyy")
            return dateFormatter.string(from: newDate!)
    }
}

struct MaterialDeliveryFormView: View {
    
    @ObservedObject var moduleRouter: ModuleRouter
    @ObservedObject private var selectMaterialsModalToggle = ModalToggle()
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var selectedMaterials = [String]()
    @State private var deliveries = [AdvertisingMaterialDelivery]()
    
    var realm = try? Realm()
    
    @State private var showToast = false
    
    var body: some View {
        ZStack {
            VStack {
                HeaderToggleView(couldSearch: false, title: "modMaterialDelivery", icon: Image("ic-material"), color: Color.cPanelMaterial)
                ZStack(alignment: .bottomTrailing) {
                    
                }
                Button(action: {
                    selectMaterialsModalToggle.status.toggle()
                }) {
                    HStack(alignment: .center){
                        Text("addMaterialDelivery")
                        Image("ic-plus-circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                    }
                }
                .padding(10)
                .background(Color(red: 100, green: 100, blue: 100))
                .frame(alignment: Alignment.center)
                .cornerRadius(8)
                .clipped()
                .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                .foregroundColor(.cPrimaryLight)
                List {
                    ForEach(deliveries, id: \.materialId) { item in
                        MaterialDeliveryFormCardView(material: item)
                    }
                    .onDelete(perform: self.delete)
                }
                .buttonStyle(PlainButtonStyle())
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                        if deliveries.count > 0 {
                            MaterialDeliveryDao(realm: try! Realm()).store(deliveries: deliveries)
                            moduleRouter.currentPage = "LIST"
                        } else {
                            self.showToast.toggle()
                        }
                    }
                }
                .toast(isPresenting: $showToast){
                    AlertToast(type: .regular, title: NSLocalizedString("noneMaterialDelivery", comment: ""))
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
                            var toogle = false
                            for i in deliveries {
                                if i.materialId == material.id {
                                    toogle = true
                                    break
                                }
                            }
                            if !toogle {
                                print("_________material_________")
                                print(material)
                                print("_________material_________")
                                let delivery = AdvertisingMaterialDelivery()
                                delivery.materialId = material.id
                                delivery.material =  material
                                delivery.date = Utils.currentDate()
                                delivery.comment = ""
                                if material.sets.count == 0 {
                                    let materialSet = AdvertisingMaterialSet()
                                    materialSet.dueDate = ""
                                    materialSet.id = "0"
                                    materialSet.stock = 1001001
                                    let deliverySet = AdvertisingMaterialDeliverySet()
                                    deliverySet.objectId = materialSet.objectId
                                    deliverySet.id = materialSet.id
                                    deliverySet.quantity = 0
                                    deliverySet.set = materialSet
                                    print("_________material EDIT_________")
                                    print(material)
                                    print("_________material EDIT_________")
                                    delivery.sets.append(deliverySet)
                                } else {
                                    material.sets.forEach { set in
                                        let deliverySet = AdvertisingMaterialDeliverySet()
                                        deliverySet.objectId = set.objectId
                                        deliverySet.id = set.id
                                        deliverySet.quantity = 0
                                        deliverySet.set = set
                                        delivery.sets.append(deliverySet)
                                    }
                                }
                                deliveries.append(delivery)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        self.deliveries.remove(atOffsets: offsets)
    }
}


struct MaterialDeliveryFormCardView: View {
    @State var observation: String = ""
    var material: AdvertisingMaterialDelivery
    
    var body: some View {
        let bindingComment = Binding<String>(get: {
            self.material.comment
        }, set: {
            self.material.comment = $0
        })
        VStack(alignment: .leading, spacing: 5){
            VStack{
                HStack {
                    Text(material.material?.name ?? "")
                    Spacer()
                }
                Spacer()
                Divider()
                 .frame(height: 1)
                 .padding(.horizontal, 5)
                 .background(Color.gray)
                VStack {
                    ForEach(material.sets, id: \.id) { set in
                        MaterialDeliverySetFormCardView(set: set)
                    }
                }
                TextField(NSLocalizedString("materialObservations", comment: ""), text: bindingComment)
                Divider()
                 .frame(height: 1)
                 .padding(.horizontal, 5)
                 .background(Color.gray)
            }
            .padding(7)
        }
        .background(Color(red: 100.0, green: 100.0, blue: 100.0))
        .frame(alignment: Alignment.center)
        .clipped()
        .shadow(color: Color.gray, radius: 4, x: 0, y: 0)
    }
    
}

struct MaterialDeliverySetFormCardView: View {
    @State var set: AdvertisingMaterialDeliverySet
    @State var tvNumber: Int = 0
    
    var body: some View {
        
        VStack {
            HStack {
                Text(String(set.id))
                Spacer()
                Text(String(format: NSLocalizedString("expDate", comment: ""), Utils.dateFormat(date: Utils.strToDate(value: set.set.dueDate ?? ""), format: "MMMM d, yyyy")))
                Text(set.set.dueDate ?? "")
            }
            Spacer()
            HStack {
                Button(action: {
                    if set.quantity > 0 {
                        tvNumber -= 1
                        set.quantity = tvNumber
                    }
                }, label: {
                    Text("-")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                })
                .background(Color.white)
                Spacer()
                VStack {
                    Text("\(String(tvNumber))")
                    Text(String(format: NSLocalizedString("materialRemainder", comment: ""),
                                String((set.set.stock) - (set.set.delivered))))
                }
                Spacer()
                Button(action: {
                    if set.quantity < set.set.stock {
                        tvNumber += 1
                        set.quantity = tvNumber
                    }
                }, label: {
                    Text("+")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                })
                .background(Color.white)
            }
        }
    }
}

struct MaterialDeliveryView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialDeliveryView()
    }
}
