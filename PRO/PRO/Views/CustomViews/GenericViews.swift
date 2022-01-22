//
//  GenericViews.swift
//  PRO
//
//  Created by VMO on 1/12/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import RealmSwift
import SwiftUI

struct PanelListView: View {
    @State var data: Array<Panel & SyncEntity>
    @Binding var searchText: String

    var body: some View {
        ZStack(alignment: .trailing) {
            Text("Total en panel: \(data.count)")
                .foregroundColor(.cTextMedium)
                .font(.system(size: 12))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            Button(action: {
                
            }) {
                Text("Filtros")
                    .font(.system(size: 13))
                    .foregroundColor(.cTextLink)
                    .padding(.horizontal, 10)
            }
        }
        ScrollView {
            LazyVStack {
                ForEach(data.filter {
                    self.searchText.isEmpty ? true :
                        ($0.name ?? "").lowercased().contains(self.searchText.lowercased()) ||
                        ($0.city?.name ?? "").lowercased().contains(self.searchText.lowercased())
                }, id: \.id) { element in
                    PanelItem(panel: element).onTapGesture {
                        
                    }
                }
            }
        }
    }
}

struct PanelItem: View {
    @State var panel: Panel & SyncEntity
    @State var address = ""
    @State var visitsFee = 0
    @State var visitsCycle = 0
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack {
                    Text(panel.name ?? " -- ")
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                        .foregroundColor(.cPrimary)
                    /*if panel.specialty?.name != nil {
                        Text(panel.specialty?.name ?? " -- ")
                            .font(.system(size: 14))
                            .foregroundColor(.cPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    */
                    Text(panel.type == "M" ? "\(address), \(panel.city?.name ?? " -- ")" : panel.city?.name ?? " -- ")
                        .font(.system(size: 14))
                        .foregroundColor(.cPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                    /*Text(panel.type == "M" ? panel.institution ?? " -- " : address)
                        .font(.system(size: 14))
                        .foregroundColor(.cPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    */
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .trailing, spacing: 2) {
                    VStack {
                        Text(panel.category?.name ?? "")
                            .padding(.horizontal, 5)
                            .font(.system(size: 14))
                            .foregroundColor(.cTextLight)
                            .frame(height: 20)
                    }
                    .frame(minWidth: 30)
                    .background(Color.cPrimary)
                    Text("\(visitsCycle)/\(visitsFee)")
                        .font(.system(size: 14))
                        .frame(width: 30, height: 20, alignment: .center)
                        .background(Color.red)
                        .foregroundColor(.white)
                }
                .frame(minWidth: 30)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        .onAppear {
            manage()
        }
    }
    
    func manage() {
        if panel.locations.count > 0 {
            let location = panel.locations[0]
            address = location.address ?? ""
        }
        let sub = JWTUtils.sub()
        panel.userPanel.forEach { item in
            if item.userID == sub {
                visitsFee = item.visitsFee
                visitsCycle = item.visitsCycle
            }
        }
    }
}

struct KeyInfoView: View {
    @State var panel: Panel!
    
    @State var headerColor = Color.cPrimary
    @State var headerIcon = "ic-home"
    
    var body: some View {
        VStack {
            HStack {
                Text(panel.name ?? "")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .padding(.horizontal, 5)
                    .foregroundColor(.white)
                Image(headerIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34, alignment: .center)
                    .padding(4)
            }
            .background(headerColor)
            .frame(maxWidth: .infinity)
            ScrollView {
                VStack {
                    
                }
            }
        }
    }
}

protocol CustomContainerView: View {
    associatedtype Content
    init(content: @escaping () -> Content)
}

extension CustomContainerView {
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.init(content: content)
    }
}

struct CustomForm<Content: View>: CustomContainerView {
    var content: () -> Content
    
    var body: some View {
        ScrollView {
            VStack(content: content).padding()
        }
        .background(Color.cForm)
    }
}

struct CustomSection<Content: View>: View {
    var title: String = ""
    var content: () -> Content
    
    init(_ title: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack {
            if !title.isEmpty {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.cTextMedium)
            }
            VStack(content: content)
                .padding()
                .background(Color.white)
                .cornerRadius(5)
        }
        .padding(.top, 10)
    }
}

