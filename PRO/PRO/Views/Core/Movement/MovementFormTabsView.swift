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
                    //Text((valueNameBrand == 0) ? item.name ?? "": item.brand ?? "")
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
    
    @State private var isSheet = false
    @State private var idsSelected = [String]()
    
    var body: some View {
        VStack {
            Button(action: {
                isSheet = true
            }, label: {
                HStack{
                    Spacer()
                    Text(NSLocalizedString("envStock", comment: ""))
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
                    CardStock(item: $selected[index])
                }
            }
            .buttonStyle(PlainButtonStyle())
        }.sheet(isPresented: $isSheet, content: {
            CustomDialogPicker(onSelectionDone: onSelectionDone, selected: $idsSelected, key: "PRODUCT-PROMOTED", multiple: true, isSheet: true)
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
                let movementProductStock = MovementProductStock()
                movementProductStock.id = Int(id) ?? 0
                self.selected.append(movementProductStock)
            }
        }
    }
    
}

struct CardStock: View {
    @Binding var item: MovementProductStock
    
    @State var configData = Config.get(key: "MOV_STOCK_NE_REASONS").complement ?? ""
    @State private var showReason = false
    @State private var isSheet = false
    @State private var selected = [String]()
    @State private var reason = ""
    var body: some View {
        VStack{
            if let product = ProductDao(realm: try! Realm()).by(id: String(item.id)){
                Toggle(isOn: $showReason){
                    Text(product.name ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 18))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .onChange(of: showReason, perform: { value in
                    item.hasStock = value
                    item.noStockReason = (value) ? "" : item.noStockReason
                })
                .toggleStyle(SwitchToggleStyle(tint: .cBlueDark))
                
                
                if showReason {
                    TextField("", text: Binding(
                        get: { String(item.quantity) },
                        set: { item.quantity = Float($0) ?? 0 }
                    ))
                    .cornerRadius(CGFloat(4))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Button(action: {
                        isSheet = true
                    }) {
                        HStack{
                            VStack{
                                Text(NSLocalizedString("envReason", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))
                                Text( (item.noStockReason == "") ? NSLocalizedString("envChoose", comment: ""): reason)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))
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
                
            }
        }
        .partialSheet(isPresented: $isSheet) {
            SourceDynamicDialogPicker(onSelectionDone: onSelectionDone, selected: $selected, data: configData, multiple: false, title: "Titulo", isSheet: true)
        }
        .onAppear{initCard()}
        .padding(7)
        .background(Color.white)
        .frame(alignment: Alignment.center)
        .clipped()
        .shadow(color: Color.gray, radius: 4, x: 0, y: 0)
    }
    
    func initCard(){
        
        let dynamicData = Utils.jsonObject(string: configData)
        dynamicData.forEach{ it in
            if it["id"] as! String == item.noStockReason{
                reason = it["label"] as! String
            }
        }
    }
    
    func onSelectionDone(_ selected: [String]) {
        isSheet = false
        item.noStockReason = self.selected[0]
        let dynamicData = Utils.jsonObject(string: configData)
        dynamicData.forEach{ it in
            if it["id"] as! String == self.selected[0]{
                reason = it["label"] as! String
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
                    Text(NSLocalizedString("envShopping", comment: ""))
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
                    CardShopping(item: $selected[index])
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
                if let product = ProductDao(realm: try! Realm()).by(id: id) {
                    let movementProductShopping = MovementProductShopping()
                    movementProductShopping.id = Int(id) ?? 0
                    product.competitors?.components(separatedBy: ",").forEach({ competitor in
                        let movementCompetitor = MovementProductShoppingCompetitor()
                        movementCompetitor.id = competitor
                        movementProductShopping.competitors.append(movementCompetitor)
                    })
                    self.selected.append(movementProductShopping)
                }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        withAnimation{
            //self.selected.remove(atOffsets: offsets)
        }
    }
}

struct CardShopping: View {
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
        }
        .padding(7)
        .background(Color.white)
        .frame(alignment: Alignment.center)
        .clipped()
        .shadow(color: Color.gray, radius: 4, x: 0, y: 0)
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
                    CardTransference(item: $selected[index], dataVisitType: dataVisitType)
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

struct CardTransference: View{
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
                                                    Text(NSLocalizedString("envChoose", comment: ""))
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
