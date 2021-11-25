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

struct MovementFormTabPromotedView: View {
    
    @ObservedObject private var selectPromotedModalToggle = ModalToggle()
    @Binding var selected: [String]
    @State var products = [Product]()
    @State private var isEditable = false
    @State private var showToast = false
    @EnvironmentObject var viewRouter: ViewRouter
    let value: Int = Config.get(key: "MOV_PROMOTED_ONLY_BRAND").value
    
    var body: some View {
        ZStack{
            VStack{
                Button(action: {
                    print("xxxx")
                    selectPromotedModalToggle.status.toggle()
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
                        Text(item.name ?? "")
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
                
            }
            if selectPromotedModalToggle.status {
                GeometryReader {geo in
                    CustomDialogPicker(onSelectionDone: onSelectionDone, selected: $selected, key: "PRODUCT-PROMOTED", multiple: true)
                }
                .background(Color.black.opacity(0.45))
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                        if products.count > 0 {
                            viewRouter.currentPage = "MASTER"
                        } else {
                            self.showToast.toggle()
                        }
                    }
                }
                .toast(isPresenting: $showToast){
                    AlertToast(type: .regular, title: NSLocalizedString("nonePromotedProducts", comment: ""))
                }
            }
        }
    }
    
    func onSelectionDone(_ selected: [String]) {
        selectPromotedModalToggle.status.toggle()
        self.selected.forEach{ id in
            if let product = ProductDao(realm: try! Realm()).by(id: id){
                var exists = false
                for i in products {
                    if i.id == product.id {
                        exists = true
                        break
                    }
                }
                if !exists {
                    products.append(product)
                }
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        self.products.move(fromOffsets: source, toOffset: destination)
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
            print(selected)
            //selected[type]?.binding.removeAll(where: { $0 == String(its) })
            self.products.remove(atOffsets: offsets)
        }
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
    
    var body: some View {
        ScrollView {
            VStack {
                Text("TRANSFERENCE!!!!")
            }
        }
    }
    
}
