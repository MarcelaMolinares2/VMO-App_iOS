//
//  MaterialDeliveryView.swift
//  PRO
//
//  Created by VMO on 24/08/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct MaterialDeliveryView: View {
    
    @ObservedObject private var selectMaterialsModalToggle = ModalToggle()
    @EnvironmentObject var viewRouter: ViewRouter
    
    //@Binding var isPresented: Bool
    
    @State private var selectedMaterials = [String]()
    //@State private var deliveries = [AdvertisingMaterialDelivery]()
    @State private var deliveries = MaterialDeliveryDao(realm: try! Realm()).all()
    
    var body: some View {
        ZStack {
            VStack{
                HeaderToggleView(couldSearch: false, title: "modMaterialDelivery", icon: Image("ic-material"), color: Color.cPanelMaterial)
                Spacer()
                List {
                    ForEach(deliveries, id: \.id) { item in
                        VStack{
                            Text(item.material?.name ?? "")
                            Spacer()
                            HStack{
                                Text("hhh: \(String(item.comment))")
                                Spacer()
                                Text("Cantidad")
                                //Text(String(item.sets.quantity))
                            }
                            
                            
                            Divider()
                             .frame(height: 1)
                             .padding(.horizontal, 30)
                             .background(Color.red)
                        }
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-plus", foregroundColor: .cPrimaryLight) {
                        
                        self.goTo(page: "MATERIAL-REQUEST")
                    }
                }
            }
        }
        .onAppear{
            load()
        }
    }
    
    func load() {
        print("__________For deliveries__________")
        for i in deliveries{
            print(i.material ?? [])
        }
        print("__________For deliveries__________")
    }
    
    func goTo(page: String) {
        viewRouter.currentPage = page
        //self.isPresented = false
    }
    
}

