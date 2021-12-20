//
//  ActivityListView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct ActivityListView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Binding var searchText: String
    
    @State var viewActivity = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                if !viewActivity{
                    ListView()
                } else {
                    MapView()
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                        FormEntity(objectId: "").go(path: "DTV-FORM", router: viewRouter)
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    FAB(image: (viewActivity) ? "ic-list": "ic-map", foregroundColor: .cPrimary) {
                        viewActivity.toggle()
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
        }
    }
}

struct MapView: View{
    var body: some View {
        VStack{
            Text("Hola")
            Spacer()
        }
    }
}

struct ListView: View{
    
    @ObservedResults(Activity.self) var activity
    
    var body: some View {
        VStack{
            List {
                ForEach (activity, id: \.objectId){ item in
                    VStack {
                        Text(item.description_ ?? "")
                            //.frame(width: UIScreen.main.bounds.width / 2, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextMedium)
                            .font(.system(size: 16))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding([.leading, .trailing], 4)
                            /*
                            Text()
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                                .fixedSize(horizontal: false, vertical: true)
                            */
                        Text(Utils.dateFormat(date: Utils.strToDate(value: item.dateStart ?? Utils.dateFormat(date: Date())), format: "dd, MMM yy") + ". " + Utils.dateFormat(date: Utils.strToDate(value: item.dateEnd ?? Utils.dateFormat(date: Date())), format: "dd, MMM yy"))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(.cTextMedium)
                            .font(.system(size: 14))
                            .fixedSize(horizontal: false, vertical: true)
                        .padding([.leading, .trailing], 4)
                        .padding([.top, .bottom], 2)
                    }
                    .padding([.top, .bottom], 10)
                    .background(Color.white)
                    .frame(alignment: Alignment.center)
                    .clipped()
                    .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                    
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
