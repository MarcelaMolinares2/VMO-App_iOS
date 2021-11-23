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

struct Materials: Hashable{
    var id: String
    var name: String
}

struct MaterialRequestView: View {
    
    @ObservedObject private var selectMaterialsModalToggle = ModalToggle()
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var selectedMaterials = [String]()
    @State private var materialRequest = AdvertisingMaterialRequest()
    @State private var dateStart = Date()
    @State var materials: [Materials] = []
    
    var realm = try? Realm()
    
    let date = Date()
    
    @State var obs = ""
    
    @State private var showToast = false
    
    var body: some View {
        let bindingComment = Binding<String>(get: {
            materialRequest.comment
        }, set: {
            materialRequest.comment = $0
        })
        ZStack {
            VStack {
                HeaderToggleView(couldSearch: false, title: "modMaterialDelivery", icon: Image("ic-material"), color: Color.cPanelMaterial)
                
                HStack {
                    VStack{
                        Text(NSLocalizedString("envDate", comment: ""))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextHigh)
                        HStack{
                            DatePicker("", selection: $dateStart, in: Date()..., displayedComponents: .date)
                                .labelsHidden()
                                .clipped()
                                .accentColor(.cTextHigh)
                                .background(Color.white)
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    Image("ic-day-request")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .foregroundColor(Color.cPrimaryLight)
                }
                .padding(15)
                
                TextField(NSLocalizedString("materialObservations", comment: ""), text: bindingComment)
                    .frame(height: 30)
                    .padding([.leading, .trailing], 10)
                    .foregroundColor(.black)
                Divider()
                    .frame(width: UIScreen.main.bounds.size.width * 0.95, height: 1)
                    .background(Color.gray)
                List {
                    ForEach(materials, id: \.self) { item in
                        HStack{
                            Text(item.name)
                                .padding([.leading, .trailing], 15)
                                .padding([.top, .bottom], 10)
                            Spacer()
                        }
                        .background(Color.white)
                        .frame(alignment: Alignment.center)
                        .clipped()
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                    }
                    .onDelete(perform: self.delete)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack {
                Spacer()
                HStack {
                    FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                        selectMaterialsModalToggle.status.toggle()
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        formatter.timeStyle = .none
                        let datetime = formatter.string(from: dateStart)
                        if materials.count > 0 {
                            materialRequest.date = datetime
                            materialRequest.materials = materials.map { $0.id }.joined(separator: ",")
                            AdvertisingMaterialRequestDao(realm: try! Realm()).store(advertisingMaterialRequest: materialRequest)
                            goTo(page: "MASTER")
                        } else {
                            self.showToast.toggle()
                        }
                    }
                }
                .toast(isPresenting: $showToast) {
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
    
    func goTo(page: String) {
        viewRouter.currentPage = page
    }
    
    private func delete(at offsets: IndexSet) {
        self.materials.remove(atOffsets: offsets)
    }
    
    func onSelectionDone(_ selected: [String]) {
        selectMaterialsModalToggle.status.toggle()
        
        selectedMaterials.forEach { id in
            if let material = MaterialDao(realm: try! Realm()).by(id: id) {
                var exists = false
                for i in materials {
                    if i.name == material.name {
                        exists = true
                        break
                    }
                }
                if !exists {
                    materials.append(Materials(id: id, name: material.name ?? "" ))
                }
            }
        }
    }
}

struct MaterialRequestView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialRequestView()
    }
}
