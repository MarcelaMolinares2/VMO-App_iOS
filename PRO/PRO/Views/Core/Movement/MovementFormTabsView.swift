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

struct MovementFormTabMaterialView: View {
    var realm: Realm
    @Binding var materials: [AdvertisingMaterialDeliveryMaterial]
    
    var body: some View {
        MaterialDeliveryFormWrapperView(realm: realm, details: $materials)
    }
    
}

struct MovementFormTabPromotedView: View {
    var realm: Realm
    var isEditable: Bool
    var extraData: [String: Any]
    @Binding var selected: [String]
    
    @State private var modalOpen = false
    
    let groupByBrand: Bool = Config.get(key: "MOV_PROMOTED_ONLY_BRAND").value == 1
    
    var body: some View {
        VStack {
            if isEditable {
                CustomHeaderButtonIconView(label: "envPromotedProducts") {
                    modalOpen = true
                }
            }
            List {
                ForEach(selected, id: \.self) { item in
                    if groupByBrand {
                        if let brand = ProductBrandDao(realm: realm).by(id: item) {
                            Text(brand.name.capitalized)
                                .foregroundColor(.cTextHigh)
                                .multilineTextAlignment(.leading)
                        }
                    } else {
                        if let product = ProductDao(realm: realm).by(id: item) {
                            Text(product.name.capitalized)
                                .foregroundColor(.cTextHigh)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                .onMove(perform: move)
                .onDelete(perform: self.delete)
                .foregroundColor(.cTextMedium)
            }
            .environment(\.editMode, .constant(.active))
            .buttonStyle(PlainButtonStyle())
            
        }
        .sheet(isPresented: $modalOpen) {
            DialogSourcePickerView(selected: $selected, key: groupByBrand ? "PRODUCT-BY-BRAND": "PRODUCT-PROMOTED", multiple: true, title: (groupByBrand ? "envBrand": "envProduct").localized(), extraData: extraData) { selected in
                onSelectionDone(selected)
            }
        }
    }
    
    func onSelectionDone(_ selected: [String]) {
        modalOpen = false
    }
    
    func move(from source: IndexSet, to destination: Int) {
        self.selected.move(fromOffsets: source, toOffset: destination)
    }
    
    func delete(at offsets: IndexSet) {
        withAnimation {
            selected.remove(atOffsets: offsets)
        }
    }
    
}

struct MovementFormTabStockView: View {
    var realm: Realm
    @Binding var items: [MovementProductStockModel]
    
    @State private var selected: [String] = []
    @State private var modalOpen = false
    
    var body: some View {
        VStack {
            CustomHeaderButtonIconView(label: "envStock") {
                modalOpen = true
            }
            ScrollView {
                ForEach($items) { $item in
                    MovementFormTabStockItemView(realm: realm, item: $item) {
                        delete(detail: item)
                    }
                }
            }
        }
        .sheet(isPresented: $modalOpen) {
            DialogSourcePickerView(selected: $selected, key: "PRODUCT-STOCK", multiple: true, title: "envProduct".localized()) { selected in
                onSelectionDone(selected)
            }
        }
    }
    
    func onSelectionDone(_ selected: [String]) {
        modalOpen = false
        selected.forEach { s in
            if items.filter({ d in
                d.productId == Utils.castInt(value: s)
            }).count <= 0 {
                if let product = ProductDao(realm: realm).by(id: s) {
                    let item = MovementProductStockModel()
                    item.productId = product.id
                    items.append(item)
                }
            }
        }
    }
    
    private func delete(detail: MovementProductStockModel) {
        selected = selected.filter { $0 != String(detail.productId) }
        items = items.filter { $0.productId != detail.productId }
    }
    
}

struct MovementFormTabStockItemView: View {
    var realm: Realm
    @Binding var item: MovementProductStockModel
    let onDeleteTapped: () -> Void
    
    @State private var selected = [String]()
    @State private var dataReasons = Config.get(key: "MOV_STOCK_NE_REASONS").complement ?? "{}"
    @State private var modalReasonOpen = false
    
    var body: some View {
        let product = ProductDao(realm: realm).by(id: item.productId)
        VStack {
            CustomCard {
                HStack {
                    Text((product?.name ?? "").capitalized)
                        .foregroundColor(.cTextHigh)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                    Button(action: {
                        onDeleteTapped()
                    }) {
                        Image("ic-delete")
                            .resizable()
                            .foregroundColor(.cDanger)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22, alignment: .center)
                            .padding(8)
                    }
                    .frame(width: 44, height: 44, alignment: .center)
                }
                Toggle(isOn: $item.hasStock) {
                    Text("envPresenceAtPointOfSale")
                        .foregroundColor(.cTextHigh)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if item.hasStock {
                    Text("envQuantity")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.cTextMedium)
                    TextField("envQuantity", value: $item.quantity, formatter: NumberFormatter())
                        .cornerRadius(CGFloat(4))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Button(action: {
                        modalReasonOpen = true
                    }, label: {
                        HStack{
                            VStack{
                                Text(NSLocalizedString("envReason", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(item.noStockReason.isEmpty ? Color.cDanger : .cTextMedium)
                                    .font(.system(size: 14))
                                Text(DynamicUtils.jsonValue(data: dataReasons, selected: selected))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextHigh)
                                    .font(.system(size: 16))
                            }
                            Spacer()
                            Image("ic-arrow-expand-more")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35)
                                .foregroundColor(.cIcon)
                        }
                        .sheet(isPresented: $modalReasonOpen) {
                            DialogPlainPickerView(selected: $selected, data: dataReasons, multiple: false, title: "envReason".localized(), onSelectionDone: onSelectionDone)
                        }
                        .padding(.vertical, 10)
                    })
                }
            }
        }
        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
    }
    
    func onSelectionDone(_ selected: [String]) {
        if !selected.isEmpty {
            item.noStockReason = selected[0]
        }
        modalReasonOpen = false
    }
    
}

struct MovementFormTabShoppingView: View {
    var realm: Realm
    @Binding var items: [MovementProductShoppingModel]
    
    @State private var selected: [String] = []
    @State private var modalOpen = false
    
    var body: some View {
        VStack {
            CustomHeaderButtonIconView(label: "envShopping") {
                modalOpen = true
            }
            ScrollView {
                ForEach($items) { $item in
                    MovementFormTabShoppingItemView(realm: realm, item: $item) {
                        delete(detail: item)
                    }
                }
            }
        }
        .sheet(isPresented: $modalOpen) {
            DialogSourcePickerView(selected: $selected, key: "PRODUCT-SHOPPING", multiple: true, title: "envProduct".localized()) { selected in
                onSelectionDone(selected)
            }
        }
    }
    
    func onSelectionDone(_ selected: [String]) {
        modalOpen = false
        selected.forEach { s in
            if items.filter({ d in
                d.productId == Utils.castInt(value: s)
            }).count <= 0 {
                if let product = ProductDao(realm: realm).by(id: s) {
                    let item = MovementProductShoppingModel()
                    item.productId = product.id
                    product.competitors?.components(separatedBy: ",").forEach { competitor in
                        let c = MovementProductShoppingCompetitorModel()
                        c.id = competitor
                        c.price = 0
                        item.competitors.append(c)
                    }
                    items.append(item)
                }
            }
        }
    }
    
    func delete(detail: MovementProductShoppingModel) {
        selected = selected.filter { $0 != String(detail.productId) }
        items = items.filter { $0.productId != detail.productId }
    }
}

struct MovementFormTabShoppingItemView: View {
    var realm: Realm
    @Binding var item: MovementProductShoppingModel
    let onDeleteTapped: () -> Void
    
    var body: some View {
        let product = ProductDao(realm: realm).by(id: item.productId)
        VStack {
            CustomCard {
                HStack {
                    Text((product?.name ?? "").capitalized)
                        .foregroundColor(.cTextHigh)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                    Button(action: {
                        onDeleteTapped()
                    }) {
                        Image("ic-delete")
                            .resizable()
                            .foregroundColor(.cDanger)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22, alignment: .center)
                            .padding(8)
                    }
                    .frame(width: 44, height: 44, alignment: .center)
                }
                Text("envQuantity")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.cTextMedium)
                TextField("envQuantity", value: $item.price, formatter: NumberFormatter())
                    .cornerRadius(CGFloat(4))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Divider()
                ForEach($item.competitors) { $competitor in
                    MovementFormTabShoppingCompetitorItemView(item: $competitor)
                }
            }
        }
        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
    }
}

