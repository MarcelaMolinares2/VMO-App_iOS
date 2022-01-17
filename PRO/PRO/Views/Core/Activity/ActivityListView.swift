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
                    ActivityItemsView(viewRouter: viewRouter)
                } else {
                    ActivityMapView()
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

struct ActivityMapView: View{
    var body: some View {
        VStack{
            Text("Hola")
            Spacer()
        }
    }
}

struct ActivityItemsView: View{
    
    @ObservedObject var viewRouter: ViewRouter
    @ObservedResults(Activity.self) var activitys
    @State private var optionsModal = false
    
    @State private var activitySelected: Activity = Activity()
    
    var body: some View {
        VStack{
            List {
                ForEach (activitys.sorted { Utils.strDateFormat(value: $0.dateStart ?? "") < Utils.strDateFormat(value: $1.dateStart ?? "")}, id: \.objectId){ item in
                    ActivityItemsCardView(item: item).onTapGesture {
                        self.activitySelected = item
                        self.optionsModal = true
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .partialSheet(isPresented: $optionsModal) {
            ActivityBottomMenu(onEdit: onEdit, onDetail: onDetail, activity: activitySelected)
        }
    }
    
    func onEdit(_ activity: Activity) {
        self.optionsModal = false
        viewRouter.data = FormEntity(objectId: activity.objectId.stringValue)
        FormEntity(objectId: activity.objectId.stringValue).go(path: "DTV-FORM", router: viewRouter)
        print("Edit")
    }
    
    func onDetail(_ activity: Activity) {
        self.optionsModal = false
        viewRouter.data = FormEntity(objectId: activity.objectId.stringValue)
        FormEntity(objectId: activity.objectId.stringValue).go(path: "DTV-SUMMARY", router: viewRouter)
        print("Datile")
    }
}

struct ActivityItemsCardView: View{
    var item: Activity
    
    var body: some View {
        VStack {
            Text(item.description_ ?? "")
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.cTextMedium)
                .font(.system(size: 16))
                .fixedSize(horizontal: false, vertical: true)
                .padding([.leading, .trailing], 4)
            Text(Utils.dateFormat(date: Utils.strToDate(value: item.dateStart ?? Utils.dateFormat(date: Date())), format: "dd, MMM yy") + ". " + Utils.dateFormat(date: Utils.strToDate(value: item.dateEnd ?? Utils.dateFormat(date: Date())), format: "dd, MMM yy"))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(.cTextMedium)
                .font(.system(size: 14))
                .fixedSize(horizontal: false, vertical: true)
            .padding([.leading, .trailing], 4)
            .padding([.top, .bottom], 2)
        }
        //.padding([.top, .bottom], 10)
        .padding(10)
        .background(Color.white)
        .frame(alignment: Alignment.center)
        .clipped()
        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
    }
    
}
