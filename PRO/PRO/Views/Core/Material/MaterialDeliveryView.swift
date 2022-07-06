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

struct setStock: Hashable {
    var lot: String
    var quantity: Int
}
struct Stock {
    let id = UUID()
    var name: String
    var set: [setStock]
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
    
    @State private var deliveries: [AdvertisingMaterialDeliveryReport] = []
    
    var body: some View {
        ZStack {
            VStack{
                HeaderToggleView(couldSearch: false, title: "modMaterialDelivery", icon: Image("ic-material"), color: Color.cPanelMaterial)
                Spacer()
                List {
                    ForEach(deliveries, id: \.id) { item in
                        MaterialDeliveryListItemView(item: item)
                    }
                }
                .refreshable {
                    getDeliveries()
                }
            }
            .foregroundColor(.cPrimaryLight)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-plus") {
                        moduleRouter.currentPage = "FORM"
                    }
                }
            }
        }
        .onAppear {
            getDeliveries()
        }
    }
    
    func getDeliveries() {
        let realm = try! Realm()
        let local = MaterialDeliveryDao(realm: realm).all()
        for i in local {
            i.materials.forEach { m in
                let material = MaterialDao(realm: realm).by(id: m.materialId)
                m.sets.forEach { s in
                    let item = AdvertisingMaterialDeliveryReport()
                    item.quantity = s.quantity
                    item.comment = i.comment
                    item.date = i.date
                    item.material = material
                    item.madeBy = UserDao(realm: realm).logged()
                    
                    deliveries.append(item)
                }
            }
        }
        AppServer().postRequest(data: [String: Any](), path: "vm/advertising-material/report/deliveries") { (bool, int, any) in
            let requestAny = any as? Array<String> ?? []
            requestAny.forEach{ value in
                let decoded = try! JSONDecoder().decode(AdvertisingMaterialDeliveryReport.self, from: value.data(using: .utf8)!)
                deliveries.append(decoded)
            }
        }
    }
}

struct MaterialDeliveryListItemView: View {
    
    var item: AdvertisingMaterialDeliveryReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5){
            VStack{
                HStack{
                    Text(item.material?.name ?? "")
                    Spacer()
                }
                Spacer()
                Divider()
                    .frame(height: 0.7)
                    .padding(.horizontal, 5)
                    .background(Color.gray)
                Spacer()
                    .frame(height: 15)
                VStack {
                    HStack{
                        Text(item.set?.label ?? "--")
                        Spacer()
                        Text(String(format: NSLocalizedString("materialQuantity", comment: ""), String(item.quantity)))
                            .font(.system(size: 18, weight: .heavy, design: .default))
                    }
                    Spacer()
                        .frame(height: 15)
                }
                Divider()
                    .frame(height: 0.7)
                 .padding(.horizontal, 5)
                 .background(Color.gray)
                Spacer()
                HStack{
                    Spacer()
                    Text(Utils.dateFormat(date: Utils.strToDate(value: item.date), format: "dd, MMM yy"))
                        .font(.system(size: 14))
                }
                
            }
            .padding(7)
        }
        .background(Color.white)
        .frame(alignment: Alignment.center)
        .clipped()
        .shadow(color: Color.gray, radius: 4, x: 0, y: 0)
    }
}

struct MaterialDeliveryFormView: View {
    @ObservedObject var moduleRouter: ModuleRouter
    @ObservedObject private var selectMaterialsModalToggle = ModalToggle()
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var selectedMaterials = [String]()
    @State private var delivery = AdvertisingMaterialDelivery()
    
    var realm = try? Realm()
    
    @State private var showToast = false
    
