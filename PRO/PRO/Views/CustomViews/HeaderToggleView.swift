//
//  HeaderToggleView.swift
//  PRO
//
//  Created by VMO on 30/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI

struct HeaderToggleView: View {
    @StateObject var headerRouter = TabRouter()
    
    @Binding private var searchText: String
    private var title: String
    
    private var couldSearch = false
    private var couldBack = false
    private var onBackPressed: () -> Void = {}
    
    @State private var menuIsPresented = false
    @State private var modalAgentLocation = false
    
    init(search: Binding<String>, title: String) {
        self.couldSearch = true
        self._searchText = search
        self.title = title
    }
    
    init(title: String) {
        self._searchText = Binding(
            get: { "" },
            set: { _ in }
        )
        self.title = title
        self.couldBack = false
    }
    
    init(title: String, onBackPressed: @escaping () -> Void) {
        self._searchText = Binding(
            get: { "" },
            set: { _ in }
        )
        self.title = title
        self.couldBack = true
        self.onBackPressed = onBackPressed
    }
    
    var body: some View {
        HStack {
            if headerRouter.current == "TITLE" {
                HStack {
                    if couldBack {
                        Button(action: {
                            onBackPressed()
                        }) {
                            Image("ic-back")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.cIcon)
                                .frame(width: 24, height: 24, alignment: .center)
                        }
                        .frame(width: 44, height: 44, alignment: .center)
                        Spacer()
                    } else {
                        Button(action: {
                            self.menuIsPresented = true
                        }) {
                            Image("logo-header")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60)
                        }
                    }
                }
                .frame(width: 60)
                Text((couldSearch ? NSLocalizedString("envSearch", comment: "") + " " + NSLocalizedString(title, comment: "").lowercased() : NSLocalizedString(title, comment: "")))
                    .foregroundColor(.cPrimaryDark)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .onTapGesture {
                        if couldSearch {
                            self.headerRouter.current = "SEARCH"
                        }
                    }
                HStack {
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Image("ic-notification")
                            .resizable()
                            .foregroundColor(.cIcon)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32, alignment: .center)
                            .padding(8)
                    }
                    .frame(width: 44, height: 44, alignment: .center)
                }
                .frame(width: 60)
            } else {
                SearchBar(text: $searchText, placeholder: Text(NSLocalizedString("envSearch", comment: "") + " " + NSLocalizedString(title, comment: "").lowercased())) {
                    self.headerRouter.current = "TITLE"
                }
            }
        }
        .padding(.horizontal, 8)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: 44)
        .partialSheet(isPresented: self.$menuIsPresented) {
            GlobalMenu(isPresented: self.$menuIsPresented) {
                menuIsPresented = false
                modalAgentLocation = true
            }
        }
        .partialSheet(isPresented: $modalAgentLocation) {
            AgentLocationForm() {
                modalAgentLocation = false
            }
        }
    }
}
