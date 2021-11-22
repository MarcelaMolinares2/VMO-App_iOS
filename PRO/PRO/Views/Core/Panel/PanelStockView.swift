//
//  PanelStockView.swift
//  PRO
//
//  Created by VMO on 22/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI

struct PanelStockView: View {
    
    var panel: Panel!
    @State var couldAdd = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            if couldAdd {
                FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                    print(1)
                }
            }
        }
    }
    
}

