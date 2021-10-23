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
    
    @State private var selectedMaterials = [String]()
    @State private var deliveries = MaterialDeliveryDao(realm: try! Realm()).all()
    
    var body: some View {
        ZStack {
            VStack{
                HeaderToggleView(couldSearch: false, title: "modMaterialDelivery", icon: Image("ic-material"), color: Color.cPanelMaterial)
                Spacer()
                List {
                    ForEach(deliveries, id: \.self) { item in
                        if let material = MaterialDao(realm: try! Realm()).by(id: String(item.materialId)) {
                            VStack{
                                HStack{
                                    Text(material.name ?? "")
                                    Spacer()
                                }
                                Spacer()
                                HStack{
                                    Text(String(material.sets[0].id))
                                    Spacer()
                                    Text(String(format: NSLocalizedString("materialQuantity", comment: ""), String(item.sets[0].quantity)))
                                        .font(.system(size: 18, weight: .heavy, design: .default))
                                }
                                Spacer()
                                HStack{
                                    Spacer()
                                    Text(formatStringDate(date: String(item.date)))
                                        .font(.system(size: 14))
                                }
                                
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
        print(deliveries)
    }
    
    func goTo(page: String) {
        viewRouter.currentPage = page
    }
    
    
    func formatStringDate(date: String) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let newDate = dateFormatter.date(from: date)
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM d, yyyy")
            return dateFormatter.string(from: newDate!)
    }
    
}

