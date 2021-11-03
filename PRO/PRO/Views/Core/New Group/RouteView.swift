//
//  RouteView.swift
//  PRO
//
//  Created by Fernando Garcia on 28/10/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct RouteView: View {
    @ObservedObject private var moduleRouter = ModuleRouter()
    var body: some View {
        switch moduleRouter.currentPage {
        case "LIST":
            RouteListView(moduleRouter: moduleRouter)
        case "FORM":
            RouteFormView(moduleRouter: moduleRouter)
        default:
            Text("")
        }
    }
}

struct RouteListView: View {
    @ObservedObject var moduleRouter: ModuleRouter
    var body: some View {
        ZStack {
            VStack{
                HeaderToggleView(couldSearch: true, title: "modPeopleRoute", icon: Image("ic-people-route"), color: Color.cPanelRequestDay)
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                        moduleRouter.currentPage = "FORM"
                    }
                }
            }
        }
    }
}

struct RouteFormView: View {
    @ObservedObject var moduleRouter: ModuleRouter
    @State private var name = ""
    @State private var items = [Panel & SyncEntity]()
    @State private var isValidationOn = false
    @State private var cardShow = false
    
    var body: some View {
        ZStack {
            VStack {
                HeaderToggleView(couldSearch: false, title: "modPeopleRoute", icon: Image("ic-people-route"), color: Color.cPanelRequestDay)
                VStack{
                    TextField(NSLocalizedString("envName", comment: ""), text: $name)
                    Divider()
                     .frame(height: 1)
                     .padding(.horizontal, 5)
                     .background(Color.gray)
                }.padding(10)
                ScrollView {
                    LazyVStack {
                        ForEach(items, id: \.id) { element in
                            PanelItem(panel: element)
                        }
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                        if validate() {
                            save()
                        }
                        moduleRouter.currentPage = "LIST"
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                        cardShow.toggle()
                        print(UIScreen.main.bounds.width)
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
        }
        .partialSheet(isPresented: self.$cardShow) {
            CardMenuPanels(arrayShow: ["M", "F", "C", "P"], isPresented: self.$cardShow)
        }
    }
    
    func validate() -> Bool {
        isValidationOn = true
        if items.isEmpty {
            return false
        }
        return true
    }
    
    func save() {
        
    }
    
}

struct itemsGrid : Hashable{
    var color: Color
    var nameIcon: String
    var name: String
}

struct CardMenuPanels: View {
    @State var arrayShow: [String]
    @Binding var isPresented: Bool
    @State private var arrayCustomItemsPanels: [itemsGrid] = []
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View{
        VStack{
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(arrayCustomItemsPanels, id: \.self) { item in
                    Button(action: {
                        print(item.name)
                    }) {
                        VStack (alignment: .center){
                            Image(item.nameIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25)
                                .foregroundColor(item.color)
                            Spacer()
                            Text(NSLocalizedString(item.name, comment: ""))
                                .padding(.horizontal)
                                .foregroundColor(.cPrimary)
                        }
                    }
                }
            }
            Spacer()
                .frame(height: 30)
        }
        .onAppear{
            loadData()
        }
    }
    func loadData(){
        var card = itemsGrid(color: .cPrimary, nameIcon: "none", name: "none")
        for item in arrayShow{
            switch item {
                case "M":
                    card.color = .cPanelMedic
                    card.nameIcon = "ic-medic"
                    card.name = "modMedic"
                    arrayCustomItemsPanels.append(card)
                case "F":
                    card.color = .cPanelPharmacy
                    card.nameIcon = "ic-pharmacy"
                    card.name = "modPharmacy"
                    arrayCustomItemsPanels.append(card)
                case "C":
                    card.color = .cPanelClient
                    card.nameIcon = "ic-client"
                    card.name = "modClient"
                    arrayCustomItemsPanels.append(card)
                case "P":
                    card.color = .cPanelPatient
                    card.nameIcon = "ic-patient"
                    card.name = "modPatient"
                    arrayCustomItemsPanels.append(card)
                default:
                    print("default")
            }
        }
    }
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        RouteView()
    }
}
