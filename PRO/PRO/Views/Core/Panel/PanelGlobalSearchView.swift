//
//  PanelGlobalSearchView.swift
//  PRO
//
//  Created by VMO on 11/09/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI

struct PanelGlobalSearchView: View {
    
    @State private var search = ""
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modGeneralSearch")
            SearchBar(text: $search, placeholder: Text("Search")) {
                
            }
            ScrollView {
                
            }
        }
    }
}
