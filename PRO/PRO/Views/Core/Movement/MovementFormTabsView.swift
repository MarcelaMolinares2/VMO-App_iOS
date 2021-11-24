//
//  MovementFormTabsView.swift
//  PRO
//
//  Created by VMO on 23/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift


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
    
    @Binding var selected: RealmSwift.List<MovementProductStock>
    
    var body: some View {
        ScrollView {
            VStack {
                Text("STOCK!!!!")
            }
        }
    }
    
}


struct MovementFormTabShoppingView: View {
    
    @Binding var selected: RealmSwift.List<MovementProductShopping>
    
    var body: some View {
        ScrollView {
            VStack {
                Text("SHOPPING!!!!")
            }
        }
    }
    
}


struct MovementFormTabTransferenceView: View {
    
    @Binding var selected: RealmSwift.List<MovementProductTransference>
    
    var body: some View {
        ScrollView {
            VStack {
                Text("TRANSFERENCE!!!!")
            }
        }
    }
    
}
