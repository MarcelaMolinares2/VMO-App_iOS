//
//  ReportGenericViews.swift
//  PRO
//
//  Created by VMO on 19/09/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct CustomReportListView<Content: View, ContentMap: View>: View {
    var realm: Realm
    let hasMap: Bool
    @Binding var userSelected: Int
    var list: () -> Content
    var map: () -> ContentMap
    let onAgentChanged: () -> Void

    @State private var layout: ViewLayout = .list
    @State private var selectedUser = [String]()
    @State private var modalUserOpen = false
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            VStack {
                if userSelected > 0 {
                    HStack {
                        VStack {
                            Image("ic-user")
                                .resizable()
                                .foregroundColor(.cIcon)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22, alignment: .center)
                        }
                        .frame(width: 40, height: 40, alignment: .center)
                        let user = UserDao(realm: realm).by(id: userSelected)
                        Text((user?.name ?? "").capitalized)
                            .foregroundColor(.cTextHigh)
                            .lineLimit(1)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        Button(action: {
                            userSelected = 0
                            onAgentChanged()
                        }) {
                            Image("ic-close")
                                .resizable()
                                .foregroundColor(.cIcon)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20, alignment: .center)
                        }
                        .frame(width: 40, height: 40, alignment: .center)
                    }
                    .frame(height: 40)
                }
                if layout == .list {
                    ScrollView {
                        VStack(content: list)
                        ScrollViewFABBottom()
                    }
                } else {
                    VStack(content: map)
                }
            }
            HStack(alignment: .bottom) {
                FAB(image: layout == .map ? "ic-list" : "ic-map") {
                    layout = layout == .map ? .list : .map
                }
                Spacer()
                if let user = UserDao(realm: realm).logged() {
                    if !user.hierarchy.isEmpty {
                        FAB(image: "ic-user") {
                            modalUserOpen = true
                        }
                    }
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .sheet(isPresented: $modalUserOpen) {
            DialogSourcePickerView(selected: $selectedUser, key: "USER-HIERARCHY", multiple: false, title: NSLocalizedString("envAgent", comment: "Agent")) { selected in
                modalUserOpen = false
                if !selected.isEmpty {
                    if userSelected != Utils.castInt(value: selected[0]) {
                        userSelected = Utils.castInt(value: selected[0])
                        onAgentChanged()
                    }
                }
            }
        }
    }
    
}
