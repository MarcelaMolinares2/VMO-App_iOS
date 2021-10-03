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
    
    @State var menuIsPresented = false
    @State var couldSearch = false
    
    @State var searchText = ""
    
    @State var title = ""
    @State var icon = Image("ic-home")
    @State var color = Color.cPrimary
    
    var body: some View {
        HStack {
            Button(action: {
                self.menuIsPresented = true
            }) {
                Image("logo-header")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70)
            }
            if headerRouter.current == "TITLE" {
                Text((couldSearch ? NSLocalizedString("envSearch", comment: "") + " " + NSLocalizedString(title, comment: "").lowercased() : NSLocalizedString(title, comment: "")))
                    .foregroundColor(.cPrimaryDark)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .onTapGesture {
                        if couldSearch {
                            self.headerRouter.current = "SEARCH"
                        }
                    }
                icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, alignment: .center)
                    .padding(6)
                    .foregroundColor(color)
            } else {
                SearchBar(headerRouter: self.headerRouter, text: $searchText, placeholder: Text(NSLocalizedString("envSearch", comment: "") + " " + NSLocalizedString(title, comment: "").lowercased()))
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: 44)
        .partialSheet(isPresented: self.$menuIsPresented) {
            GlobalMenu(isPresented: self.$menuIsPresented)
        }
    }
}

struct HeaderToggleView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderToggleView()
    }
}
