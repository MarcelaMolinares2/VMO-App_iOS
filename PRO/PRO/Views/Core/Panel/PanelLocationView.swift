//
//  PanelLocationView.swift
//  PRO
//
//  Created by VMO on 21/12/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI

struct PanelLocationView: View {
    
    var panel: Panel!
    @State var couldAdd = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PanelLocationMapsView(locations: panel.locations)
            if couldAdd {
                FAB(image: "ic-plus") {
                    print(1)
                }
            }
        }
    }
}

struct PanelLocationView_Previews: PreviewProvider {
    static var previews: some View {
        PanelLocationView()
    }
}
