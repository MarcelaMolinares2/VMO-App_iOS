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
    
    //@EnvironmentObject var moduleRouter: ModuleRouter
    //private var moduleRouter = ModuleRouter()
    @ObservedObject private var moduleRouter = ModuleRouter()
    
    //@EnvironmentObject var moduleRouter = ModuleRouter()

    var body: some View {
        
        
        if moduleRouter.status {
            MaterialDeliveryFormView()
        } else {
            MaterialDeliveryListView()
        }
        /*
        switch moduleRouter.currentPage {
        case "LIST":
            MaterialDeliveryListView()
        case "FORM":
            MaterialDeliveryFormView()
        default:
            Text("")
        }
         */
        /*
        VStack {
            
            
            /*
            
            switch moduleRouter.currentPage {
            
            case "LIST":
                MaterialDeliveryListView()
            default:
                Text("")
            }
            */
        }.onAppear {
            loadData()
        }
        */
    }
    func loadData() {
        //moduleRouter.currentPage = "LIST";
    }
}

struct MaterialDeliveryListView: View {
    
    //@ObservedObject var moduleRouter = ModuleRouter()
    @ObservedObject var moduleRouter: ModuleRouter = ModuleRouter()
    
    @State private var selectedMaterials = [String]()
    @State private var deliveries = MaterialDeliveryDao(realm: try! Realm()).all()
    
    var body: some View {
        ZStack {
            VStack{
                HeaderToggleView(couldSearch: false, title: "modMaterialDelivery", icon: Image("ic-material"), color: Color.cPanelMaterial)
                Spacer()
                List {
                    ForEach(deliveries, id: \.self) { item in
                        if let material = MaterialDao(realm: try! Realm()).by(id: String(item.materialId)) {
                            VStack{
                                HStack{
                                    Text(material.name ?? "")
                                    Spacer()
                                }
                                Spacer()
                                HStack{
                                    Text(String(material.sets[0].id))
                                    Spacer()
                                    Text(String(format: NSLocalizedString("materialQuantity", comment: ""), String(item.sets[0].quantity)))
                                        .font(.system(size: 18, weight: .heavy, design: .default))
                                }
                                Spacer()
                                HStack{
                                    Spacer()
                                    Text(formatStringDate(date: String(item.date)))
                                        .font(.system(size: 14))
                                }
                                
                                Divider()
                                 .frame(height: 1)
                                 .padding(.horizontal, 5)
                                 .background(Color.gray)
                            }
                        }
                        
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-plus", foregroundColor: .cPrimaryLight) {
                        print("cambie pez")
                        moduleRouter.status.toggle()
                        print(moduleRouter.status)
                    }
                }
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        print("ajajaja")
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
    
    //@ObservedObject var moduleRouter = ModuleRouter()
    @ObservedObject var moduleRouter = ModuleRouter()
    //@EnvironmentObject var moduleRouter: ModuleRouter
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
                        if deliveries.count > 0 {
                            MaterialDeliveryDao(realm: try! Realm()).store(deliveries: deliveries)
                            
                            moduleRouter.status.toggle()
                            //self.goTo(page: "MATERIAL-DELIVERY")
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
                            let delivery = AdvertisingMaterialDelivery()
                            let dateDescription = String(Date().description)
                            let date = dateDescription.components(separatedBy: " ")[0]
                            
                            var verif = false
                            for i in deliveries {
                                if i.materialId == material.id {
                                    verif = true
                                    break
                                }
                            }
                            if !verif {
                                delivery.materialId = material.id
                                delivery.material =  material
                                delivery.date = date
                                deliveries.append(delivery)
                            }
                        }
                    }
                }
            }
        }
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
    var deliverieSet = AdvertisingMaterialDeliverySet()
    var item: AdvertisingMaterialDelivery
    var body: some View {
        let binding = Binding<String>(get: {
            self.item.comment
        }, set: {
            self.item.comment = $0
        })
        
        VStack{
            HStack {
                Text(item.material?.name ?? "")
            }
            Spacer()
            VStack{
                HStack {
                    Text(String(item.material?.sets[0].id ?? ""))
                    Spacer()
                    Text(String(format: NSLocalizedString("expDate", comment: ""), formatStringDate(date: String(item.material?.sets[0].dueDate ?? ""))))
                }
                Spacer()
                HStack {
                    Button(action: {
                        tvNumber -= 1
                        if tvNumber <= 0 {tvNumber = 0}
                        deliverieSet.id = String(item.materialId)
                        deliverieSet.objectId = item.objectId
                        deliverieSet.quantity = tvNumber
                        
                        item.sets.removeAll()
                        item.sets.insert(deliverieSet, at: 0)
                    }, label: {
                        Text("-")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    })
                    .background(Color.white)
                    Spacer()
                    VStack {
                        Text("\(String(tvNumber))")
                        Text(String(format: NSLocalizedString("materialRemainder", comment: ""),
                        String((item.material?.sets[0].stock ?? 0) - (item.material?.sets[0].delivered ?? 0))))
                    }
                    Spacer()
                    Button(action: {
                        tvNumber += 1
                        deliverieSet.id = String(item.materialId)
                        deliverieSet.objectId = item.objectId
                        deliverieSet.quantity = tvNumber
                        
                        item.sets.removeAll()
                        item.sets.insert(deliverieSet, at: 0)
                    }, label: {
                        Text("+")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    })
                    .background(Color.white)
                }
                TextField("Observaciones...", text: binding)
            }
            
            Divider()
             .frame(height: 1)
             .padding(.horizontal, 5)
             .background(Color.gray)
        }
    }
    
    func formatStringDate(date: String) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let newDate = dateFormatter.date(from: date)
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM d, yyyy")
            return dateFormatter.string(from: newDate!)
    }
    
}

struct MaterialDeliveryView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialDeliveryView()
    }
}

struct MaterialDeliveryListView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialDeliveryListView()
    }
}

struct MaterialDeliveryFormView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialDeliveryFormView()
    }
}
