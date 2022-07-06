//
//  ActivityListView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct ActivityListWrapperView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Binding var searchText: String
    
    @State var layout: GenericListLayout = .list
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            switch layout {
                case .list:
                    ActivityListView(viewRouter: viewRouter)
                case .map:
                    ActivityMapView()
            }
            HStack {
                FAB(image: (layout == .list) ? "ic-list": "ic-map") {
                    layout = layout == .list ? .map : .list
                }
                Spacer()
                FAB(image: "ic-plus") {
                    FormEntity(objectId: "").go(path: "DTV-FORM", router: viewRouter)
                }
            }
            .padding(.horizontal, 20)
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

struct ActivityListView: View{
    
    @ObservedObject var viewRouter: ViewRouter
    @ObservedResults(DifferentToVisit.self, sortDescriptor: SortDescriptor(keyPath: "dateFrom", ascending: false)) var activities
    @State private var optionsModal = false
    
    @State private var activitySelected: DifferentToVisit = DifferentToVisit()
    
    var body: some View {
        VStack{
            List {
                ForEach (activities, id: \.objectId){ item in
                    ActivityItemCardView(item: item).onTapGesture {
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
    
    func onEdit(_ activity: DifferentToVisit) {
        self.optionsModal = false
        viewRouter.data = FormEntity(objectId: activity.objectId.stringValue)
        FormEntity(objectId: activity.objectId.stringValue).go(path: "DTV-FORM", router: viewRouter)
        print("Edit")
    }
    
    func onDetail(_ activity: DifferentToVisit) {
        self.optionsModal = false
        viewRouter.data = FormEntity(objectId: activity.objectId.stringValue)
        FormEntity(objectId: activity.objectId.stringValue).go(path: "DTV-SUMMARY", router: viewRouter)
        print("Datile")
    }
}

struct ActivityItemCardView: View{
    var item: DifferentToVisit
    
    var body: some View {
        VStack {
            Text(item.comment)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.cTextMedium)
                .font(.system(size: 16))
                .fixedSize(horizontal: false, vertical: true)
                .padding([.leading, .trailing], 4)
            Text("\(Utils.dateFormat(value: item.dateFrom, toFormat: "dd, MMM yy")) \(NSLocalizedString("envTo", comment: "to")) \(Utils.dateFormat(value: item.dateTo, toFormat: "dd, MMM yy"))")
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
