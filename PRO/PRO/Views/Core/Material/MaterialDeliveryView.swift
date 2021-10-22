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
    @State private var deliveries = [AdvertisingMaterialDelivery]()
    
    var body: some View {
        ZStack {
            VStack{
                HeaderToggleView(couldSearch: false, title: "modMaterialDelivery", icon: Image("ic-material"), color: Color.cPanelMaterial)
                Spacer()
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
    }
    func goTo(page: String) {
        viewRouter.currentPage = page
        //self.isPresented = false
    }
    
}