struct MovementFormTabShoppingCompetitorItemView: View{
    
    @Binding var item: MovementProductShoppingCompetitorModel
    
    var body: some View {
        VStack{
            Text(item.id.capitalized)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.cTextMedium)
            TextField("envQuantity", value: $item.price, formatter: NumberFormatter())
                .cornerRadius(CGFloat(4))
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct MovementFormTabTransferenceView: View {
    var realm: Realm
    var visitType: String
    @Binding var items: [MovementProductTransferenceModel]
    
    @State private var selected: [String] = []
    @State private var modalOpen = false
    
    var body: some View {
        VStack {
            CustomHeaderButtonIconView(label: "envTransference") {
                modalOpen = true
            }
            ScrollView {
                ForEach($items) { $item in
                    MovementFormTabTransferenceItemView(realm: realm, visitType: visitType, item: $item) {
                        delete(detail: item)
                    }
                }
            }
        }
        .sheet(isPresented: $modalOpen) {
            DialogSourcePickerView(selected: $selected, key: "PRODUCT-TRANSFERENCE", multiple: true, title: "envProduct".localized()) { selected in
                onSelectionDone(selected)
            }
        }
    }
    
    func onSelectionDone(_ selected: [String]) {
        modalOpen = false
        selected.forEach { s in
            if items.filter({ d in
                d.productId == Utils.castInt(value: s)
            }).count <= 0 {
                if let product = ProductDao(realm: realm).by(id: s) {
                    let item = MovementProductTransferenceModel()
                    item.productId = product.id
                    items.append(item)
                }
            }
        }
    }
    
    private func delete(detail: MovementProductTransferenceModel) {
        selected = selected.filter { $0 != String(detail.productId) }
        items = items.filter { $0.productId != detail.productId }
    }
    
}

struct MovementFormTabTransferenceItemView: View{
    var realm: Realm
    var visitType: String
    @Binding var item: MovementProductTransferenceModel
    let onDeleteTapped: () -> Void
    
    let transferOptions = Utils.jsonDictionary(string: Config.get(key: "MOV_TRANSFER_FIELDS").complement ?? "")
    
    @State private var selected = [String]()
    @State private var modalBonusOpen = false
    
    @State private var bonusVisible = false
    @State private var bonusRequired = false
    @State private var priceVisible = true
    @State private var priceRequired = false
    @State private var quantityVisible = true
    @State private var quantityRequired = false
    
    var body: some View {
        let product = ProductDao(realm: realm).by(id: item.productId)
        VStack {
            CustomCard {
                HStack {
                    Text((product?.name ?? "").capitalized)
                        .foregroundColor(.cTextHigh)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                    Button(action: {
                        onDeleteTapped()
                    }) {
                        Image("ic-delete")
                            .resizable()
                            .foregroundColor(.cDanger)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22, alignment: .center)
                            .padding(8)
                    }
                    .frame(width: 44, height: 44, alignment: .center)
                }
                if quantityVisible {
                    Text("envQuantity")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(quantityRequired && item.quantity <= 0 ? .cDanger : .cTextMedium)
                    TextField("envQuantity", value: $item.quantity, formatter: NumberFormatter())
                        .cornerRadius(CGFloat(4))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                if priceVisible {
                    Text("envPrice")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(priceRequired && item.price <= 0 ? .cDanger : .cTextMedium)
                    TextField("envPrice", value: $item.price, formatter: NumberFormatter())
                        .cornerRadius(CGFloat(4))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                if bonusVisible {
                    Divider()
                    VStack {
                        Button(action: {
                            modalBonusOpen = true
                        }, label: {
                            HStack{
                                VStack{
                                    Text(NSLocalizedString("envBonusProduct", comment: ""))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(bonusRequired && item.bonusProduct <= 0 ? .cDanger : .cTextMedium)
                                        .font(.system(size: 14))
                                    Text(DynamicUtils.tableValue(key: "PRODUCT", selected: selected, defaultValue: "envChoose".localized()).capitalized)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.cTextHigh)
                                        .font(.system(size: 16))
                                }
                                Spacer()
                                Image("ic-arrow-expand-more")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                                    .foregroundColor(.cIcon)
                            }
                            .sheet(isPresented: $modalBonusOpen) {
                                DialogSourcePickerView(selected: $selected, key: "PRODUCT", multiple: false, title: "envProduct".localized()) { selected in
                                    onSelectionDone(selected)
                                }
                            }
                            .padding(.vertical, 10)
                        })
                        Text("envBonusQuantity")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(bonusRequired && item.bonusQuantity <= 0 ? .cDanger : .cTextMedium)
                        TextField("envBonusQuantity", value: $item.bonusQuantity, formatter: NumberFormatter())
                            .cornerRadius(CGFloat(4))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
                }
            }
        }
        .onAppear {
            initItem()
        }
    }
    
    func initItem() {
        if let ops = transferOptions[visitType.lowercased()] as? [String: Any] {
            if let bonus = ops["bonus"] as? [String: Int] {
                bonusRequired = bonus["required"] == 1
                bonusVisible = bonus["visible"] == 1
            }
            if let price = ops["price"] as? [String: Int] {
                priceRequired = price["required"] == 1
                priceVisible = price["visible"] == 1
            }
            if let quantity = ops["quantity"] as? [String: Int] {
                quantityRequired = quantity["required"] == 1
                quantityVisible = quantity["visible"] == 1
            }
        }
    }
    
    func onSelectionDone(_ selected: [String]) {
        self.modalBonusOpen = false
        if !selected.isEmpty {
            item.bonusProduct = Utils.castInt(value: selected[0])
        }
    }
}
