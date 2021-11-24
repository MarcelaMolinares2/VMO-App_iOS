//
//  MovementFormTabsView.swift
//  PRO
//
//  Created by VMO on 23/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI


struct MovementFormTabPromotedView: View {
    
    @Binding var selected: [String]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("PROMOTED!!!!")
            }
        }
    }
    
}


struct MovementFormTabStockView: View {
    
    var body: some View {
        ScrollView {
            VStack {
                Text("STOCK!!!!")
            }
        }
    }
    
}


struct MovementFormTabShoppingView: View {
    
    var body: some View {
        ScrollView {
            VStack {
                Text("SHOPPING!!!!")
            }
        }
    }
    
}


struct MovementFormTabTransferenceView: View {
    
    var body: some View {
        ScrollView {
            VStack {
                Text("TRANSFERENCE!!!!")
            }
        }
    }
    
}