    var body: some View {
        ZStack {
            VStack {
                HeaderToggleView(couldSearch: false, title: "modMaterialDelivery", icon: Image("ic-material"), color: Color.cPanelMaterial)
                Button(action: {
                    selectMaterialsModalToggle.status.toggle()
                }) {
                    HStack(alignment: .center){
                        Text("addMaterialDelivery")
                        Image("ic-plus-circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                    }
                }
                .padding(10)
                .background(Color(red: 100, green: 100, blue: 100))
                .frame(alignment: Alignment.center)
                .cornerRadius(8)
                .clipped()
                .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                List {
                    ForEach(delivery.materials.indices, id: \.self) { i in
                        MaterialDeliveryFormCardView(deliveryMaterial: $delivery.materials[i])
                    }
                    .onDelete(perform: self.delete)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .foregroundColor(.cPrimaryLight)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-cloud") {
                        if delivery.materials.count > 0 {
                            //MaterialDeliveryDao(realm: try! Realm()).store(deliveries: deliveries)
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
                    CustomDialogPicker(onSelectionDone: onSelectionDone, selected: $selectedMaterials, key: "MATERIAL", multiple: true)
                }
                .background(Color.black.opacity(0.45))
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        withAnimation{
            self.delivery.materials.remove(atOffsets: offsets)
        }
    }
    
    func onSelectionDone(_ selected: [String]) {
        selectMaterialsModalToggle.status.toggle()
        /*selectedMaterials.forEach { id in
            if let material = MaterialDao(realm: try! Realm()).by(id: id) {
                var exists = false
                for i in deliveries {
                    if i.materialId == material.id {
                        exists = true
                        break
                    }
                }
                if !exists {
                    let delivery = AdvertisingMaterialDelivery()
                    delivery.materialId = material.id
                    delivery.material =  material
                    delivery.date = Utils.currentDate()
                    delivery.comment = ""
                    material.sets.forEach { set in
                        let deliverySet = AdvertisingMaterialDeliverySet()
                        deliverySet.id = set.id
                        deliverySet.set = set
                        delivery.sets.append(deliverySet)
                    }
                    if material.sets.isEmpty {
                        let deliverySet = AdvertisingMaterialDeliverySet()
                        deliverySet.set = AdvertisingMaterialSet()
                        deliverySet.id = "0"
                        delivery.sets.append(deliverySet)
                    }
                    deliveries.append(delivery)
                }
            }
        }*/
    }
}



struct MaterialDeliveryFormCardView: View {
    @State var observation: String = ""
    @Binding var deliveryMaterial: AdvertisingMaterialDeliveryMaterial
    
    var body: some View {
        let material = MaterialDao(realm: try! Realm()).by(id: deliveryMaterial.materialId)
        VStack(alignment: .leading, spacing: 5){
            VStack{
                HStack {
                    Text(material?.name ?? "")
                    Spacer()
                }
                Divider()
                .frame(height: 0.7)
                .padding(.horizontal, 5)
                .background(Color.gray)
                Spacer()
                VStack {
                    ForEach(deliveryMaterial.sets.indices, id: \.self) { i in
                        MaterialDeliverySetFormCardView(deliverySet: $deliveryMaterial.sets[i])
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                        Divider()
                        .frame(height: 0.5)
                        .padding(.horizontal, 5)
                        .background(Color.gray)
                    }
                }
                Divider()
                 .frame(height: 1)
                 .padding(.horizontal, 5)
                 .background(Color.gray)
            }
            .padding(7)
        }
        .background(Color.white)
        .frame(alignment: Alignment.center)
        .clipped()
        .shadow(color: Color.gray, radius: 4, x: 0, y: 0)
    }
    
}

struct MaterialDeliverySetFormCardView: View {
    @Binding var deliverySet: AdvertisingMaterialDeliveryMaterialSet
    @State var tvNumber: Int = 0
    
    var body: some View {
        let set = AdvertisingMaterialSet()
        VStack {
            HStack {
                Text(String(set.label))
                Spacer()
                Text(String(format: NSLocalizedString("expDate", comment: ""), Utils.dateFormat(date: Utils.strToDate(value: set.dueDate ?? ""), format: "dd, MMM yy")))
            }
            Spacer()
                .frame(height: 15)
            HStack {
                Button(action: {
                    if deliverySet.quantity > 0 {
                        tvNumber -= 1
                        deliverySet.quantity = tvNumber
                    }
                }, label: {
                    Image("ic-minus-circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32)
                })
                .background(Color.white)
                Spacer()
                VStack {
                    Text("\(String(tvNumber))")
                        .frame(height: 15)
                    if (set.stock) - (set.delivered) > 0 {
                        Spacer()
                        Text(String(format: NSLocalizedString("materialRemainder", comment: ""),
                                    String((set.stock) - (set.delivered))))
                            .foregroundColor(.cBlueDark)
                    } else {
                        Spacer()
                    }
                }
                Spacer()
                Button(action: {
                    if deliverySet.quantity < (set.stock - set.delivered) {
                        tvNumber += 1
                        deliverySet.quantity = tvNumber
                    }
                    
                }, label: {
                    Image("ic-plus-circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32)
                })
                .background(Color.white)
            }
        }
    }
}
