//
//  MaterialRequestView.swift
//  PRO
//
//  Created by VMO on 24/08/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast


class AdvertisingMaterialRequestDetailModel: ObservableObject, Identifiable {
    var materialId: Int = 0
    @Published var quantity: Int = 0
    @Published var comment: String = ""
}


struct MaterialRequestView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var selected = [String]()
    @State private var details = [AdvertisingMaterialRequestDetailModel]()
    @State private var modalOpen = false
    @State private var showToast = false
    @State private var savedToast = false
    
    var realm = try! Realm()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HeaderToggleView(title: "modMaterialRequest")
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
                    ScrollView {
                        ForEach($details) { $detail in
                            let material = MaterialPlainDao(realm: realm).by(id: detail.materialId)
                            VStack {
                                CustomCard {
                                    HStack {
                                        Text(material?.name ?? "")
                                            .foregroundColor(.cTextHigh)
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(2)
                                        Button(action: {
                                            delete(detail: detail)
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
                                        .foregroundColor((detail.quantity < 0) ? Color.cDanger : .cTextMedium)
                                    TextField("envQuantity", value: $detail.quantity, formatter: NumberFormatter())
                                        .cornerRadius(CGFloat(4))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    Text("envObservations")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.cTextMedium)
                                    TextField("envObservations", text: $detail.comment)
                                        .cornerRadius(CGFloat(4))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
                        }
                        ScrollViewFABBottom()
                    }
                }
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
        .sheet(isPresented: $modalOpen) {
            DialogSourcePickerView(selected: $selected, key: "MATERIAL-PLAIN", multiple: true, title: "envMaterial") { selected in
                onSelectionDone(selected)
            }
        }
        .toast(isPresenting: $showToast) {
            AlertToast(type: .error(.cError), title: NSLocalizedString("errMaterialDeliveryEmpty", comment: ""))
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
        let materialRequest = AdvertisingMaterialRequest()
        materialRequest.date = Utils.currentDateTime()
        details.forEach { d in
            let detail = AdvertisingMaterialRequestDetail()
            detail.materialId = d.materialId
            detail.quantity = d.quantity
            detail.comment = d.comment
            materialRequest.details.append(detail)
        }
        AdvertisingMaterialRequestDao(realm: realm).store(advertisingMaterialRequest: materialRequest)
        goTo(page: "MASTER")
    }
    
    func goTo(page: String) {
        savedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Globals.ENV_SAVE_DELAY) {
            viewRouter.currentPage = page
        }
    }
    
    private func delete(detail: AdvertisingMaterialRequestDetailModel) {
        selected = selected.filter { $0 != String(detail.materialId) }
        details = details.filter { $0.materialId != detail.materialId }
    }
    
    func onSelectionDone(_ selected: [String]) {
        modalOpen = false
        selected.forEach { s in
            if details.filter({ d in
                d.materialId == Utils.castInt(value: s)
            }).count <= 0 {
                let detail = AdvertisingMaterialRequestDetailModel()
                detail.materialId = Utils.castInt(value: s)
                details.append(detail)
            }
        }
    }
}
