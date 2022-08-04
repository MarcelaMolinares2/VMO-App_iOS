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
        case "FORM":
            MaterialDeliveryFormView(moduleRouter: moduleRouter)
        default:
            MaterialDeliveryListView(moduleRouter: moduleRouter)
        }
    }
}

struct MaterialDeliveryListView: View {
    
    @ObservedObject var moduleRouter: ModuleRouter
    
    @State private var deliveries: [AdvertisingMaterialDeliveryReport] = []
    
    @State private var search = ""
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HeaderToggleView(title: "modMaterialDelivery")
                ScrollView {
                    ForEach(deliveries, id: \.id) { item in
                        MaterialDeliveryListItemView(item: item)
                    }
                }
                .refreshable {
                    getDeliveries()
                }
            }
            HStack {
                Spacer()
                FAB(image: "ic-plus") {
                    moduleRouter.currentPage = "FORM"
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .onAppear {
            getDeliveries()
        }
    }
    
    func getDeliveries() {
        let realm = try! Realm()
        let local = MaterialDeliveryDao(realm: realm).all()
        var ix = 0
        for i in local {
            i.materials.forEach { m in
                let material = MaterialDao(realm: realm).by(id: m.materialId)
                m.sets.forEach { s in
                    let item = AdvertisingMaterialDeliveryReport()
                    item.id = 1000000 + (ix)
                    item.quantity = s.quantity
                    item.comment = i.comment
                    item.date = i.date
                    item.material = material
                    item.set = MaterialSetDao(realm: realm).by(id: s.id)
                    item.madeBy = UserDao(realm: realm).logged()
                    deliveries.append(item)
                    ix += 1
                }
            }
        }
        AppServer().postRequest(data: [String: Any](), path: "vm/advertising-material/report/deliveries") { (bool, int, data) in
            if let rs = data as? [String] {
                for item in rs {
                    let decoded = try! JSONDecoder().decode(AdvertisingMaterialDeliveryReport.self, from: item.data(using: .utf8)!)
                    deliveries.append(decoded)
                }
            }
        }
    }
}

struct MaterialDeliveryListItemView: View {
    
    var item: AdvertisingMaterialDeliveryReport
    
    var body: some View {
        VStack {
            CustomCard {
                Text(item.material?.name ?? "")
                    .foregroundColor(.cTextHigh)
                    .font(.system(size: 15))
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Divider()
                    .frame(height: 0.7)
                    .padding(.horizontal, 5)
                    .background(Color.gray)
                HStack{
                    Text(item.set?.label ?? "--")
                        .foregroundColor(.cTextMedium)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    Text(String(format: NSLocalizedString("envQuantityAbb", comment: "Q: %@"), String(item.quantity)))
                        .font(.system(size: 18))
                        .foregroundColor(.cTextHigh)
                }
                Divider()
                    .frame(height: 0.7)
                    .padding(.horizontal, 5)
                    .background(Color.gray)
                HStack {
                    Spacer()
                    Text(Utils.dateFormat(date: Utils.strToDate(value: item.date), format: "dd MMM yy"))
                        .foregroundColor(.cTextHigh)
                        .font(.system(size: 13))
                }
            }
        }
        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
    }
}


struct MaterialDeliveryFormWrapperView: View {
    var realm: Realm
    @Binding var details: [AdvertisingMaterialDeliveryMaterial]
    
    @State private var selected = [String]()
    @State private var modalOpen = false
    
    var body: some View {
        VStack {
            Button(action: {
                modalOpen = true
            }) {
                ZStack(alignment: .center) {
                    HStack {
                        Spacer()
                        Image("ic-plus-circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40, alignment: .center)
                            .foregroundColor(.cIcon)
                    }
                    VStack {
                        Text("envMaterialAndSamples")
                            .foregroundColor(.cTextHigh)
                    }
                }
            }
            .padding(.horizontal, Globals.UI_FORM_PADDING_HORIZONTAL)
            ScrollView {
                ForEach($details) { $detail in
                    MaterialDeliveryFormItemView(realm: realm, deliveryMaterial: $detail) {
                        delete(materialDelivery: detail)
                    }
                }
                ScrollViewFABBottom()
            }
        }
        .sheet(isPresented: $modalOpen) {
            DialogSourcePickerView(selected: $selected, key: "MATERIAL", multiple: true, title: NSLocalizedString("envMaterial", comment: "Material")) { selected in
                onSelectionDone(selected)
            }
        }
    }
    
    private func delete(materialDelivery: AdvertisingMaterialDeliveryMaterial) {
        selected = selected.filter { $0 != String(materialDelivery.materialId) }
        details = details.filter { $0.materialId != materialDelivery.materialId }
    }
    
    func onSelectionDone(_ selected: [String]) {
        modalOpen = false
        selected.forEach { s in
            if details.filter({ d in
                d.materialId == Utils.castInt(value: s)
            }).count <= 0 {
                if let material = MaterialDao(realm: realm).by(id: s) {
                    let detail = AdvertisingMaterialDeliveryMaterial()
                    detail.materialId = material.id
                    material.sets.forEach { materialSet in
                        let deliverySet = AdvertisingMaterialDeliveryMaterialSet()
                        deliverySet.id = materialSet.id
                        detail.sets.append(deliverySet)
                    }
                    details.append(detail)
                }
            }
        }
    }
    
}

struct MaterialDeliveryFormView: View {
    @ObservedObject var moduleRouter: ModuleRouter
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var showToast = false
    @State private var savedToast = false
    
