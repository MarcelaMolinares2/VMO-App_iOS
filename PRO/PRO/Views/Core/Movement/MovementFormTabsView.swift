//
//  MovementFormTabsView.swift
//  PRO
//
//  Created by VMO on 23/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast
import Combine

struct MovementFormTabPromotedView: View {
    
    @Binding var selected: [String]
    @State var selectedBridge = [String]()
    @State var products = [Product]()
    @State private var isEditable = false
    @State private var isSheet = false
    let valueNameBrand: Int = Config.get(key: "MOV_PROMOTED_ONLY_BRAND").value
    
    var body: some View {
        VStack{
            Button(action: {
                isSheet = true
            }, label: {
                HStack{
                    Spacer()
                    Text(NSLocalizedString("envPromotedProducts", comment: ""))
                    Image("ic-plus-circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                    Spacer()
                }
                .frame(height: 30)
                .padding(10)
                .foregroundColor(.cPrimary)
            })
            List {
                ForEach(products, id: \.self) { item in
                    Text((valueNameBrand == 0) ? item.name ?? "": item.brand ?? "")
                }
                .onMove(perform: move)
                .onDelete(perform: self.delete)
                .foregroundColor(.cPrimary)
                .onLongPressGesture {
                    withAnimation {
                        self.isEditable = true
                    }
                }
            }
            .environment(\.editMode, isEditable ? .constant(.active) : .constant(.inactive))
            .buttonStyle(PlainButtonStyle())
            
        }.sheet(isPresented: $isSheet, content: {
            CustomDialogPicker(onSelectionDone: onSelectionDone, selected: $selectedBridge, key: (valueNameBrand == 0) ? "PRODUCT-PROMOTED": "PRODUCT-BY-BRAND", multiple: true, isSheet: true)
        })
        .onAppear {
            initView()
        }
        
    }
    
    func initView(){
        self.selected.forEach{ id in
            if let product = ProductDao(realm: try! Realm()).by(id: id){
                if !validate(product: product){
                    products.append(product)
                }
            }
        }
    }
    
    func onSelectionDone(_ selected: [String]) {
        isSheet = false
        self.selectedBridge.forEach{ id in
            if let product = ProductDao(realm: try! Realm()).by(id: id){
                if !validate(product: product){
                    products.append(product)
                    self.selected.append(id)
                }
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        self.products.move(fromOffsets: source, toOffset: destination)
        self.selected.move(fromOffsets: source, toOffset: destination)
        withAnimation {
            isEditable = false
        }
    }
    
    func delete(at offsets: IndexSet) {
        withAnimation{
            var its: Int = 0
            offsets.forEach{ it in
                its = it
            }
            selected.remove(at: its)
            self.products.remove(atOffsets: offsets)
        }
    }
    
    func validate(product: Product) -> Bool {
        var exists = false
        for i in products {
            if i.id == product.id {
                exists = true
                break
            }
        }
        return exists
    }
}


struct MovementFormTabStockView: View {
    
    @Binding var selected: RealmSwift.List<MovementProductStock>
    
    var body: some View {
        ScrollView {
            VStack {
                Text("STOCK!!!!")
            }
        }
    }
    
}


struct MovementFormTabShoppingView: View {
    
    @Binding var selected: RealmSwift.List<MovementProductShopping>
    
    var body: some View {
        ScrollView {
            VStack {
                Text("SHOPPING!!!!")
            }
        }
    }
    
}


struct MovementFormTabTransferenceView: View {
    
    @Binding var selected: RealmSwift.List<MovementProductTransference>
    var visitType: String
    
    let dynamicData = Utils.jsonDictionary(string: Config.get(key: "MOV_TRANSFER_FIELDS").complement ?? "")
    @State private var isSheet = false
    @State private var idsSelected = [String]()
    @State private var dataVisitType: Any = ""
    @State private var numOfPeople = "0"
    
    
    var body: some View {
        
        VStack {
            Button(action: {
                print("aajaja")
                print(dynamicData)
                isSheet = true
            }, label: {
                HStack{
                    Spacer()
                    Text(NSLocalizedString("envTransference", comment: ""))
                    Image("ic-plus-circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                    Spacer()
                }
                .frame(height: 30)
                .padding(10)
            })
            List {
                ForEach(selected, id: \.self) { item in
                    
                    
                    VStack (alignment: .leading, spacing: 5){
                        VStack {
                            if let product = ProductDao(realm: try! Realm()).by(id: String(item.id)){
                                Text(product.name ?? "")
                                    .font(.system(size: 18))
                            }
                            if let quantity = (dataVisitType as! NSDictionary)["quantity"]{
                                /*
                                if let requiredBonus = (bouns as! NSDictionary)["required"]{
                                    print(requiredBonus)
                                }
                                */
                                if let visibleQuantity = (quantity as! NSDictionary)["visible"]{
                                    if String((visibleQuantity as AnyObject).description) == "1"{
                                        VStack{
                                            Text("QUANTITY")
                                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                                .font(.system(size: 14))
                                            TextField("Total number of people", text: Binding(
                                                get: { String(item.quantity) },
                                                set: { item.quantity = Float($0) ?? 0 }
                                            ))
                                                .frame(height: 30)
                                                .foregroundColor(.black)
                                                .keyboardType(.numberPad)
                                            Divider()
                                             .frame(height: 1)
                                             .padding(.horizontal, 5)
                                             .background(Color.gray)
                                        }
                                        
                                        
                                    }
                                }
                            }
                            if let price = (dataVisitType as! NSDictionary)["price"]{
                                /*
                                if let requiredBonus = (bouns as! NSDictionary)["required"]{
                                    print(requiredBonus)
                                }
                                */
                                if let visiblePrice = (price as! NSDictionary)["visible"]{
                                    if String((visiblePrice as AnyObject).description) == "1"{
                                        VStack{
                                            HStack{
                                                Text("PRICE VISIBLE")
                                                    .font(.system(size: 14))
                                                Spacer()
                                            }
                                            TextField("Total number of people", text: Binding(
                                                get: { String(item.price) },
                                                set: { item.price = Float($0) ?? 0 }
                                            ))
                                                .frame(height: 30)
                                                .foregroundColor(.black)
                                                .keyboardType(.numberPad)
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
                            if let bouns = (dataVisitType as! NSDictionary)["bonus"]{
                                /*
                                if let requiredBonus = (bouns as! NSDictionary)["required"]{
                                    print(requiredBonus)
                                }
                                */
                                if let visibleBonus = (bouns as! NSDictionary)["visible"]{
                                    if String((visibleBonus as AnyObject).description) == "1" {
                                        VStack {
                                            VStack {
                                                HStack{
                                                    Spacer()
                                                    Text("BONUS VISIBLE")
                                                        .font(.system(size: 16))
                                                    Spacer()
                                                }
                                                Button(action: {
                                                    print("Pendejo")
                                                }) {
                                                    HStack{
                                                        VStack{
                                                            Text("Product")
                                                                .font(.system(size: 14))
                                                            Text("Select....")
                                                                .font(.system(size: 14))
                                                        }
                                                        Spacer()
                                                        Image("ic-arrow-expand-more")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 32)
                                                    }
                                                    .padding(10)
                                                    .background(Color.white)
                                                    .frame(alignment: Alignment.center)
                                                    .clipped()
                                                    .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                                                }
                                            }
                                            VStack{
                                                HStack{
                                                    Text("PRICE VISIBLE")
                                                        .font(.system(size: 14))
                                                    Spacer()
                                                }
                                                TextField("Total number of people", text: Binding(
                                                    get: { String(item.bonusQuantity) },
                                                    set: { item.bonusQuantity = Float($0) ?? 0 }
                                                ))
                                                    .frame(height: 30)
                                                    .foregroundColor(.black)
                                                    .keyboardType(.numberPad)
                                                Divider()
                                                 .frame(height: 1)
                                                 .padding(.horizontal, 5)
                                                 .background(Color.gray)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 7)
                                        }
                                        .padding(7)
                                        .background(Color.white)
                                        .frame(alignment: Alignment.center)
                                        .clipped()
                                        .shadow(color: Color.gray, radius: 2, x: 0, y: 0)
                                    }
                                }
                            }
                        }
                    }
                    .padding(7)
                    .background(Color.white)
                    .frame(alignment: Alignment.center)
                    .clipped()
                    .shadow(color: Color.gray, radius: 4, x: 0, y: 0)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }.sheet(isPresented: $isSheet, content: {
            CustomDialogPicker(onSelectionDone: onSelectionDone, selected: $idsSelected, key: "PRODUCT-TRANSFERENCE", multiple: true, isSheet: true)
        })
        .foregroundColor(.cPrimary)
        .onAppear{
            initView()
        }
    }
    
    func initView(){
        print(Config.get(key: "MOV_TRANSFER_FIELDS").complement ?? "")
        print("____________")
        if let data = dynamicData[visitType.lowercased()]{
            dataVisitType = data
            if let bouns = (dataVisitType as! NSDictionary)["bonus"]{
                if let requiredBonus = (bouns as! NSDictionary)["required"]{
                    print(requiredBonus)
                }
                if let visibleBonus = (bouns as! NSDictionary)["visible"]{
                    print(visibleBonus)
                }
            }
        }
    }
    
    func onSelectionDone(_ selected: [String]) {
        isSheet = false
        print("__________self.selected___________")
        /*
        self.selected.forEach{ item in
            print(item.objectId)
            print(item.id)
            print(item.price)
        }
        */
        print(self.selected)
        print("_________idsSelected____________")
        print(self.idsSelected)
        self.idsSelected.forEach{ id in
            let mm = MovementProductTransference()
            mm.id = Int(id) ?? 0
            self.selected.append(mm)
        }
        /*
        self.selectedBridge.forEach{ id in
            if let product = ProductDao(realm: try! Realm()).by(id: id){
                if !validate(product: product){
                    products.append(product)
                    self.selected.append(id)
                }
            }
        }
        */
    }
    
}
