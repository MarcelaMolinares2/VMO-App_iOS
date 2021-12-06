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
                .padding(10)
                .foregroundColor(.cTextMedium)
            })
            List {
                ForEach(products, id: \.self) { item in
                    Text((valueNameBrand == 0) ? item.name ?? "": item.brand ?? "")
                }
                .onMove(perform: move)
                .onDelete(perform: self.delete)
                .foregroundColor(.cTextMedium)
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
    
    @State private var isSheet = false
    @State private var idsSelected = [String]()
    
    var body: some View {
        VStack {
            Button(action: {
                isSheet = true
            }, label: {
                HStack{
                    Spacer()
                    Text("SHOPPING")
                    Image("ic-plus-circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                    Spacer()
                }
                .foregroundColor(.cTextMedium)
                .padding(10)
            })
            List {
                ForEach(selected.indices, id: \.self) { index in
                    CardTabShopping(item: $selected[index])
                }
                .onDelete(perform: self.delete)
            }
            .buttonStyle(PlainButtonStyle())
        }.sheet(isPresented: $isSheet, content: {
            CustomDialogPicker(onSelectionDone: onSelectionDone, selected: $idsSelected, key: "PRODUCT-SHOPPING", multiple: true, isSheet: true)
        })
    }
    
    func onSelectionDone(_ selected: [String]) {
        isSheet = false
        self.idsSelected.forEach{ id in
            var exist = false
            for i in self.selected {
                if String(i.id) == id{
                    exist = true
                    break
                }
            }
            if !exist {
                let movementProductShopping = MovementProductShopping()
                movementProductShopping.id = Int(id) ?? 0
                self.selected.append(movementProductShopping)
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        withAnimation{
            //self.selected.remove(atOffsets: offsets)
        }
    }
}

struct CardTabShopping: View {
    @Binding var item: MovementProductShopping
    
    @State var idCompetitors : [String] = []
    var body: some View {
        VStack{
            VStack{
                if let product = ProductDao(realm: try! Realm()).by(id: String(item.id)){
                    Text(product.name ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 18))
                }
                Text("ENTRY PRICE")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.cTextMedium)
                    .font(.system(size: 14))
                TextField("", text: Binding(
                    get: { String(item.price) },
                    set: { item.price = Float($0) ?? 0 }
                ))
                .cornerRadius(CGFloat(4))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            Spacer()
                .frame(height: 15)
            VStack {
                ForEach(item.competitors.indices, id: \.self) { index in
                    CardCompetitorsShopping(item: $item.competitors[index])
                }
            }
            .padding(7)
            .background(Color.white)
            .frame(alignment: Alignment.center)
            .clipped()
            .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
            Spacer()
                .frame(height: 15)
        }
        .padding(7)
        .background(Color.white)
        .frame(alignment: Alignment.center)
        .clipped()
        .shadow(color: Color.gray, radius: 4, x: 0, y: 0)
        .onAppear{
            initView()
        }
    }
    
    func initView(){
        if let product = ProductDao(realm: try! Realm()).by(id: String(item.id)){
            if item.competitors.count == 0{
                idCompetitors = (product.competitors ?? "").split(separator: ",").map { String($0) }
            }
        }
        idCompetitors.forEach{ it in
            let movementProductShoppingCompetitor = MovementProductShoppingCompetitor()
            movementProductShoppingCompetitor.id = it
            item.competitors.append(movementProductShoppingCompetitor)
        }
    }
}

struct CardCompetitorsShopping: View{
    
    @Binding var item: MovementProductShoppingCompetitor
    
    var body: some View {
        VStack{
            Text(item.id)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.cTextMedium)
                .font(.system(size: 14))
            
            TextField("", text: Binding(
                get: { String(item.price) },
                set: { item.price = Float($0) ?? 0 }
            ))
            .cornerRadius(CGFloat(4))
            .textFieldStyle(RoundedBorderTextFieldStyle())
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
    
    var body: some View {
        VStack {
            Button(action: {
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
                .foregroundColor(.cTextMedium)
                .padding(10)
            })
            List {
                ForEach(selected.indices, id: \.self) { index in
                    CardTabTransference(item: $selected[index], dataVisitType: dataVisitType)
                }
                .onDelete(perform: self.delete)
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
        if let data = dynamicData[visitType.lowercased()]{
            dataVisitType = data
        }
    }
    
    func onSelectionDone(_ selected: [String]) {
        isSheet = false
        self.idsSelected.forEach{ id in
            var exist = false
            for i in self.selected {
                if String(i.id) == id{
                    exist = true
                    break
                }
            }
            if !exist {
                let movementProductTransference = MovementProductTransference()
                movementProductTransference.id = Int(id) ?? 0
                self.selected.append(movementProductTransference)
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        withAnimation{
            //self.selected.remove(atOffsets: offsets)
        }
    }
    
}

struct CardTabTransference: View{
    @Binding var item: MovementProductTransference
    var dataVisitType: Any
    
    @State private var isSheet = false
    @State private var idsSelected = [String]()
    var body: some View{
        VStack (alignment: .leading, spacing: 15){
            VStack {
                if let product = ProductDao(realm: try! Realm()).by(id: String(item.id)){
                    Text(product.name ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 18))
                }
                if let quantity = (dataVisitType as! NSDictionary)["quantity"]{
                    if let visibleQuantity = (quantity as! NSDictionary)["visible"]{
                        if String((visibleQuantity as AnyObject).description) == "1"{
                            VStack{
                                if let requiredQuantity = (quantity as! NSDictionary)["required"]{
                                    Text(NSLocalizedString("quantityTransference", comment: ""))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor((String((requiredQuantity as AnyObject).description)  == "1") ? Color.cDanger : .cTextMedium)
                                        .font(.system(size: 14))
                                }
                                TextField("", text: Binding(
                                    get: { String(item.quantity) },
                                    set: { item.quantity = Float($0) ?? 0 }
                                ))
                                .cornerRadius(CGFloat(4))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding(.top, 3)
                        }
                    }
                }
                if let price = (dataVisitType as! NSDictionary)["price"]{
                    if let visiblePrice = (price as! NSDictionary)["visible"]{
                        if String((visiblePrice as AnyObject).description) == "1"{
                            VStack{
                                if let priceQuantity = (price as! NSDictionary)["required"]{
                                    Text(NSLocalizedString("priceTransference", comment: ""))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor((String((priceQuantity as AnyObject).description)  == "1") ? Color.cDanger : .cTextMedium)
                                        .font(.system(size: 14))
                                }
                                TextField("", text: Binding(
                                    get: { String(item.price) },
                                    set: { item.price = Float($0) ?? 0 }
                                ))
                                .cornerRadius(CGFloat(4))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding(.top, 3)
                        }
                    }
                }
            }
            VStack {
                if let bouns = (dataVisitType as! NSDictionary)["bonus"]{
                    if let visibleBonus = (bouns as! NSDictionary)["visible"]{
                        if String((visibleBonus as AnyObject).description) == "1" {
                            VStack {
                                VStack {
                                    Text(NSLocalizedString("bonusTransference", comment: ""))
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundColor(.cTextMedium)
                                        .font(.system(size: 16))
                                    Button(action: {
                                        isSheet = true
                                    }) {
                                        HStack{
                                            VStack{
                                                if let bounsRequired = (bouns as! NSDictionary)["required"]{
                                                    Text(NSLocalizedString("productTransference", comment: ""))
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .foregroundColor((String((bounsRequired as AnyObject).description)  == "1") ? Color.cDanger : .cTextMedium)
                                                        .font(.system(size: 14))
                                                }
                                                if let product = ProductDao(realm: try! Realm()).by(id: String(item.bonusProduct)){
                                                    Text(product.name ?? "")
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .foregroundColor(.cTextMedium)
                                                        .font(.system(size: 14))
                                                } else {
                                                    Text(NSLocalizedString("nameDisabledTransference", comment: ""))
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .foregroundColor(.cTextMedium)
                                                        .font(.system(size: 14))
                                                
                                                }
                                            }
                                            Spacer()
                                            Image("ic-arrow-expand-more")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 35)
                                                .foregroundColor(.cTextMedium)
                                        }
                                        .padding(10)
                                        .background(Color.white)
                                        .frame(alignment: Alignment.center)
                                        .clipped()
                                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                                    }
                                }
                                VStack{
                                    if let bounsRequired = (bouns as! NSDictionary)["required"]{
                                        Text(NSLocalizedString("bonusUnitsTransference", comment: ""))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor((String((bounsRequired as AnyObject).description)  == "1") ? Color.cDanger : .cTextMedium)
                                            .font(.system(size: 14))
                                        
                                    }
                                    TextField("", text: Binding(
                                        get: { String(item.bonusQuantity) },
                                        set: { item.bonusQuantity = Float($0) ?? 0 }
                                    ))
                                        .cornerRadius(CGFloat(4))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
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
        .sheet(isPresented: $isSheet, content: {
            CustomDialogPicker(onSelectionDone: onSelectionDone, selected: $idsSelected, key: "PRODUCT-TRANSFERENCE", multiple: false, isSheet: true)
        })
    }
    
    func onSelectionDone(_ selected: [String]) {
        self.isSheet = false
        self.idsSelected.forEach{ id in
            item.bonusProduct = Int(id) ?? 0
        }
    }
}