    @State private var details = [AdvertisingMaterialDeliveryMaterial]()
    @State private var date = Date()
    
    var realm = try! Realm()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HeaderToggleView(title: "modMaterialDelivery") {
                    moduleRouter.currentPage = "LIST"
                }
                VStack {
                    DatePicker("envDate", selection: $date, displayedComponents: .date)
                }
                .padding(.bottom, 10)
                .padding(.horizontal, Globals.UI_FORM_PADDING_HORIZONTAL)
                MaterialDeliveryFormWrapperView(realm: realm, details: $details)
            }
            HStack {
                Spacer()
                if !savedToast {
                    FAB(image: "ic-cloud") {
                        validate()
                    }
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .toast(isPresenting: $showToast){
            AlertToast(type: .error(.cWarning), title: NSLocalizedString("errMaterialDeliveryEmpty", comment: ""))
        }
        .toast(isPresenting: $savedToast) {
            AlertToast(type: .complete(.cDone), title: NSLocalizedString("envSuccessfullySaved", comment: ""))
        }
    }
    
    func validate() {
        if details.isEmpty {
            showToast = true
            return
        }
        save()
    }
    
    func save() {
        let delivery = AdvertisingMaterialDelivery()
        delivery.date = Utils.currentDateTime()
        delivery.deliveredFrom = JWTUtils.sub()
        details.forEach { d in
            delivery.materials.append(d)
        }
        AdvertisingMaterialDeliveryDao(realm: realm).store(advertisingMaterialDelivery: delivery)
        goTo()
    }
    
    func goTo() {
        savedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Globals.ENV_SAVE_DELAY) {
            moduleRouter.currentPage = "LIST"
        }
    }
}



struct MaterialDeliveryFormItemView: View {
    var realm: Realm
    @Binding var deliveryMaterial: AdvertisingMaterialDeliveryMaterial
    let onDeleteTapped: () -> Void
    
    var body: some View {
        let material = MaterialDao(realm: realm).by(id: deliveryMaterial.materialId)
        VStack {
            CustomCard {
                HStack {
                    Text(material?.name ?? "")
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
                ForEach(deliveryMaterial.sets.indices, id: \.self) { ix in
                    MaterialDeliverySetFormItemSetView(realm: realm, deliverySet: $deliveryMaterial.sets[ix])
                }
            }
        }
        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
    }
    
}

struct MaterialDeliverySetFormItemSetView: View {
    var realm: Realm
    @Binding var deliverySet: AdvertisingMaterialDeliveryMaterialSet
    
    @State private var expiredLimitSurpassed = false
    @State private var quantity = 0
    
    var body: some View {
        let set = MaterialSetDao(realm: realm).by(id: deliverySet.id)
        VStack {
            Divider()
                .frame(height: 0.7)
                .padding(.horizontal, 5)
                .background(Color.gray)
            HStack {
                Text(set?.label ?? "--")
                    .foregroundColor(.cTextHigh)
                Spacer()
                Text(String(format: NSLocalizedString("envExpDate", comment: ""), Utils.dateFormat(date: Utils.strToDate(value: set?.dueDate ?? ""), format: "dd MMM yy")))
                    .foregroundColor(expiredLimitSurpassed ? .cWarning : .cTextHigh)
            }
            HStack {
                Button(action: {
                    if deliverySet.quantity > 0 {
                        deliverySet.quantity -= 1
                        quantity = deliverySet.quantity
                    }
                }, label: {
                    Image("ic-minus-circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36)
                        .foregroundColor(.cIcon)
                        .opacity(expiredLimitSurpassed ? 0.4 : 1)
                })
                .disabled(expiredLimitSurpassed)
                Spacer()
                Text(String(quantity))
                    .foregroundColor(.cTextHigh)
                    .font(.system(size: 24))
                Spacer()
                Button(action: {
                    if deliverySet.quantity < ((set?.stock ?? 0) - (set?.delivered ?? 0)) {
                        deliverySet.quantity += 1
                        quantity = deliverySet.quantity
                    }
                }, label: {
                    Image("ic-plus-circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36)
                        .foregroundColor(.cIcon)
                        .opacity(expiredLimitSurpassed ? 0.4 : 1)
                })
                .disabled(expiredLimitSurpassed)
            }
            .padding(.horizontal, 15)
            Text(String(format: NSLocalizedString("envRemainder", comment: ""), String((set?.stock ?? 0) - (set?.delivered ?? 0))))
                .foregroundColor(.cHighlighted)
        }
        .onAppear {
            initialReactive()
            validateDueDate(set: set)
        }
    }
    
    func initialReactive() {
        quantity = deliverySet.quantity
    }
    
    func validateDueDate(set: AdvertisingMaterialSet?) {
        if let dueDate = set?.dueDate {
            if !dueDate.isEmpty {
                let limit = Config.get(key: "").value
                let interval = Utils.strToDate(value: dueDate) - Date()
                if interval.day ?? 0 < limit {
                    expiredLimitSurpassed = true
                }
            }
        }
    }
    
}
